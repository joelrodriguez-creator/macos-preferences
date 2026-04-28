# NEXT_SESSION.md

_Last checkpoint: 2026-04-28 14:58 on Joel's MacBook Pro_

## TL;DR

New repo created today to encode the macOS auto-dim fix that took months of irritation to track down. Apply script is idempotent — re-run after any macOS install or major upgrade. Three of four dimming systems are killed via CLI (`pmset -b lessbright`, `pmset -b displaysleep`, `AmbientLightSensor.plist`). The fourth (True Tone) is gated by an Apple-private entitlement on Tahoe and can't be scripted; it's documented as a known limitation. Repo is intentionally sparse — designed to grow as more macOS tweaks accumulate.

## First actions on the other machine

### macOS (MacBook)

```zsh
cd "$HOME/Code Projects/infrastructure/macos-preferences"
git pull origin main
./apply.sh   # only if you've reinstalled macOS or settings drifted
```

### Windows (FalconXtreme)

This repo is Mac-only — `pmset` and `defaults` don't exist on Windows. Skip cloning unless you want to read it for reference:

```powershell
# Reference clone only (no equivalent functionality on Windows):
cd "E:\Code Projects\infrastructure"
git clone https://github.com/joelrodriguez-creator/macos-preferences.git
```

## Recreate local-only files

None. The repo has no secrets, no `.env`, no credentials. `apply.sh` only writes to system preferences via `pmset` and `defaults`.

## What's done (this session)

- `1365396` — Initial commit: macOS preferences automation
- `cc5fc84` — Checkpoint: add NEXT_SESSION.md handoff doc

## What's pending (in priority order)

There's no urgent work. Repo is in a "ready to grow" state. Candidate next additions, in rough order of friction-reduction value:

1. **Finder defaults** — show hidden files (`AppleShowAllFiles`), show file extensions (`AppleShowAllExtensions`), default to list view, etc.
2. **Screenshot location override** — `defaults write com.apple.screencapture location ~/Pictures/Screenshots`
3. **Dock auto-hide + delay** — `defaults write com.apple.dock autohide -bool true; autohide-delay -float 0`
4. **Key repeat speed** — `defaults write NSGlobalDomain KeyRepeat -int 2; InitialKeyRepeat -int 15`
5. **Disable shake-to-locate-cursor** if it ever annoys you
6. **Disable smart quotes / autocorrect in text fields** (`NSAutomaticQuoteSubstitutionEnabled`, etc.)

Each one is a 1–2 line `defaults` command that gets appended to `apply.sh` and re-run.

## Prompt to paste into next Claude Code session

```text
I'm resuming work on macos-preferences. Read NEXT_SESSION.md at the repo root for full context. The auto-dim fix is shipped and working. Next action: append a new macOS tweak to apply.sh — see the pending list for ideas, or I'll tell you which one I want.
```

## Hard rules for this project

- **Idempotent always.** Every command in `apply.sh` must be safe to re-run. No "already exists" failures, no destructive operations.
- **Single password prompt.** All sudo work goes inside the existing `osascript ... with administrator privileges` block, not as separate `sudo` calls. One prompt for the whole script.
- **Best-effort for entitlement-gated keys.** If a `defaults write` fails on Tahoe due to corebrightnessd or similar daemon-side rejection, swallow the error (`|| true`) and document it under "Known limitations" in the README. Don't fight Apple.
- **No secrets.** This repo writes system preferences only. If a future tweak needs an API key, it doesn't belong here — make a separate repo.
- **Mac-only.** Don't add Windows-equivalent scripts. The PC has its own preference workflow.
