# VDS-to-rtmp

Docker tabanlı bu proje, bir VDS üzerinde **SRS (Simple Realtime Server)** ve **FFmpeg** kullanarak tek bir giriş akışını aynı anda birden fazla RTMP hedefine iletir. SRS HLS çıktısı da üretir, böylece web üzerinden izlenebilir.
RTMPS Çıkışını denedim ama sürekli hatalarla karşılaştım, olmadı. Türkçe konu açarak bana yardımcı olabilirsiniz.

## İçindekiler
- [Özellikler](#özellikler)
- [Gereksinimler](#gereksinimler)
- [Kurulum](#kurulum)
- [Akış ayarlarını yapılandırma](#akış-ayarlarını-yapılandırma)
- [Çalıştırma](#çalıştırma)
- [Faydalı adresler](#faydalı-adresler)
- [Sorun giderme](#sorun-giderme)

## Özellikler
- SRS ile 1935 (RTMP), 1985 (API) ve 8080 (HTTP/HLS) portlarını açar.
- FFmpeg ile tek giriş akışını `tee` formatı sayesinde birden fazla RTMP/RTMPS hedefine çoğaltır.
- İsteğe bağlı transcode: kopyala (varsayılan) veya x264 + AAC ile yeniden kodla.
- Çevresel değişken dosyasıyla (shell uyumlu) kolay yapılandırma.

## Gereksinimler
- Docker ve Docker Compose yüklü olmalı.
- Yayın giriş URL'lerinize ve hedef RTMP adreslerinize ihtiyaç var.

## Kurulum
1. Depoyu VDS'inize klonlayın veya dosyaları `/root/canli-yayin` dizinine yerleştirin (betikler buna göre ayarlanmıştır).
2. İzinler:
   ```bash
   chmod +x ffmpeg-wrapper.sh
   ```

## Akış ayarlarını yapılandırma
`stream.env` dosyası shell uyumlu `KEY="value"` formatındadır ve FFmpeg konteyneri tarafından yüklenir.

Örnek alanlar:
- `INPUT`: SRS'den veya başka bir kaynaktan aldığınız giriş akışı (`rtmp://srs:1935/live/stream` gibi).
- `OUTPUT_1..N`: Her biri `tee` formatıyla başlayan hedefler (ör: `[f=flv]rtmp://...`).
- `OUTPUTS`: Tek tek `OUTPUT_*` değerlerini `|` ile birleştirir ve betik bunu kullanır.
- `TRANSCODE`: `0` ise kopyala; `1` ise belirtilen `BITRATE` ile x264/AAC transcode yapar.

Değişikliklerin konteyner tarafından görülebilmesi için dosya aynı dizinde kalmalıdır; Docker Compose, `/etc/stream.env` olarak bağlar.

## Çalıştırma
Projeyi başlatmak için:
```bash
docker compose up -d
```
- `srs` servisi otomatik olarak RTMP ve HLS sunar.
- `ffmpeg` servisi `ffmpeg-wrapper.sh` giriş noktasını kullanarak akışı çoğaltır veya gerekiyorsa transcode eder.

Günlükleri görmek için:
```bash
docker compose logs -f
```
FFmpeg veya SRS özel servis günlükleri için:
```bash
docker compose logs -f ffmpeg
# veya
 docker compose logs -f srs
```

## Faydalı adresler
- RTMP giriş: `rtmp://<sunucu-ip>:1935/live/<stream-key>`
- HLS oynatma (SRS varsayılan vhost): `http://<sunucu-ip>:8080/live/<stream-key>.m3u8`

## Sorun giderme
- **Giriş akışı gelmiyor**: `INPUT` değerinin doğru ve erişilebilir olduğundan emin olun. SRS'e push ediyorsanız port 1935 açık olmalı.
- **Çoklu hedeflerden biri başarısız**: `OUTPUTS` içinde ilgili RTMP URL'lerini ve kimlik bilgilerini kontrol edin. Yanlış URL tüm `tee` komutunu durdurabilir.
- **Performans sorunları**: `TRANSCODE=0` kopyalama modunu kullanın veya `BITRATE`/`PRESET` değerlerini düşürün.
