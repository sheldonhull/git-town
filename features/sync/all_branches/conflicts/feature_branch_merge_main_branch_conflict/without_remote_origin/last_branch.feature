Feature: git-town sync --all: handling merge conflicts between feature branch and main branch (without remote repo)

  Background:
    Given my repo does not have a remote origin
    And my repo has the local feature branches "feature-1" and "feature-2"
    And the following commits exist in my repo
      | BRANCH    | LOCATION | MESSAGE          | FILE NAME        | FILE CONTENT      |
      | main      | local    | main commit      | conflicting_file | main content      |
      | feature-1 | local    | feature-1 commit | feature1_file    | feature-1 content |
      | feature-2 | local    | feature-2 commit | conflicting_file | feature-2 content |
    And I am on the "main" branch
    And my workspace has an uncommitted file
    When I run "git-town sync --all"


  Scenario: result
    Then it runs the commands
      | BRANCH    | COMMAND                  |
      | main      | git add -A               |
      |           | git stash                |
      |           | git checkout feature-1   |
      | feature-1 | git merge --no-edit main |
      |           | git checkout feature-2   |
      | feature-2 | git merge --no-edit main |
    And it prints the error:
      """
      To abort, run "git-town abort".
      To continue after having resolved conflicts, run "git-town continue".
      To continue by skipping the current branch, run "git-town skip".
      """
    And I am now on the "feature-2" branch
    And my uncommitted file is stashed
    And my repo now has a merge in progress


  Scenario: aborting
    When I run "git-town abort"
    Then it runs the commands
      | BRANCH    | COMMAND                                       |
      | feature-2 | git merge --abort                             |
      |           | git checkout feature-1                        |
      | feature-1 | git reset --hard {{ sha 'feature-1 commit' }} |
      |           | git checkout main                             |
      | main      | git stash pop                                 |
    And I am now on the "main" branch
    And my workspace has the uncommitted file again
    And my repo is left with my original commits


  Scenario: skipping
    When I run "git-town skip"
    Then it runs the commands
      | BRANCH    | COMMAND           |
      | feature-2 | git merge --abort |
      |           | git checkout main |
      | main      | git stash pop     |
    And I am now on the "main" branch
    And my workspace has the uncommitted file again
    And my repo now has the following commits
      | BRANCH    | LOCATION | MESSAGE                            | FILE NAME        |
      | main      | local    | main commit                        | conflicting_file |
      | feature-1 | local    | feature-1 commit                   | feature1_file    |
      |           |          | main commit                        | conflicting_file |
      |           |          | Merge branch 'main' into feature-1 |                  |
      | feature-2 | local    | feature-2 commit                   | conflicting_file |
    And my repo now has the following committed files
      | BRANCH    | NAME             | CONTENT           |
      | main      | conflicting_file | main content      |
      | feature-1 | conflicting_file | main content      |
      | feature-1 | feature1_file    | feature-1 content |
      | feature-2 | conflicting_file | feature-2 content |


  Scenario: continuing without resolving the conflicts
    When I run "git-town continue"
    Then it runs no commands
    And it prints the error:
      """
      you must resolve the conflicts before continuing
      """
    And I am still on the "feature-2" branch
    And my uncommitted file is stashed
    And my repo still has a merge in progress


  Scenario: continuing after resolving the conflicts
    Given I resolve the conflict in "conflicting_file"
    And I run "git-town continue"
    Then it runs the commands
      | BRANCH    | COMMAND              |
      | feature-2 | git commit --no-edit |
      |           | git checkout main    |
      | main      | git stash pop        |
    And I am now on the "main" branch
    And my workspace has the uncommitted file again
    And my repo now has the following commits
      | BRANCH    | LOCATION | MESSAGE                            | FILE NAME        |
      | main      | local    | main commit                        | conflicting_file |
      | feature-1 | local    | feature-1 commit                   | feature1_file    |
      |           |          | main commit                        | conflicting_file |
      |           |          | Merge branch 'main' into feature-1 |                  |
      | feature-2 | local    | feature-2 commit                   | conflicting_file |
      |           |          | main commit                        | conflicting_file |
      |           |          | Merge branch 'main' into feature-2 |                  |
    And my repo now has the following committed files
      | BRANCH    | NAME             | CONTENT           |
      | main      | conflicting_file | main content      |
      | feature-1 | conflicting_file | main content      |
      | feature-1 | feature1_file    | feature-1 content |
      | feature-2 | conflicting_file | resolved content  |


  Scenario: continuing after resolving the conflicts and committing
    Given I resolve the conflict in "conflicting_file"
    And I run "git commit --no-edit"
    And I run "git-town continue"
    Then it runs the commands
      | BRANCH    | COMMAND           |
      | feature-2 | git checkout main |
      | main      | git stash pop     |
    And I am now on the "main" branch
    And my workspace has the uncommitted file again
    And my repo now has the following commits
      | BRANCH    | LOCATION | MESSAGE                            | FILE NAME        |
      | main      | local    | main commit                        | conflicting_file |
      | feature-1 | local    | feature-1 commit                   | feature1_file    |
      |           |          | main commit                        | conflicting_file |
      |           |          | Merge branch 'main' into feature-1 |                  |
      | feature-2 | local    | feature-2 commit                   | conflicting_file |
      |           |          | main commit                        | conflicting_file |
      |           |          | Merge branch 'main' into feature-2 |                  |
    And my repo now has the following committed files
      | BRANCH    | NAME             | CONTENT           |
      | main      | conflicting_file | main content      |
      | feature-1 | conflicting_file | main content      |
      | feature-1 | feature1_file    | feature-1 content |
      | feature-2 | conflicting_file | resolved content  |
