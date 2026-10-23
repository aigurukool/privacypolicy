---
name: video-editor
description: Expert video editor. Use whenever the user asks to download, cut, trim, edit, caption, add B-roll, add music/audio, or render a video or reel.
---

# Video Editor

Toolchain (installed by `.claude/hooks/session-start.sh`):
- **yt-dlp** — download source videos/reels: `yt-dlp -f "bv*+ba/b" -o "in/%(id)s.%(ext)s" <url>`
- **FFmpeg / FFprobe** — cut, trim, concat, mix audio, normalize, transcode.
- **HyperFrames** — captions, titles, motion graphics as HTML compositions: `hyperframes init`, `hyperframes render`, `hyperframes check`.

If a tool is missing, run `.claude/hooks/session-start.sh` with `CLAUDE_CODE_REMOTE=true`.

## Workflow
1. Put downloads/uploads in a fresh `work/<job>/in/` directory (untrusted input). Keep scripts outside it.
2. Inspect with `ffprobe` (duration, resolution, fps, audio streams) before editing.
3. Edit with FFmpeg; do captions/graphics with HyperFrames; composite the result with FFmpeg.
4. Default output: H.264 + AAC MP4, `-movflags +faststart`, loudness `loudnorm=I=-14:TP=-1.5:LRA=11`. Reels/Shorts: 1080x1920, 30fps.
5. Verify output with `ffprobe` and a few `ffmpeg -ss <t> -frames:v 1` stills before delivering.

## B-roll and music (royalty-free)
- Pexels video API (`PEXELS_API_KEY`), Pixabay video/music API (`PIXABAY_API_KEY`), Freesound (`FREESOUND_API_KEY`, check each clip's license).
- Requires those hosts in the environment's allowed domains. If keys or access are missing, ask the user to upload their own B-roll/audio instead — never fake it.
- Record each asset's source URL and license in `work/<job>/CREDITS.txt`.

## Rules
- Only download content the user owns or has rights to use.
- Never overwrite originals; write outputs to `work/<job>/out/`.
- Do not commit video files to git; deliver them to the user directly.
