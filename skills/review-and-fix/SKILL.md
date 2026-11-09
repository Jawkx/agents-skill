---
name: review-and-fix
description: Loop a separate reviewer agent over your change and fix what it finds until you both agree. Use when the user says "review and fix" or asks for a review loop on a change.
license: MIT (see LICENSE)
metadata:
  source: https://github.com/t3dotgg/tstack
  adapted-from: sol-loop
  upstream-commit: 1085050f3baed1ac724caa4a8166145fb2ac88af
---

# Review and fix

Get a second agent to review your change, fix the real findings, and repeat
until the reviewer approves or you hit the budget. Use it before filing a PR,
or after, to tighten one.

Make the smallest changes that answer the reviewer. Watch for scope creep and
push back when a finding is wrong.

## The reviewer

The reviewer is a separate agent. You start it with whatever your harness has:
a subagent, a delegated task, another session. This skill does not care which.

- If the user named a model, provider, or agent, use that. If you cannot run
  it, say so and stop. Do not swap in another one.
- Otherwise use your harness's usual way to start a reviewer.
- The reviewer gets no history from you. Everything it needs goes in the brief.
- Use one reviewer. It must not start its own subagents or reviewers.
- If you cannot start a separate agent at all, report that. Reviewing your own
  work does not count as this loop.

Record which model or agent reviewed, and its effort and usage if your harness
shows them. Never guess them.

## Budget

- Default: 3 rounds. Round 1 reviews the whole change. Later rounds check only
  changed code and open findings.
- Go up to 5 only when the user asks, or when a blocker or should finding
  with evidence stays open in security, permissions, auth, data loss, or
  state and concurrency.
- Stop early if a round returns only nits. Declined nits and fixes to
  comments, docs, or formatting need no new round.
- Keep a ledger with one row per finding: id, severity, outcome.

## 1. Scope

Run `git status --short`. Do not stash, discard, or include unrelated
changes. Limit the review to the change's paths if they separate cleanly.
Otherwise stop and ask.

Run `git fetch origin`, then find the base:

- PR: `gh pr view <n> --json baseRefName,headRefOid`. Check out the branch
  only if the working tree is clean. Confirm `HEAD` is the PR head, or ahead
  of it only by this change. Base is `git merge-base HEAD origin/<baseRefName>`.
- Local branch: `git merge-base HEAD origin/<default-branch>`.
- No remote: a base the user names, or `HEAD` when only uncommitted changes
  are in scope.

The change runs from the base to the working tree in those paths, untracked
files included. Use the same diff command every round. Write the intent and
what is out of scope in one or two sentences.

Run the checks that cover the change. Do not send the reviewer code that this
change breaks. Note missing or already failing checks in the brief.

## 2. Start the reviewer

Do not edit files in scope while the review runs. Wait for the reply. Do not
start a second reviewer. A timeout, an error, or no reply is not approval. If
the reviewer fails, stop it, make sure it stopped, and restart it with the
ledger.

Round 1 brief:

```
Review only. Do not edit, commit, push, comment on PRs, or start subagents.
Repo: <abs path> Base: <sha> Intent: <intent> Out of scope: <scope> Checks: <results>
See: git diff <base> [-- <paths>]; git status --short (read untracked files).
Read the surrounding code. Find bugs, broken callers, and mismatches with the intent.
Skip style unless it hides a bug. Hold the change to the smallest version that works.
Flag code, tests, or guards the intent does not need. Other paths, rare cases,
small perf costs, and extra compatibility are nits.
blocker = the intended case is wrong. should = a real bug callers will hit, within the intent. nit = everything else.
Reply:
VERDICT: APPROVE or CHANGES
R1 [blocker|should|nit] <file>:<line> <claim>. Fix: <suggestion> (keep ids stable across rounds)
```

## 3. Answer findings

Check each finding and its severity yourself. Another path, a rare case, or a
small cost is a nit, whatever label it came with.

- Agree: make the smallest fix. Prefer deleting or narrowing code over adding
  a lock, cache, helper, or option. Fix the case that happened. Add one focused
  test that fails without the fix, if the intent needs it.
- Disagree: say why, with evidence (file:line, a test, command output).
- Out of scope or nit: decline in one line and list it as a follow-up.

Update the ledger. Re-run the checks and `git diff --shortstat <base>`. If the
review grew the diff, cut it back first. Do not agree just to end the loop.

## 4. Next round

Start another round only if budget remains and one of these holds: a blocker or
should is open, behavior code changed, or the last approval does not cover the
current diff.

Continue the same reviewer if your harness can. Otherwise start a fresh one.
Either way, send the round 1 brief, the ledger (`fixed:` / `disagree:` /
`declined:` with evidence), the same base diff, and what changed since the last
round. Tell the reviewer to look only at open ids and changed code, and to mark
each old id `resolved` or `still open: <reason>`.

## 5. Stop and ship

You agree when the reviewer approves the current diff, no blocker or should is
open, and you have no concern of your own.

You are stuck when one finding stays disputed after two replies, or the budget
runs out. Give both sides in two or three lines each and let the user decide.
Running out of budget is not approval.

Do not push during the loop. After you agree, push only if the user asked you
to push, ship, or update the PR. If you push to a PR, add this line to the
description:

`Reviewed with review-and-fix: <N> rounds with <reviewer>. Verdict: approved.`

Final report: rounds, reviewer (model and effort if known), what the review
changed, diff size before and after, fixed and declined findings with reasons,
usage if your harness showed it (otherwise say it did not), and whether you
pushed.
