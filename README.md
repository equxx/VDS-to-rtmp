# VDS to RTMP

Docker tabanlı bu proje, bir VDS üzerinde SRS ve FFmpeg kullanarak tek bir giriş yayınını birden fazla RTMP hedefine iletir ve HLS çıktısı sunar.

## İçindekiler

- [Özellikler](#özellikler)
- [Gereksinimler](#gereksinimler)
- [Kurulum](#kurulum)
- [Yayın ayarları](#yayın-ayarları)
- [Çalıştırma](#çalıştırma)
- [Adresler](#adresler)
- [Sorun giderme](#sorun-giderme)

## Özellikler

- SRS, RTMP yayını ve HLS çıktısı sağlar.
- FFmpeg, tek bir giriş yayınını `tee` biçimiyle birden fazla RTMP hedefine iletir.
- İsteğe bağlı yeniden kodlama, x264 ve AAC kullanır.
- Yayın ayarları `stream.env` dosyasından yüklenir.

## Gereksinimler

- Docker Engine ve Docker Compose eklentisi
- Erişilebilir bir giriş yayın adresi ve RTMP/RTMPS hedef adresleri

## Kurulum

Projeyi VDS üzerine kopyalayın veya GitHub deposunu klonlayın. `stream.env.example` dosyasını `stream.env` adıyla kopyalayın ve yayın adreslerinizi bu yerel dosyaya girin. `stream.env` özel bilgi içerebilir; GitHub'a yüklemeyin veya başkalarıyla paylaşmayın.

## Yayın ayarları

`stream.env` dosyası kabuk tarafından okunabilen `KEY="value"` biçimindedir.

- `INPUT`: Giriş yayın adresi. Örneğin kendi SRS sunucunuz için `rtmp://srs:1935/live/streamkey`.
- `OUTPUT_1`, `OUTPUT_2` ve devamı: `[f=flv]` biçiminde hedef yayın adresleri.
- `OUTPUTS`: Hedefleri `|` karakteriyle birleştiren FFmpeg `tee` listesi.
- `TRANSCODE=0`: Akışı yeniden kodlamadan iletir.
- `TRANSCODE=1`: Akışı H.264/AAC biçiminde yeniden kodlar.
- `BITRATE`: Yeniden kodlama sırasında kullanılacak video bit hızı.
- `FPS` ve `PRESET`: Yeniden kodlama kare hızı ve x264 ön ayarı.

Yayın adresleri ve anahtarlarınızı yalnızca `stream.env` içine yazın. Bu dosya Git tarafından yok sayılır.

## Çalıştırma

```bash
docker compose up -d --build
```

Günlükleri izlemek için:

```bash
docker compose logs -f ffmpeg
docker compose logs -f srs
```

Projeyi durdurmak için:

```bash
docker compose down
```

## Adresler

- RTMP girişi: `rtmp://<sunucu-ip>:1935/live/<yayın-anahtarı>`
- HLS oynatma: `http://<sunucu-ip>:8080/live/<yayın-anahtarı>.m3u8`
- SRS API'si 1985 numaralı portu kullanır ve Compose ayarında yalnızca yerel makineye bağlanır.

Sunucunun güvenlik duvarında yalnızca kullanmanız gereken portları açın.

## Sorun giderme

- **Giriş yayını gelmiyor:** `INPUT` adresinin doğru ve erişilebilir olduğunu, gerekiyorsa 1935 numaralı portun açık olduğunu kontrol edin.
- **Hedeflerden biri çalışmıyor:** `OUTPUTS` içindeki adresleri ve yayın anahtarlarını kontrol edin. Hedef hataları FFmpeg `tee` yayınını durdurabilir.
- **Performans sorunu yaşanıyor:** `TRANSCODE=0` ile yeniden kodlamayı kapatın veya `BITRATE` ve `PRESET` değerlerini düşürün.
