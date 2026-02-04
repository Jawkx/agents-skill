---
name: address-gh-review
description: guide for addressing github reviews from other users. This skill should be used when user give you a github PR
---

User will give you a github PR or a github link. And then optionally will give you a comment on who's comments should be addressed (maybe a github user name or just a name)

## How to use

1. First, use gh cli to get the PR details, get the branch of the PR
2. Use gwq to create a new worktree and then CO to the PR branch, and then make sure it's up to date
3. Read the comments/review from the user and then check out the codebase to understand the context more
4. Then reply to user (in codex not on github) with this format


``` markdown
## <numbering> Short description of the comment
- How critical is the comment
- validity of the comment (if it's not valid, then why)
- what's the actionable step to address this 

## <numbering> Short description of the comment 2
...
```

Numbering is important so that user can easily reference the comment
