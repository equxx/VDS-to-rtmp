#!/bin/bash
set -euo pipefail

# load env if present
if [ -f /etc/stream.env ]; then
  set -a
  source /etc/stream.env
  set +a
fi

# required vars: INPUT ve OUTPUTS (OUTPUTS = tee hedef string'i; Ã¶rn: "[f=flv]rtmp://a|[f=flv]rtmp://b")
: "${INPUT:?Need INPUT in /etc/stream.env or ./stream.env (eg: rtmp://srs:1935/live/streamkey)}"
: "${OUTPUTS:?Need OUTPUTS in /etc/stream.env (eg: \"[f=flv]rtmp://a|[f=flv]rtmp://b\")}"

TRANSCODE="${TRANSCODE:-0}"
BITRATE="${BITRATE:-2500k}"
PRESET="${PRESET:-veryfast}"
FPS="${FPS:-}"

cmd=(ffmpeg -re -i "$INPUT" -map 0)

if [ "$TRANSCODE" = "0" ]; then
  cmd+=(-c copy)
else
  # Örnek transcode: video x264 audio aac
  cmd+=(-c:v libx264 -preset "$PRESET" -b:v "$BITRATE" -c:a aac -b:a 128k)
  if [ -n "$FPS" ]; then
    cmd+=(-r "$FPS")
  fi
fi

cmd+=(-f tee "$OUTPUTS")

exec "${cmd[@]}"
