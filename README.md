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

## Diller

🇹🇷 Türkçe (varsayılan) · 🇬🇧 English · 🇩🇪 Deutsch · 🇪🇸 Español · 🇫🇷 Français · 🇮🇹 Italiano · 🇵🇹 Português · 🇷🇺 Русский · 🇨🇳 简体中文 · 🇯🇵 日本語

Uygulama açılışta **sistem diline** göre kendini ayarlar. Sistem dili bu on dilden
biri değilse **Türkçe** kullanılır. Dili elle de seçebilirsin (menüdeki 🌐 düğmesi
ya da Ayarlar → Genel → Dil); seçim kaydedilir ve anında uygulanır.

Çeviriler `Sources/*/Localization/` altında, dil başına tek dosya. Metinler tek bir
`struct` üzerinden tutulduğu için **eksik çeviri mümkün değil**: yeni bir metin
eklendiğinde çeviri dosyaları derlenmez, tamamlanana kadar hata verir. Yeni bir dil
eklemek için `AppLanguage`'a bir durum ve karşılık gelen dosyayı eklemek yeterli.

## Kurulum

```bash
./build.sh --install --run
```

Derler, `Kablo Kaşifi.app` paketini üretir, `/Applications` içine kopyalar ve çalıştırır.
Herhangi bir özel izin gerekmez.

İstersen ad-hoc yerine sabit bir yerel imza kimliğiyle imzalayabilirsin
(`./Scripts/setup-signing.sh` — bir kez yeter; `build.sh` varsa onu kullanır).

Terminalden hızlı bakış:

```bash
"/Applications/Kablo Kaşifi.app/Contents/MacOS/KabloKasifi" --print
```

## Nasıl çalışıyor

Veriler mümkün olan her yerde **native API'lerden** okunur; bunlar macOS sürümleri
arasında değişmediği için uygulama sürüm güncellemelerine dayanıklıdır:

| Bilgi | Kaynak |
|---|---|
| USB aygıtları, hız, USB sürümü, hub ağacı | IOKit — `IOUSBHostDevice` kayıtları (`UsbLinkSpeed`, `bcdUSB`, `locationID`) |
| Şarj adaptörü, voltaj/akım, PD profilleri, pil | IOKit — `AppleSmartBattery` / `AdapterDetails` |
| Harici ekranlar | CoreGraphics — `CGGetOnlineDisplayList` |
| Thunderbolt port durumu | `system_profiler` (tip adı çalışma anında keşfedilir) |

Aygıtın *kendi* yeteneği (`bcdUSB`) ile *gerçekleşen* bağlantı hızı (`UsbLinkSpeed`)
ayrı ayrı okunduğu için suçluyu doğru gösterebiliyor: yavaşlık aygıtın kendisinden mi,
araya giren hub'dan mı, yoksa kablodan mı kaynaklanıyor.

### macOS sürüm dayanıklılığı

Bu uygulamanın ilk sürümü `system_profiler SPUSBDataType` kullanıyordu ve **macOS 26'da
hiçbir USB aygıtını göremiyordu**: Apple bu veri tipini `SPUSBHostDataType` olarak
yeniden adlandırmış, `system_profiler` de var olmayan tip için hata vermek yerine
sessizce boş dizi döndürüyordu.

Alınan dersler koda işlendi:

1. Kritik veriler artık `system_profiler` yerine IOKit/CoreGraphics'ten okunuyor.
2. `system_profiler` gereken tek yerde (Thunderbolt) veri tipi adı
   `system_profiler -listDataTypes` ile **çalışma anında** doğrulanıyor; birden fazla
   aday isim deneniyor.
3. Bir kaynak okunamazsa bölüm sessizce boş kalmıyor — panelde turuncu uyarı çıkıyor.
4. `--doctor` bayrağı hangi kaynağın çalıştığını tek bakışta gösteriyor:

```bash
"/Applications/Kablo Kaşifi.app/Contents/MacOS/KabloKasifi" --doctor
```

```
macOS: Version 26.6.2 (Build 25G83)
USB (IOKit)            : 4 aygıt
Güç (IOKit)            : 96W USB-C Power Adapter
Ekran (CoreGraphics)   : 0 harici
Thunderbolt            : SPThunderboltDataType → 2 veri yolu
  ✗ SPUSBDataType
  ✓ SPUSBHostDataType
```

macOS 27'de bir veri tipi daha yeniden adlandırılırsa uygulama çalışmaya devam eder;
etkilenen tek bölüm (Thunderbolt) uyarı gösterir ve `--doctor` sebebi söyler.

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
  Core/USBProbe.swift              IOKit USB aygıt ağacı (hız, bcdUSB, hub ilişkisi)
  Core/PowerProbe.swift            IOKit adaptör/pil bilgisi (PD profilleri dahil)
  Core/ProbeStore.swift            Durum, canlı yenileme, yeni aygıt algılama
  Models/Connection.swift          Satır ve yorum modelleri
  Views/PanelView.swift            Menü çubuğu paneli
  Localization/                    10 dil, dil başına tek dosya (KKStrings)
  Views/RenderPreview.swift        Paneli PNG'ye çizen geliştirme yardımcısı
Scripts/setup-signing.sh           Sabit yerel imza kimliği oluşturur
```

### Geliştirme

```bash
swift build -c release
./.build/release/KabloKasifi --print               # terminalde özet
./.build/release/KabloKasifi --doctor              # veri kaynaklarının durumu
./.build/release/KabloKasifi --render /tmp/p.png   # paneli PNG olarak çiz
```

---

## In English

**Kablo Kaşifi** ("Cable Explorer") is a macOS menu bar app that tells you, in plain
language, what the USB-C cable you just plugged in can actually do: negotiated link
speed per device, whether a cable is limiting charging power (label watts vs. the
volts × amps actually negotiated, with the "battery is nearly full" case handled
separately), whether video is flowing, and the state of each Thunderbolt/USB4 port.
It reads USB topology from IOKit (`IOUSBHostDevice`), power from `AppleSmartBattery`
and displays from CoreGraphics, then turns them into one-sentence verdicts. Because it
reads each device's own `bcdUSB` capability alongside the negotiated `UsbLinkSpeed`, it
can tell you whether the bottleneck is the device, an intermediate hub, or the cable.
Native APIs are preferred over `system_profiler` deliberately: macOS 26 renamed
`SPUSBDataType` to `SPUSBHostDataType` and the old name silently returned an empty
array, so the first version saw no USB devices at all. Run `--doctor` to see which
data source is live on your macOS version. Available in 10 languages (Turkish, English, German, Spanish, French, Italian,
Portuguese, Russian, Chinese, Japanese); it follows your system language and falls
back to Turkish. No special permissions, nothing leaves your Mac.

Build with `./build.sh --install --run` (needs Xcode or Command Line Tools, macOS 14+).

MIT lisanslı.
