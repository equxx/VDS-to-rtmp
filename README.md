# VDS to RTMP

Bu proje, Docker üzerinde SRS ve FFmpeg kullanarak tek bir giriş yayınını birden fazla RTMP hedefine iletir ve HLS yayını sunar.

## Gereksinimler

- Docker ve Docker Compose
- Erişilebilir bir giriş yayın adresi ve RTMP/RTMPS hedef adresleri

## Yayın ayarları

`stream.env` dosyasına giriş ve hedef yayın adreslerinizi ekleyin. `OUTPUTS`, FFmpeg `tee` biçiminde `|` ile ayrılmış hedeflerden oluşur. Yayın adresleri ve anahtarları gizli bilgidir; bu dosyayı herkese açık depolarda paylaşmayın.

- `INPUT`: Giriş yayın adresi.
- `OUTPUTS`: `|` ile ayrılmış RTMP hedefleri.
- `TRANSCODE=0`: Akışı yeniden kodlamadan iletir.
- `TRANSCODE=1`: Akışı H.264/AAC biçiminde yeniden kodlar.
- `BITRATE`: Yeniden kodlama sırasında kullanılacak video bit hızı.

## Başlatma

```bash
docker compose up -d
```

RTMP girişi 1935, HLS ve HTTP 8080 numaralı portları kullanır. SRS API'si 1985 numaralı portu kullanır. Güvenlik duvarınızda yalnızca gerekli portları açın.

Günlükleri izlemek için:

```bash
docker compose logs -f ffmpeg
docker compose logs -f srs
```

Projeyi durdurmak için:

```bash
docker compose down
```
