# Rapid Quiz — iOS

[English](README.md) · **Türkçe**

Rapid Quiz üyeliksiz, hızlı bir bilgi yarışmasıdır: bir kategori seçilir, her biri **5 saniyelik** **20 soru** cevaplanır. Doğru cevap ne kadar hızlı verilirse o kadar çok puan getirir. Oyun sonunda yalnızca **isim** girilir ve kategorinin **İlk 10** skor tablosuna yazılır.

Bu repo, oyunun yerel iOS istemcisidir (Swift + SwiftUI). Web istemcisiyle aynı API'yi (`RapidQuizBackend`, API v1) kullanır. Puan, süre ve doğru cevap kararı tamamen sunucudadır; uygulama yalnızca gösterir.

## Ekranlar

1. **Kategoriler**: kategori kartlarının olduğu ana ekran
2. **Oyun**: 3-2-1 geri sayımı, 20 soru, geri sayım halkası, anında geri bildirim
3. **Sonuç**: puan, doğru sayısı, toplam süre, isimle kaydetme
4. **Skor Tablosu**: kategori seçici, podyum ve İlk 10

## Teknolojiler

| | |
| --- | --- |
| Dil | Swift 6 (katı eşzamanlılık) |
| Arayüz | SwiftUI, Observation (`@Observable`) |
| Minimum iOS | 17.0 (iPhone, dikey) |
| Ağ | `URLSession` + `async/await` + `Codable` |
| Test | Swift Testing, XCUITest |
| Bağımlılık | Yok |

## Kurulum

Gereksinim: Xcode 26 veya üstü yüklü bir Mac.

```bash
git clone https://github.com/busracankit/RapidQuiziOS.git
open RapidQuiziOS/RapidQuiz.xcodeproj
```

Bir iPhone simülatörü seçip çalıştır (`⌘R`).

### API adresi

API kök adresi koda gömülü değildir, derleme ayarından okunur:

| Ayar | Dosya | Adres |
| --- | --- | --- |
| Debug | `Config/Debug.xcconfig` | `http://localhost:8000` |
| Release | `Config/Release.xcconfig` | `https://rapidap.co` |

Değer `Config/Info.plist` (`APIBaseURL`) üzerinden uygulamaya geçer ve `AppConfig.apiBaseURL` ile okunur. xcconfig dosyalarında `//` yorum başlattığı için adresler `http:/$()/host` biçiminde yazılır.

### Backend'i yerelde çalıştırma

```bash
# RapidQuizBackend reposunda
uv run manage.py runserver 0.0.0.0:8000
```

- **Simülatör:** `http://localhost:8000` doğrudan çalışır.
- **Gerçek iPhone (aynı Wi-Fi):** `Debug.xcconfig` içinde `API_BASE_URL = http:/$()/<mac-adı>.local:8000` yap ve backend'de `<mac-adı>.local` adresini `DJANGO_ALLOWED_HOSTS`'a ekle. iOS ilk açılışta yerel ağ izni ister.

Düz HTTP yalnızca `localhost` ve `.local` adreslerine açıktır (`NSAllowsLocalNetworking`). Diğer tüm trafik HTTPS olmalıdır.

## Klasör yapısı

```
Config/                 xcconfig dosyaları ve Info.plist
RapidQuiz/
├── Config/             AppConfig (API adresini okur)
├── Design/             Renk tokenları, fontlar
├── Resources/          Localizable.xcstrings, gömülü fontlar
├── Networking/         API istemcisi ve modeller
├── Home/ Game/ Result/ Leaderboard/
└── Components/         Ortak görünümler
RapidQuizTests/         Birim testleri (Swift Testing)
RapidQuizUITests/       Arayüz testleri
docs/                   Proje dokümanı, font lisansları
```

## Doküman

API sözleşmesi, zamanlama kuralları, tasarım tokenları, arayüz metinleri ve yol haritasını içeren proje dokümanı: [`docs/RapidQuiz-iOS-Proje-Dokumani.md`](docs/RapidQuiz-iOS-Proje-Dokumani.md).

Uygulama arayüzü yalnızca Türkçedir. Kod adları İngilizce, kod yorumları Türkçedir.

## Fontlar

[Space Grotesk](https://github.com/floriankarsten/space-grotesk) ve [Plus Jakarta Sans](https://github.com/tokotype/PlusJakartaSans), SIL Open Font License 1.1 ile uygulamaya gömülüdür. Bkz. [`docs/licenses/`](docs/licenses/).
