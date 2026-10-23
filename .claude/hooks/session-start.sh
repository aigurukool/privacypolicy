#!/bin/bash
# Installs the video editing toolchain (FFmpeg, yt-dlp, HyperFrames + headless Chrome) in cloud sessions.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

command -v ffmpeg >/dev/null || (apt-get update -qq && apt-get install -y -qq ffmpeg)
command -v yt-dlp >/dev/null || pip install -q --break-system-packages yt-dlp 2>/dev/null || pip install -q yt-dlp
command -v hyperframes >/dev/null || npm install -g --silent hyperframes@0.8.186
hyperframes browser ensure >/dev/null
