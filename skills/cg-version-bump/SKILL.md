---
name: cg-version-bump
description: Automate CoinGecko mobile release version bumps. Use when user asks to create a release branch from main, bump app version using script/cli/versionBump.js, commit version files, and open a draft GitHub PR to main.
---

# CG Version Bump

## Workflow

1. Confirm target version and branch name.
- Default branch format: `<target-version>-branch` (example: `3.43.1-branch`).
- Use the exact version requested by the user.

2. Run preflight checks.
- Run `git branch --show-current` and `git status --short`.
- Ensure the working tree is clean or contains only intended version-bump changes.
- Switch to `main` before creating the release branch.

3. Create the branch from `main`.
- `git checkout main`
- `git pull --ff-only origin main`
- `git checkout -b <target-version>-branch`

4. Run the version bump via the existing CLI.
- Explicit target version: `VERSION=<target-version> yarn versionbump --skip-build`
- Patch bump from current version: `yarn versionbump --skip-build`
- Always pass `--skip-build` to keep Android/iOS build numbers unchanged.

5. Handle known non-blocking CLI error.
- If `react-native-version` ends with `fatal: no tag exactly matches ...`, inspect file changes.
- Continue when all expected version files are updated correctly.

6. Verify file updates.
- Expect changes in:
  - `README.md`
  - `package.json`
  - `android/app/build.gradle`
  - `ios/CoinGecko/Info.plist`
  - `ios/CoinGeckoKit/Info.plist`
  - `ios/CoinGeckoKitTests/Info.plist`
  - `ios/CoinGecko Widget Extension/Info.plist`
  - `ios/CoinTickerIntentHandler/Info.plist`
- Confirm the target version string is updated and build numbers are unchanged.

7. Commit the bump.
- Stage only version-bump files.
- Use commit message: `build: bump version to <target-version>`.
- If commit workflow constraints exist, follow them before running `git commit`.

8. Push and open a draft PR to `main`.
- `git push -u origin <target-version>-branch`
- `gh pr create --base main --head <target-version>-branch --draft --title "build: bump version to <target-version>" --body "<release summary>"`

9. Report completion.
- Return branch name, commit SHA, and PR URL.
- Mention non-blocking warnings encountered during bump.
