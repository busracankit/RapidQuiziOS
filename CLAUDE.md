# Rapid Quiz iOS

Proje dokümanı: `docs/RapidQuiz-iOS-Proje-Dokumani.md` (tek doğru kaynak). Kurallar özet:

- Swift 6 dil modu, iOS 17+, SwiftUI + Observation, üçüncü parti bağımlılık yok.
- Kod adları İngilizce; kullanıcı metinleri ve kod yorumları Türkçe. Metinler `RapidQuiz/Resources/Localizable.xcstrings`.
- API adresi `Config/*.xcconfig` → `Config/Info.plist` (`APIBaseURL`). Debug: localhost:8000, Release: rapidap.co.
- Puan/süre/doğru cevap sunucuda; istemci hesaplamaz. Zamanlama `ContinuousClock` ile (doküman 5. bölüm).
- Yol haritası (doküman 13. bölüm): her adım ayrı commit, yazar `Büşra Cankit <cankitbusra@gmail.com>`.
