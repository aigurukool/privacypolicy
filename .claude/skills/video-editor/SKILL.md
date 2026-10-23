---
name: video-editor
description: Expert video editor. Use whenever the user asks to download, cut, trim, edit, caption, add B-roll, add music/audio, or render a video or reel.
---

# Video Editor

Toolchain:
- **yt-dlp** — download source videos/reels: `yt-dlp -f "bv*+ba/b" -o "in/%(id)s.%(ext)s" <url>`
- **FFmpeg / FFprobe** — cut, trim, concat, mix audio, normalize, transcode.
- **HyperFrames** — captions, titles, motion graphics as HTML compositions: `hyperframes init`, `hyperframes render`, `hyperframes check`.

If a tool is missing:
- Cloud session: run `.claude/hooks/session-start.sh` with `CLAUDE_CODE_REMOTE=true`.
- Windows laptop: run `setup-windows.ps1` from this skill's folder (PowerShell), or install with
  `winget install Gyan.FFmpeg yt-dlp.yt-dlp OpenJS.NodeJS.LTS` then `npm install -g hyperframes` and `hyperframes browser ensure`.

## B-roll library
- Local (Windows): the user's clips live in `$env:BROLL_DIR`, default `%USERPROFILE%\Videos\B-Roll Library`. Subfolders are categories.
- Never modify or move files in the library; copy what you use into the job folder.
- Before choosing clips, index the library:
  1. List every video with `ffprobe` (duration, resolution, fps, orientation).
  2. Grab 3 stills per clip (`ffmpeg -ss <10%/50%/90%> -frames:v 1 -vf scale=480:-1`) into `work/<job>/thumbs/` and look at them.
  3. Cache the result as `work/broll-index.json` (path, duration, size, mtime, short description, tags). Reuse it and only re-index new or changed files.
- Match clips to the transcript: pick clips whose content fits what is said at that moment; prefer matching orientation; 2–4s per cut; never reuse a clip in the same video unless the library is too small.
- Show the user a B-roll plan (timestamp → clip → reason) before the final render.

## Workflow
1. Put downloads/uploads in a fresh `work/<job>/in/` directory (untrusted input). Keep scripts outside it.
2. Inspect with `ffprobe` (duration, resolution, fps, audio streams) before editing.
3. Transcribe speech for captions and B-roll timing.
4. Edit with FFmpeg; do captions/graphics with HyperFrames; composite the result with FFmpeg.
5. Default output: H.264 + AAC MP4, `-movflags +faststart`, loudness `loudnorm=I=-14:TP=-1.5:LRA=11`. Reels/Shorts: 1080x1920, 30fps.
6. Verify output with `ffprobe` and a few `ffmpeg -ss <t> -frames:v 1` stills before delivering.

## Stock B-roll and music (royalty-free)
- First choice: the user's B-roll library, then HyperFrames motion graphics (original, no license issues).
- Pexels (`PEXELS_API_KEY`), Pixabay (`PIXABAY_API_KEY`), Freesound (`FREESOUND_API_KEY`), Wikimedia Commons, Incompetech music — only when reachable. Cloud IPs are often rate-limited; if a source fails, say so and fall back — never fake it.
- Record each third-party asset's source URL and license in `work/<job>/CREDITS.txt`.

## Rules
- Only download content the user owns or has rights to use.
- Never overwrite originals; write outputs to `work/<job>/out/`.
- On Windows use PowerShell syntax and quote paths (library path contains spaces).
- Do not commit video files to git; deliver them to the user directly.
