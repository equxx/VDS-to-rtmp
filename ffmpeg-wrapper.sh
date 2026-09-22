#!/bin/bash
set -euo pipefail

# Ayar dosyası varsa ortam değişkenlerini yükle.
if [ -f /etc/stream.env ]; then
  set -a
  source /etc/stream.env
  set +a
fi

# Gerekli değişkenler: INPUT ve OUTPUTS. OUTPUTS, | ile ayrılmış tee hedefleridir.
: "${INPUT:?INPUT değişkenini stream.env dosyasında belirtin (örnek: rtmp://srs:1935/live/yayin-anahtari)}"
: "${OUTPUTS:?OUTPUTS değişkenini stream.env dosyasında belirtin (örnek: [f=flv]rtmp://hedef/yayin)}"

TRANSCODE="${TRANSCODE:-0}"
BITRATE="${BITRATE:-2500k}"
# Anahtar kare aralığını, ayarlanan kare hızında iki saniye olarak belirle.
FPS="${FPS:-60}"
GOP=$((FPS * 2))
PRESET="${PRESET:-veryfast}"

if [ "$TRANSCODE" = "0" ]; then
  exec ffmpeg -re -i "$INPUT" -map 0 -c copy -f tee "$OUTPUTS"
else
  # NVIDIA GPU bulunmayan sunucularda yazılımsal H.264 kodlaması kullan.
  exec ffmpeg -re -i "$INPUT" \
    -map 0:v:0 -map '0:a?' \
    -c:v libx264 -preset "$PRESET" -tune zerolatency \
    -b:v "$BITRATE" -maxrate "$BITRATE" -bufsize "$(( ${BITRATE%k} * 2 ))k" \
    -r "$FPS" -g "$GOP" \
    -c:a aac -b:a 128k \
    -f tee "$OUTPUTS"
fi
