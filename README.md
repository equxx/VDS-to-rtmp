# VDS to RTMP

Version: **2.0.0**

Docker Compose project that receives one input stream, forwards it to multiple RTMP destinations with FFmpeg, and serves HLS through SRS. This copy contains no live stream URLs or keys.

## Requirements

- Docker Engine and Docker Compose plugin
- A reachable input stream URL and RTMP/RTMPS destination URLs

## Configure

1. Copy `stream.env.example` to `stream.env`.
2. Edit `INPUT` and `OUTPUTS` with your own stream URLs and keys. `OUTPUTS` is a pipe-separated FFmpeg tee list; quote the complete value.
3. Keep `stream.env` private. It is ignored by this package and should not be committed or shared.

`TRANSCODE=0` copies the incoming audio/video streams. Set it to `1` to encode H.264/AAC. `FPS`, `BITRATE`, and `PRESET` tune encoding.

## Start

```sh
cp stream.env.example stream.env
# Edit stream.env with your own URLs and keys, then:
docker compose up -d --build
```

RTMP ingest is exposed on port 1935. SRS HTTP/HLS is on port 8080; its API is bound to localhost on port 1985. Make sure your firewall only exposes the ports you intend to use.

View logs with `docker compose logs -f ffmpeg` or `docker compose logs -f srs`. Stop with `docker compose down`.
