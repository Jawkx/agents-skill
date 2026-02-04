# Review Process (gh + git worktree)

## 0) Prepare a dedicated PR workspace (required)
Goal: review code in an isolated directory that matches what will land on the base branch.

### Preconditions
- Repo is clean (or stash your local work):
  - `git status --porcelain` should be empty
- You are authenticated in gh:
  - `gh auth status`

### Fetch PR metadata (given PR number)
Set the PR number:
- `PR_NUMBER=1234`

Get a quick summary:
- `gh pr view "$PR_NUMBER" --json title,author,state,baseRefName,headRefName,url,labels,files,additions,deletions`

Optional: capture base + head branches:
- `BASE_BRANCH=$(gh pr view "$PR_NUMBER" --json baseRefName --jq .baseRefName)`
- `HEAD_BRANCH=$(gh pr view "$PR_NUMBER" --json headRefName --jq .headRefName)`

### Fetch the PR refs (prefer merge result)
Prefer reviewing the merge result (what will be merged), then fallback to head ref if needed.

Assuming the base repo remote is `origin`:

1) Fetch the merge ref into a local branch:
- `git fetch origin "refs/pull/$PR_NUMBER/merge:pr/$PR_NUMBER/merge"`

2) Also fetch the head ref:
- `git fetch origin "refs/pull/$PR_NUMBER/head:pr/$PR_NUMBER/head"`

If your hosting setup does not expose the merge ref, you can still review the head branch by skipping step (1) and using `pr/$PR_NUMBER/head`.

### Create a worktree workspace
Note:
- If another workspace/worktree management skill is available, use that skill to manage the workspace.
- Use the manual `git worktree` method below only when there is nothing else.

Use a predictable location:
- `WORKTREE_DIR=".worktrees/pr-$PR_NUMBER"`

Create the worktree pointing at the merge result branch:
- `git worktree add "$WORKTREE_DIR" "pr/$PR_NUMBER/merge"`

Fallback (if merge ref is not available):
- `git worktree add "$WORKTREE_DIR" "pr/$PR_NUMBER/head"`

Enter the workspace:
- `cd "$WORKTREE_DIR"`

Sanity check you are on the expected ref:
- `git rev-parse --abbrev-ref HEAD`
- `git log -1 --oneline`

### Cleanup after review
From the main repo root:
- `git worktree remove ".worktrees/pr-$PR_NUMBER"`
- `git branch -D "pr/$PR_NUMBER/merge" "pr/$PR_NUMBER/head"` (optional)

---

## 1) Triage the PR
- Read PR title/description + linked tickets.
- Identify: **goal**, **scope**, **risk level** (low/med/high), and any **user-facing impact**.
- List changed files and group by domain:
  - UI/screens/components
  - navigation
  - redux/reducers/selectors/epics
  - services/network/storage
  - utils/shared libs
  - tests
  - build/config

## 2) Load the right rubrics (progressive disclosure)
- Always load: output/tone + standards/TS.
- Load navigation rubric only if navigation is actually modified (see SKILL.md triggers).
- Load other rubrics based on changed file paths + diff contents.

Practical heuristic (scan the diff for keywords):
- Navigation: `useNavigation`, `useTypedNavigation`, `navigate(`, `createStackNavigator`, `screenOptions`, `Linking`
- Redux/Epics: `dispatch(`, `useTypedDispatch`, `useStoreSelector`, `ofType`, `switchMap`, `catchError`, `/epics/`
- Security/Privacy: `token`, `auth`, `SecureStore`, `Keychain`, `AsyncStorage`, `WebView`, `Linking.openURL`, `logger`
- Performance: `FlatList`, `SectionList`, `Image`, `useMemo`, `useCallback`, expensive mapping/filtering in render

## 3) Validate correctness first
- Look for broken logic, missing edge cases, inconsistent state transitions.
- Verify new/changed behavior matches the ticket.
- Ensure invariants: no crashes, no unhandled promise rejections, no infinite loops.

## 4) Review for maintainability
- Is the code easy to read in 6 months?
- Are names meaningful?
- Is logic placed in the right layer (component vs hook vs service vs redux)?
- Are we introducing coupling or unnecessary abstractions?

## 5) Performance and platform sanity
- Look for obvious rerender bombs, heavy renders, list perf pitfalls.
- iOS/Android differences: permissions, file paths, keyboard behavior, safe area, back gestures, etc.

## 6) Produce structured feedback
- Use the format in `01-output-and-tone.md`.
- Group issues by the rubric they offend.
- For each issue: state the **problem** and the **change**.
- Prefer fewer, higher-signal comments over nitpicking.

## 7) When to request changes vs approve
- Request changes for: correctness bugs, security/privacy risks, crashers, data loss, broken types/tests, memory leaks, serious perf regressions in hot paths.
- Approve with suggestions for: stylistic improvements, refactors, minor performance wins, optional architecture cleanups.
