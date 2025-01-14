Feature: git town-kill: killing a local branch in offline mode

  When offline
  I want to be able to still delete the current branch including all open changes
  So that I can work as much as possible despite no internet connection.


  Background:
    Given Git Town is in offline mode
    And my repo has the feature branches "current-feature" and "other-feature"
    And the following commits exist in my repo
      | BRANCH          | LOCATION      | MESSAGE                |
      | current-feature | local, remote | current feature commit |
      | other-feature   | local, remote | other feature commit   |
    And I am on the "current-feature" branch
    And my workspace has an uncommitted file
    When I run "git-town kill"


  Scenario: result
    Then it runs the commands
      | BRANCH          | COMMAND                                |
      | current-feature | git add -A                             |
      |                 | git commit -m "WIP on current-feature" |
      |                 | git checkout main                      |
      | main            | git branch -D current-feature          |
    And I am now on the "main" branch
    And my repo doesn't have any uncommitted files
    And the existing branches are
      | REPOSITORY | BRANCHES                             |
      | local      | main, other-feature                  |
      | remote     | main, current-feature, other-feature |
    And my repo now has the following commits
      | BRANCH          | LOCATION      | MESSAGE                |
      | current-feature | remote        | current feature commit |
      | other-feature   | local, remote | other feature commit   |


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
      | remote     | main, current-feature, other-feature |
    And my repo is left with my original commits
