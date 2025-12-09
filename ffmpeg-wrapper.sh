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
# run appropriate ffmpeg command
if [ "$TRANSCODE" = "0" ] ; then
  exec ffmpeg -re -i "$INPUT" -map 0 -c copy -f tee "$OUTPUTS"
else
  # Örnek transcode: video x264 audio aac
  exec ffmpeg -re -i "$INPUT" -map 0 -c:v libx264 -preset veryfast -b:v "$BITRATE" -c:a aac -b:a 128k -f tee "$OUTPUTS"
fi
