# Kablo Kaşifi 🔌🔍

Mac'ine taktığın USB-C kablosunun **gerçekte ne yapabildiğini** düz Türkçe anlatan
menü çubuğu uygulaması. Aynı görünen iki kablodan biri 40 Gb/s veri + 100 W güç
taşırken diğeri sadece şarj edebilir — bu uygulama hangisinin elinde olduğunu söyler.

Apple Silicon (macOS 14+) için yazıldı.

![Kablo Kaşifi paneli](docs/panel.png)

## Ne söyler

**Portlar** — Thunderbolt/USB4 portlarının durumu; bağlı aygıt varsa anlaşılan hız.
40 Gb/s'in altında bir bağlantı varsa uyarır: pasif ya da düşük hızlı kablo.

**Güç** — Adaptörün etiket gücü (ör. 35 W) ile fiilen anlaşılan gücü (V × A)
karşılaştırır:

- Tam güç geliyorsa: *"35 W adaptör tam güçte veriyor. Kablo bu gücü taşıyabiliyor."*
- Düşükse ve pil doluysa: *"Pil %92 olduğu için Mac az güç istiyor; bu normal."*
- Düşükse ve pil boşsa: *"Adaptör 67 W ama yalnızca 28 W geliyor. Kablo düşük güçlü
  (60 W sınırlı) olabilir ya da tam oturmamış olabilir."*

Ayrıca pil yüzdesi, azami kapasite ve döngü sayısı.

**Bağlı aygıtlar** — Her USB aygıtının gerçek bağlantı hızı ve ne anlama geldiği.
Örneğin harici SSD 480 Mb/s'de bağlıysa: *"Kablon büyük ihtimalle sadece şarj/USB 2.0
kablosu — veri kablosuyla 10 kat hızlanır."*

**Ekranlar** — Harici ekran varsa kablonun video taşıdığını ve hangi çözünürlük/tazeleme
hızında çalıştığını gösterir.

Panel açıkken 4 saniyede bir kendini yeniler; yeni takılan aygıtlar **YENİ** rozetiyle
işaretlenir. Menü çubuğunda şarj varken watt değeri görünür.

## Kurulum

```bash
./build.sh --install --run
```

Derler, `Kablo Kaşifi.app` paketini üretir, `/Applications` içine kopyalar ve çalıştırır.
Herhangi bir özel izin gerekmez.

Terminalden hızlı bakış:

```bash
"/Applications/Kablo Kaşifi.app/Contents/MacOS/KabloKasifi" --print
```

## Nasıl çalışıyor

- `system_profiler -json SPUSBDataType SPThunderboltDataType SPPowerDataType SPDisplaysDataType`
  çıktısını okur (aygıt hızları, receptacle durumları, ekranlar, pil).
- Güç adaptörünün anlaşılan voltaj/akım değerlerini IOKit'ten alır
  (`IOPSCopyExternalPowerAdapterDetails`), böylece "etikette 67 W yazıyor ama 28 W
  geliyor" farkını yakalar.
- Ham değerleri tek cümlelik Türkçe yorumlara çevirir — asıl iş burada.

Hiçbir veri dışarı gönderilmez; seri numaraları arayüzde gösterilmez.

## Proje yapısı

```
Package.swift                      SwiftPM tanımı (SwiftUI + AppKit, macOS 14+)
build.sh                           Derleme, .app paketleme, ad-hoc imzalama, kurulum
Resources/Info.plist               Paket bilgileri (LSUIElement)
Scripts/makeicon.swift             Simgeyi kodla çizer (1024px → .icns)
Sources/KabloKasifi/
  App/KabloKasifiApp.swift         MenuBarExtra sahnesi
  App/AppDelegate.swift            --print ve --render bayrakları
  Core/SystemProbe.swift           Veri toplama + Türkçe yorum motoru
  Core/ProbeStore.swift            Durum, canlı yenileme, yeni aygıt algılama
  Models/Connection.swift          Satır ve yorum modelleri
  Views/PanelView.swift            Menü çubuğu paneli
  Views/RenderPreview.swift        Paneli PNG'ye çizen geliştirme yardımcısı
```

### Geliştirme

```bash
swift build -c release
./.build/release/KabloKasifi --print               # terminalde özet
./.build/release/KabloKasifi --render /tmp/p.png   # paneli PNG olarak çiz
```

---

## In English

**Kablo Kaşifi** ("Cable Explorer") is a macOS menu bar app that tells you, in plain
language, what the USB-C cable you just plugged in can actually do: negotiated link
speed per device, whether a cable is limiting charging power (label watts vs. the
volts × amps actually negotiated, with the "battery is nearly full" case handled
separately), whether video is flowing, and the state of each Thunderbolt/USB4 port.
It reads `system_profiler` plus IOKit power-adapter details and turns them into
one-sentence verdicts. Turkish UI, no special permissions, nothing leaves your Mac.

Build with `./build.sh --install --run` (needs Xcode or Command Line Tools, macOS 14+).

MIT lisanslı.
