#### NAME

hack - create a new feature branch off the main development branch

#### SYNOPSIS

```
git town hack <branch_name>
git town hack (--abort | --continue)
```

#### DESCRIPTION

Syncs the main branch and forks a new feature branch with the given name off it.

If (and only if) [new-branch-push-flag](./new-branch-push-flag.md) is true,
pushes the new feature branch to the remote repository.

Finally, brings over all uncommitted changes to the new feature branch.

#### OPTIONS

```
<branch_name>
    The name of the branch to create.

--abort
    Cancel the operation and reset the workspace to a consistent state.

--continue
    Continue the operation after resolving conflicts.
```

#### Sample Output

From another feature branch with uncommitted changes.

```
$ git-town hack new-feature

[existing-feature] git fetch --prune
From <...>
   e2329dd..7a79f72  main       -> origin/main

[existing-feature] git add -A

[existing-feature] git stash
Saved working directory and index state WIP on existing-feature: 6f7ffde existing feature commit

[existing-feature] git checkout main
Switched to branch 'main'
Your branch is behind 'origin/main' by 1 commit, and can be fast-forwarded.
  (use "git pull" to update your local branch)

[main] git rebase origin/main
First, rewinding head to replay your work on top of it...
Fast-forwarded main to origin/main.

[main] git checkout -b new-feature main
Switched to a new branch 'new-feature'

[new-feature] git stash pop
On branch new-feature
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

	new file:   uncommitted_file

Dropped refs/stash@{0} (6df22a26ac8dacfc2d55886f0deb495f024ec2f3)
```

Output from this [feature](/features/git-town-hack/on_feature_branch/with_remote_origin.feature).
