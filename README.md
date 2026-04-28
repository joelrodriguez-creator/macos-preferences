# macOS Preferences

System preference scripts for Joel's MacBook. Idempotent — re-run after a fresh macOS install or major upgrade to restore preferred defaults.

Born out of months of irritation with macOS auto-dimming the display "for whatever reason" — Apple Support couldn't pin it down, and it turned out to be four independent dimming systems layered on top of each other. This repo encodes the fix so it never has to be re-discovered.

## Features

- **Disables battery dim on unplug** (`pmset -b lessbright 0`) — kills the dim that fires the moment the laptop unplugs from AC
- **Raises battery display-sleep timer** from 5 min to 20 min (kills the pre-dim that fires ~30 sec before display sleep)
- **Disables ambient-light auto-brightness** via `/Library/Preferences/com.apple.iokit.AmbientLightSensor.plist` — the #1 cause of unexplained dimming, especially in dark rooms at night
- **Single-prompt elevation** — uses `osascript ... with administrator privileges` so all sudo work happens in one GUI password dialog, no TTY required
- **Idempotent** — safe to re-run; setting an already-set value is a no-op

## Tech stack

| Layer | Tool |
|---|---|
| Shell | zsh |
| Privilege elevation | `osascript` GUI prompt |
| System config | `pmset`, `defaults` |

## Project structure

```
macos-preferences/
├── apply.sh        # Main script — runs all preferences in one elevated block
└── README.md
```

## Getting started

```zsh
cd "~/Code Projects/infrastructure/macos-preferences"
chmod +x apply.sh
./apply.sh
```

One macOS password dialog will appear — that's the elevation prompt for the whole sudo block. After it closes, the script prints verification commands and an empirical test.

## Verification

```zsh
pmset -g custom | grep -E 'lessbright|displaysleep'
# Expect: lessbright = 0 on Battery; displaysleep = 20 on both
defaults read /Library/Preferences/com.apple.iokit.AmbientLightSensor
# Expect: "Automatic Display Enabled" = 0
```

Empirical tests (each one tests a different dimming system):

- **Ambient light sensor**: cover the area just left of the camera in the notch for 5 sec, then uncover. Brightness should NOT change.
- **`lessbright`**: unplug the laptop. Brightness should NOT drop.
- **Display pre-dim**: stop touching the laptop on battery for 4–5 min. Brightness should NOT drop before display sleep.

## Known limitation: True Tone

The `CBTrueToneEnabled` key in `com.apple.CoreBrightness` is gated by an Apple-private entitlement on macOS 26 (Tahoe). `corebrightnessd` rejects writes from any non-Apple-signed process, even with sudo. The script attempts the write anyway (silent failure is harmless), but if you want True Tone off you must toggle it manually in **System Settings → Displays → True Tone**.

True Tone shifts color *temperature*, not brightness — it's not the cause of auto-dimming. Leaving it on is fine if all you care about is brightness staying constant.

## Tested on

- macOS 26.3.1 (Tahoe), MacBook Pro 16", April 2026

If a macOS upgrade re-introduces auto-dimming, re-run `apply.sh` first. If that doesn't fix it, Apple has likely migrated keys — capture the new state with:

```zsh
pmset -g custom
defaults read /Library/Preferences/com.apple.iokit.AmbientLightSensor
defaults -currentHost read com.apple.CoreBrightness
```

…and update `apply.sh` accordingly.
