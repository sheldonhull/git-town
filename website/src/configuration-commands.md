# Configuration commands

Git Town prompts for required configuration information during usage. Git Town
stores its configuration data inside
[Git configuration data](https://git-scm.com/docs/git-config). You can store
configuration values in the local or global Git configuration depending on
whether you want to share config settings between repositories or not. To see
your entire Git configuration, run `git config -l`. To see only the Git Town
configuration entries, run `git config --get-regexp git-town`. The following
commands read and write the configuration entries for you so that you don't have
to run Git configuration commands manually:

- [git town config](commands/config.md) - display or update your Git Town
  configuration
- [git town new-branch-push-flag](commands/new-branch-push-flag.md) - configure
  whether new empty branches are pushed to origin
- [git town main-branch](commands/main-branch.md) - display/set the main
  development branch for the current repo
- [git town offline](commands/offline.md) - enable/disable offline mode
- [git town perennial-branches](commands/perennial-branches.md) - display or
  update the perennial branches for the current repo
- [git town pull-branch-strategy](commands/pull-branch-strategy.md) - display or
  set the strategy to update perennial branches
