#!/bin/bash
# Waits for the TV, installs the current build, optionally verifies by
# triggering the screensaver and pulling a screenshot.
#   ./deploy.sh           install only
#   ./deploy.sh --verify  install + trigger dream + screenshot to tv-phase2.png
set -u
cd "$(dirname "$0")"
TV="192.168.1.172:5555"
APK="build/skylight.apk"

echo "waiting for TV at $TV ..."
online=""
for i in $(seq 1 30); do
  adb connect "$TV" > /dev/null 2>&1
  if adb devices | grep "$TV" | grep -q "device$"; then
    online=yes
    echo "TV online after ~$((i*10))s"
    break
  fi
  sleep 10
done
if [ -z "$online" ]; then
  echo "TV_STILL_OFF after 5 minutes"
  exit 2
fi

adb install -r "$APK" 2>&1 | tail -1

if [ "${1:-}" != "--verify" ]; then
  echo "installed (no verify)"
  exit 0
fi

adb shell settings put system screen_off_timeout 30000
echo "waiting for idle dream (hands off the remote) ..."
active=""
for i in $(seq 1 25); do
  d=$(adb shell dumpsys dreams 2>/dev/null | grep -m1 "mCurrentDream=" | tr -d ' \r')
  if [ -n "$d" ] && [ "$d" != "mCurrentDream=null" ]; then
    active=yes
    echo "dream active after ~$((i*6))s"
    break
  fi
  sleep 6
done
sleep 8
adb shell screencap -p /sdcard/skylight2.png \
  && adb pull /sdcard/skylight2.png tv-phase2.png > /dev/null 2>&1
adb shell settings put system screen_off_timeout 600000
echo "timeout restored to 10min"
if [ -z "$active" ]; then
  echo "dream never started (remote in use?)"
  exit 3
fi
ls -la tv-phase2.png
