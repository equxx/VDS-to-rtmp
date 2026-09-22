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
# Keyframe interval is 2 seconds at the configured output FPS.
FPS="${FPS:-60}"
GOP=$((FPS * 2))
PRESET="${PRESET:-veryfast}"

if [ "$TRANSCODE" = "0" ]; then
  exec ffmpeg -re -i "$INPUT" -map 0 -c copy -f tee "$OUTPUTS"
else
  # Software H.264 encoding for hosts without an NVIDIA GPU.
  exec ffmpeg -re -i "$INPUT" \
    -map 0:v:0 -map '0:a?' \
    -c:v libx264 -preset "$PRESET" -tune zerolatency \
    -b:v "$BITRATE" -maxrate "$BITRATE" -bufsize "$(( ${BITRATE%k} * 2 ))k" \
    -r "$FPS" -g "$GOP" \
    -c:a aac -b:a 128k \
    -f tee "$OUTPUTS"
fi
