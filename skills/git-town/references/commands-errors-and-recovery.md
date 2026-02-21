# Commands: errors and recovery

Use these when a Git Town command stops or you need to roll back.

Core recovery commands:
- `git town status` - show pending Git Town command and options
- `git town continue` - continue after resolving conflicts
- `git town skip` - skip the current branch and continue
- `git town undo` - undo the last Git Town command

Diagnostics and runstate:
- `git town runlog` - show the runlog (pre/post command SHAs)
- `git town status reset` - clear a corrupted runstate
- `git town status show` - display detailed runstate

Docs:
- https://www.git-town.com/commands/status
- https://www.git-town.com/commands/continue
- https://www.git-town.com/commands/skip
- https://www.git-town.com/commands/undo
- https://www.git-town.com/commands/runlog
- https://www.git-town.com/commands/status-reset
- https://www.git-town.com/commands/status-show
