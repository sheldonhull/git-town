Feature: git town-kill: killing the current feature branch with a deleted tracking branch

  As a user killing the current feature branch whose remote branch has been deleted
  I want the command to succeed anyways
  So that killing branches is robust and reliable.


  Background:
    Given my repo has the feature branches "current-feature" and "other-feature"
    And the following commits exist in my repo
      | BRANCH          | LOCATION      | MESSAGE                |
      | current-feature | local, remote | current feature commit |
      | other-feature   | local, remote | other feature commit   |
    And the "current-feature" branch gets deleted on the remote
    And I am on the "current-feature" branch
    And my workspace has an uncommitted file
    When I run "git-town kill"


  Scenario: result
    Then it runs the commands
      | BRANCH          | COMMAND                                |
      | current-feature | git fetch --prune --tags               |
      |                 | git add -A                             |
      |                 | git commit -m "WIP on current-feature" |
      |                 | git checkout main                      |
      | main            | git branch -D current-feature          |
    And I am now on the "main" branch
    And my repo doesn't have any uncommitted files
    And the existing branches are
      | REPOSITORY | BRANCHES            |
      | local      | main, other-feature |
      | remote     | main, other-feature |
    And my repo now has the following commits
      | BRANCH        | LOCATION      | MESSAGE              |
      | other-feature | local, remote | other feature commit |


  Scenario: undoing the kill
    When I run "git-town undo"
    Then it runs the commands
      | BRANCH          | COMMAND                                                       |
      | main            | git branch current-feature {{ sha 'WIP on current-feature' }} |
      |                 | git checkout current-feature                                  |
      | current-feature | git reset {{ sha 'current feature commit' }}                  |
    And I am now on the "current-feature" branch
    And my workspace has the uncommitted file again
    And the existing branches are
      | REPOSITORY | BRANCHES                             |
      | local      | main, current-feature, other-feature |
      | remote     | main, other-feature                  |
    And my repo now has the following commits
      | BRANCH          | LOCATION      | MESSAGE                |
      | current-feature | local         | current feature commit |
      | other-feature   | local, remote | other feature commit   |
