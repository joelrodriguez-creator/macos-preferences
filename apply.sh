#!/usr/bin/env zsh
# macOS Preferences — Joel Rodriguez
# Idempotent. Run after a fresh macOS install or major upgrade.
# Single GUI password prompt for the whole elevated block.

set -e

echo "Applying macOS preferences..."

# All sudo work in one elevated block. osascript pops a native macOS password
# dialog so the script doesn't need a TTY. Any new sudo-required tweak should
# be appended to the shell-script string below to keep it to one prompt.
osascript -e 'do shell script "pmset -b lessbright 0 && pmset -b displaysleep 20 && defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor \"Automatic Display Enabled\" -bool false ; killall cfprefsd 2>/dev/null || true ; echo elevated-changes-applied" with administrator privileges'

# User-level (no sudo). Best-effort — corebrightnessd rejects this on Tahoe due
# to entitlement check, but the write is harmless and may stick on older macOS.
defaults -currentHost write com.apple.CoreBrightness CBTrueToneEnabled -bool false 2>/dev/null || true

echo ""
echo "Done. Verify:"
echo "  pmset -g custom | grep -E 'lessbright|displaysleep'"
echo "  defaults read /Library/Preferences/com.apple.iokit.AmbientLightSensor"
echo ""
echo "Empirical test: cover the ambient-light sensor (left of the camera in"
echo "the notch) for 5 sec. If brightness flickers, auto-brightness is still"
echo "on — toggle it manually in System Settings → Displays → 'Automatically"
echo "adjust brightness'."
