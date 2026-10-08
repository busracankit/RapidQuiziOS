# Rapid Quiz — iOS Proje Dokümanı (Swift + SwiftUI)

> Sürüm 1.0 · 6 Ekim 2026 · Faz 4 (mobil). Bu dosya Xcode projesinin köküne `CLAUDE.md` ya da `docs/PROJE.md` olarak konabilir.
> Kaynak: backend reposu `RapidQuizBackend` (API v1) ve web istemcisi `RapidQuizFrontend`. Android uygulaması aynı dokümanın Compose sürümünü izler.

## 1. Amaç ve kapsam

Rapid Quiz üyeliksiz, hızlı bir bilgi yarışmasıdır: kategori seçilir, **20 soru**, her soru için **5 saniye**. Hızlı doğru cevap daha çok puan getirir. Oyun sonunda yalnızca **isim** alınır ve kategori bazlı **İlk 10** skor tablosuna yazılır. Puan, süre ve doğru cevap kararı **sunucudadır**, uygulama yalnızca gösterir.

Bu uygulama webdeki oyunun iOS'a aktarımıdır. Hedefler:

- 4 ekran: Kategoriler → Oyun → Sonuç → Skor Tablosu.
- Webdeki ile aynı API, aynı kurallar, aynı metinler, aynı renkler.
- iPhone, dikey yön. iPad ve yatay yön zorunlu değil (bozulmasın yeter).
- Üçüncü parti bağımlılık yok (URLSession + Codable yeterli).
- Kod adları İngilizce, kullanıcıya görünen metinler ve kod yorumları Türkçe.

## 2. Ekranlar ve akış

Uygulama webdeki oyunun birebir mobil karşılığıdır. **Yeni özellik yok:** üyelik, profil, ayarlar, bildirim, çevrimdışı mod, reklam, paylaşım, ses yok. Dil yalnızca Türkçe, tema yalnızca açık.

```
Kategoriler ──(kategoriye dokun)──► Oyun: 3-2-1 → 20 soru ──► Sonuç + isim ──(Kaydet)──► Skor Tablosu
     │                                                        │
     └──────────────(üst çubuktaki "Skor Tablosu")────────────┴──(Skor tablosunu gör)──► Skor Tablosu
```

| # | Ekran | İçerik | API |
| --- | --- | --- | --- |
| 1 | **Kategoriler** (açılış) | Logo "Rapid Quiz", slogan "20 soru. Her biri 5 saniye. Ne kadar hızlısın?", başlık "Bir kategori seç", kategori kartları (renk, ikon, ad, açıklama). Üst çubukta "Skor Tablosu" butonu. Yüklenirken iskelet kartlar, hata olursa mesaj + "Tekrar dene" | `GET /categories/` |
| 2 | **Oyun** | Önce tam ekran 3-2-1 (kategori adı ve rengiyle). Sonra: üstte `index/20` ve puan, 20 parçalı ilerleme çubuğu (doğru yeşil, yanlış/süre doldu kırmızı), dairesel geri sayım halkası, soru metni, alt alta 4 şık butonu (A/B/C/D rozetli). Cevaptan sonra doğru/yanlış + `+puan` | `POST /sessions/`, `POST /answers/`, `GET /current/` |
| 3 | **Sonuç** | "Oyun bitti!", büyük puan (sayarak artan animasyon), doğru `16/20`, toplam süre `41,2 sn`. İsim alanı (placeholder "Adın (2–20 karakter)") + "Kaydet". Altında "Tekrar oyna" (aynı kategori, yeni oyun), "Başka kategori" (ana ekran), "Skor tablosunu gör" | `GET /result/`, `POST /score/` |
| 4 | **Skor Tablosu** | Başlık "Skor Tablosu". Yatay kaydırılan kategori seçici (renk noktası + ad). Seçili kategori için İlk 10: ilk 3 podyum (altın/gümüş/bronz), 4–10 liste (sıra, isim, puan, "N doğru", süre). Oyundan gelindiyse kullanıcının satırı vurgulu (`accent` çerçeve, "Sen" etiketi). İlk 10'a giremediyse altta "Senin sıran: N.". Boşsa "Henüz skor yok. İlk sen ol!" | `GET /categories/`, `GET /leaderboard/?category=` |

Notlar:

- Oyun **kategoriye dokunduğun anda** başlar (POST anında sunucu sayacı 3 sn sonrasına kurar). Arada "Başla" butonu yoktur. Kurallar 3-2-1 ekranında küçük yazıyla gösterilebilir: "20 soru, her soru için 5 saniye · Hızlı cevap = daha çok puan (soru başı 150'ye kadar) · Süre dolarsa soru boş sayılır · Geri dönüp cevap değiştiremezsin".
- Skor Tablosu'na ana ekrandan girilirse ilk kategori seçilidir. Sonuçtan girilirse oynanan kategori seçili ve kullanıcının satırı vurguludur.
- Sonuç ekranından geri gidilirse ana ekrana dönülür (oyun ekranına geri dönülmez).

## 3. Sunucu adresleri

Uygulama tek bir **API kök adresi** (base URL) ile çalışır. Bu adres koda gömülmez, derleme ayarından okunur (aşağıdaki "Yapılandırma" bölümü).

| Ortam | Base URL | Not |
| --- | --- | --- |
| **Canlı (hedef)** | `https://rapidap.co` | Alan adı **henüz satın alınmadı** (deneme projesi). Alınıp DigitalOcean'a bağlanana kadar bu adrese istekler çalışmaz. |
| Geçici canlı | `https://starfish-app-yuzxi.ondigitalocean.app` | DO'nun verdiği adres. DO kaynakları silindiyse çalışmaz. |
| Yerel (Mac'te `runserver`) | `Simülatör: `http://localhost:8000`, gerçek cihaz: `http://<mac-adı>.local:8000`` | Backend: `uv run manage.py runserver 0.0.0.0:8000` |

Bütün uç noktalar `<base URL>/api/v1/` altındadır. Canlı adresle tam liste:

| # | Metot | Tam URL | Ne için |
| --- | --- | --- | --- |
| 1 | GET | `https://rapidap.co/api/v1/health/` | Sunucu ayakta mı (`{"status":"ok"}`) |
| 2 | GET | `https://rapidap.co/api/v1/categories/` | Ana ekran ve skor tablosundaki kategori listesi |
| 3 | POST | `https://rapidap.co/api/v1/sessions/` | Kategoriye dokununca oyunu başlatır, ilk soruyu döner |
| 4 | POST | `https://rapidap.co/api/v1/sessions/{session_id}/answers/` | Cevap gönderir, sonucu ve sıradaki soruyu döner |
| 5 | GET | `https://rapidap.co/api/v1/sessions/{session_id}/current/` | Uygulama arka plandan dönünce oyunu senkronlar |
| 6 | GET | `https://rapidap.co/api/v1/sessions/{session_id}/result/` | Oyun sonu özeti (puan, doğru sayısı, süre) |
| 7 | POST | `https://rapidap.co/api/v1/sessions/{session_id}/score/` | İsimle skor tablosuna kaydeder |
| 8 | GET | `https://rapidap.co/api/v1/leaderboard/?category={slug}` | Kategorinin İlk 10 listesi |

Tam şema (OpenAPI): `https://rapidap.co/api/schema/`, tarayıcıda deneme: `https://rapidap.co/api/docs/`.

## 4. API sözleşmesi (v1)

### 4.1 Genel kurallar

- **Sondaki `/` zorunlu.** `.../sessions` değil `.../sessions/`. Django eğik çizgisiz POST'u yönlendiremez, istek hata verir.
- Gövdeler JSON. Her istekte `Accept: application/json`, gövdeli isteklerde `Content-Type: application/json`.
- JSON anahtarları **snake_case** (`session_id`, `starts_in_ms`).
- **Üyelik, cookie ve CSRF yok.** Oyun oturumu, başlatırken dönen `session_token` ile taşınır: 4–7 numaralı isteklerde `X-Session-Token: <session_token>` başlığı gönderilir. Token yalnızca bir kez döner, uygulama oyun boyunca bellekte tutar ve loglara yazmaz.
- `client_type` mutlaka platforma göre gönderilir (`"android"` / `"ios"`). İstatistik için kullanılır.
- Zamanlar UTC ve ISO 8601 (`"2026-10-06T12:00:03.123456Z"`). **İstemci bunları zamanlama için kullanmaz** (bkz. 5. bölüm).
- **Puan, süre ve doğru cevap kararı tamamen sunucudadır.** İstemci yalnızca gösterir; puan hesaplamaz.

### 4.2 Hata biçimi

Başarısız her yanıt aynı biçimdedir. `message` Türkçe ve kullanıcıya gösterilebilir:

```json
{ "error": { "code": "invalid_player_name", "message": "İsim 2–20 karakter olmalı.", "details": {} } }
```

| HTTP | `code` | Ne zaman | İstemci ne yapar |
| --- | --- | --- | --- |
| 400 | `validation_error` | Gövde eksik/hatalı (`details` alan hatalarını içerir) | Genel hata mesajı. Geliştirme hatasıdır. |
| 400 | `invalid_json` | Gövde JSON değil | Geliştirme hatası |
| 400 | `invalid_choice` | `choice_id` 1–4 dışında | Geliştirme hatası |
| 400 | `invalid_player_name` | İsim kuralına uymuyor ya da uygunsuz | `message`'ı isim alanının altında göster |
| 403 | `invalid_session_token` | Token eksik/yanlış | "Oturum bulunamadı" ekranı → ana sayfa |
| 404 | `category_not_found` | Slug yok/pasif | Kategorileri yeniden yükle |
| 404 | `session_not_found` | Oturum yok | "Oturum bulunamadı" ekranı → ana sayfa |
| 404 | `not_found` | Yanlış adres | Geliştirme hatası (sondaki `/`'ı kontrol et) |
| 409 | `not_enough_questions` | Kategoride 20'den az soru | `message`'ı göster |
| 409 | `question_mismatch` | Gönderilen soru güncel soru değil | `/current/` ile senkronla (5.4) |
| 409 | `session_finished` | Tüm sorular zaten cevaplandı | Sonuç ekranına git |
| 409 | `session_not_finished` | Bitmemiş oyunda sonuç/skor istendi | `/current/` ile senkronla |
| 409 | `score_already_saved` | Skor bu oturum için zaten kaydedildi | Kaydedilmiş say, skor tablosuna geç |
| 410 | `session_expired` | Oyun başlayalı 30 dk geçti | "Oturumun süresi doldu" → ana sayfa |
| 429 | `rate_limited` | Çok fazla istek (IP başına) | `message`'ı göster |
| 500 | `server_error` | Sunucu hatası | Genel hata + "Tekrar dene" |

Bağlantı yoksa veya zaman aşımı olursa: "Sunucuya ulaşılamadı. İnternet bağlantını kontrol et." + "Tekrar dene".

İstek limitleri (IP başına, dakikada): oyun başlatma 30, cevap 120, skor kaydı 10, okuma (kategori, skor tablosu, current, result) 300.

### 4.3 Kategoriler

`GET /api/v1/categories/` → `200`, sayfalama yok, `order`'a göre sıralı dizi:

```json
[
  { "slug": "yazilim", "name": "Yazılım", "description": "…", "icon": "code", "color": "#3B82F6", "order": 1 },
  { "slug": "yapay-zeka", "name": "Yapay Zeka", "description": "…", "icon": "brain", "color": "#A855F7", "order": 2 },
  { "slug": "bilgisayar-muhendisligi", "name": "Bilgisayar Mühendisliği", "description": "…", "icon": "cpu", "color": "#F97316", "order": 3 },
  { "slug": "ulkeler", "name": "Ülkeler", "description": "…", "icon": "globe", "color": "#10B981", "order": 4 },
  { "slug": "fizik", "name": "Fizik", "description": "…", "icon": "atom", "color": "#06B6D4", "order": 5 }
]
```

`icon` bir anahtar kelimedir, platform ikonuna eşlenir (bkz. tasarım bölümü). Bilinmeyen anahtar için yedek ikon kullanılır. `color` `#RRGGBB` biçimindedir. Kategoriler admin'den değişebilir, **listeyi uygulamaya gömme.**

### 4.4 Oyunu başlat

`POST /api/v1/sessions/`

```json
{ "category": "yazilim", "client_type": "ios" }
```

→ `201`

```json
{
  "session_id": "3f6c1d9e-6a0b-4c55-9d3e-2b7f1c0a9e11",
  "session_token": "kX9…(uzun rastgele metin)",
  "category": { "slug": "yazilim", "name": "Yazılım", "color": "#3B82F6" },
  "total_questions": 20,
  "time_limit_ms": 5000,
  "question": {
    "index": 1,
    "id": 412,
    "text": "HTTP'de 404 durum kodu ne anlama gelir?",
    "difficulty": 1,
    "choices": [
      { "id": 1, "text": "Sunucu hatası" },
      { "id": 2, "text": "Bulunamadı" },
      { "id": 3, "text": "Yetkisiz" },
      { "id": 4, "text": "Yönlendirme" }
    ],
    "served_at": "2026-10-06T12:00:03.000000Z",
    "starts_in_ms": 3000,
    "remaining_ms": 5000
  }
}
```

**Soru nesnesi** (her yerde aynı):

| Alan | Tip | Anlam |
| --- | --- | --- |
| `index` | int | Oyundaki sırası, 1–20 |
| `id` | int | Soru kimliği. Cevapta `question_id` olarak geri gönderilir |
| `text` | string | Soru metni (≤ 120 karakter) |
| `difficulty` | int | 1 kolay, 2 orta, 3 zor (gösterim isteğe bağlı) |
| `choices` | dizi (4) | `id` **bu oyuna özel 1–4** (A=1, B=2, C=3, D=4 sırasıyla gösterilir), `text` ≤ 40 karakter |
| `served_at` | string | Sunucu tarafı sayaç başlangıcı. İstemci kullanmaz |
| `starts_in_ms` | int | Sayaç başlayana kadar bekleme: ilk soruda ≈3000 (3-2-1), sonrakilerde ≈800 (doğru/yanlış gösterimi) |
| `remaining_ms` | int | Sayaç başladıktan sonra kalan süre (normalde 5000) |

**Doğru şık soru ile asla gelmez**, yalnızca cevap yanıtında gelir.

### 4.5 Cevap gönder

`POST /api/v1/sessions/{session_id}/answers/` + `X-Session-Token`

```json
{ "question_id": 412, "choice_id": 2 }
```

Süre dolduysa **`choice_id` alanı `null` olarak açıkça gönderilir**. Alanı hiç göndermemek `400 validation_error` verir:

```json
{ "question_id": 412, "choice_id": null }
```

→ `200`

```json
{
  "is_correct": true,
  "timed_out": false,
  "correct_choice_id": 2,
  "selected_choice_id": 2,
  "points": 132,
  "score": 132,
  "correct_count": 1,
  "answered_count": 1,
  "finished": false,
  "next_question": { "index": 2, "id": 87, "text": "…", "difficulty": 1, "choices": [ … ], "served_at": "…", "starts_in_ms": 800, "remaining_ms": 5000 }
}
```

`finished: true` olduğunda `next_question` `null` gelir, sonuç ekranına geçilir.

### 4.6 Oyun durumu (senkron)

`GET /api/v1/sessions/{session_id}/current/` + `X-Session-Token` → `200`

```json
{
  "session_id": "3f6c…",
  "status": "in_progress",
  "category": { "slug": "yazilim", "name": "Yazılım", "color": "#3B82F6" },
  "total_questions": 20,
  "time_limit_ms": 5000,
  "score": 264,
  "correct_count": 2,
  "answered_count": 3,
  "finished": false,
  "question": { …soru nesnesi… },
  "answers": [ { "index": 1, "is_correct": true, "timed_out": false, "points": 132, "response_ms": 1180 } ]
}
```

`status`: `in_progress` / `completed` / `expired`. Sunucu, süresi geçmiş soruları bu çağrıda "süre doldu" olarak kapatır ve gerekirse sıradakini verir. `finished: true` ise `question` `null`'dır.

### 4.7 Sonuç

`GET /api/v1/sessions/{session_id}/result/` + `X-Session-Token` → `200` (oyun bitmediyse `409 session_not_finished`)

```json
{
  "session_id": "3f6c…",
  "category": { "slug": "yazilim", "name": "Yazılım", "color": "#3B82F6" },
  "score": 2140,
  "max_score": 3000,
  "correct_count": 16,
  "total_questions": 20,
  "total_time_ms": 41230,
  "finished_at": "2026-10-06T12:02:10.000000Z",
  "answers": [ { "index": 1, "is_correct": true, "timed_out": false, "points": 132, "response_ms": 1180 } ],
  "score_saved": false,
  "player_name": null,
  "rank": null
}
```

`total_time_ms` "41,2 sn" gibi gösterilir. `score_saved: true` ise isim alanı yerine "Skorun “İsim” adıyla kaydedildi." yazılır.

### 4.8 Skoru kaydet

`POST /api/v1/sessions/{session_id}/score/` + `X-Session-Token`

```json
{ "player_name": "Büşra" }
```

İsim kuralı (sunucu uygular, istemci de ön kontrol yapar): baştaki/sondaki boşluklar silinir, art arda boşluklar teke iner, **2–20 karakter**, yalnızca harf (Türkçe dahil), rakam, boşluk ve `- _ . '`, en az bir harf/rakam. Uygunsuz kelimeler reddedilir. Her oyun yalnızca **bir kez** kaydedilir.

→ `201`

```json
{
  "entry": { "id": 981, "rank": 4, "player_name": "Büşra", "score": 2140, "correct_count": 16, "total_time_ms": 41230, "created_at": "2026-10-06T12:02:30.000000Z" },
  "rank": 4,
  "in_top": true,
  "leaderboard": {
    "category": { "slug": "yazilim", "name": "Yazılım", "color": "#3B82F6" },
    "entries": [ { "id": 12, "rank": 1, "player_name": "Ada", "score": 2710, "correct_count": 19, "total_time_ms": 30120, "created_at": "…" } ]
  }
}
```

Yanıttaki `leaderboard` güncel İlk 10'dur, skor tablosuna geçerken tekrar istek atmaya gerek yoktur. `in_top: false` ise listenin altında "Senin sıran: 37." gösterilir. Kullanıcının satırı `entry.id` ile bulunup vurgulanır.

### 4.9 Skor tablosu

`GET /api/v1/leaderboard/?category=yazilim` → `200`

```json
{
  "category": { "slug": "yazilim", "name": "Yazılım", "color": "#3B82F6" },
  "entries": [
    { "id": 12, "rank": 1, "player_name": "Ada", "score": 2710, "correct_count": 19, "total_time_ms": 30120, "created_at": "2026-10-05T18:11:02.000000Z" }
  ]
}
```

En fazla 10 satır. Sıralama sunucudadır (puan ↓, süre ↑, kayıt zamanı ↑). Aynı isim birden çok kez yer alabilir. Boş liste → "Henüz skor yok. İlk sen ol!". **Tüm kategorileri birleştiren genel bir liste API'de yoktur.** Skor tablosu ekranı, webdeki gibi kategori seçici + seçili kategorinin İlk 10'udur.

### 4.10 Puan kuralı (yalnızca bilgi; istemci hesaplamaz)

Doğru cevap 100 puan + hız bonusu `floor(50 × (5000 − cevap_ms) / 5000)` → soru başına 100–150. Yanlış ya da süre dolması 0. En yüksek puan 20 × 150 = 3000. Sunucu 750 ms ağ toleransı tanır.

## 5. Oyun zamanlaması (en kritik bölüm)

Webde bulunan ve düzeltilen hata burada tekrar edilmemeli: geri bildirim süresi iki kez beklenirse oyuncu her soruda ~0,8 sn kaybeder.

### 5.1 Saat

- **Monoton saat** kullanılır (iOS: `ContinuousClock`). Cihazın duvar saati ve `served_at` zamanlama için **kullanılmaz** (cihaz saati yanlış olabilir).
- `starts_in_ms` **yanıtın alındığı ana** göredir. Başlangıç anı yanıt geldiği anda bir kez hesaplanır: `startsAt = şimdi + starts_in_ms`.

### 5.2 Akış

1. **Başlat:** `POST /sessions/` → `startsAt = şimdi + question.starts_in_ms` (≈3000). Bu sürede tam ekran **3-2-1** gösterilir (kalan süreden hesaplanır, sabit 1 sn'lik adımlarla değil).
2. **Soru:** `startsAt` gelince soru ve şıklar görünür, geri sayım `remaining_ms − (şimdi − startsAt)` değerinden başlar. Halka renkleri: >2 sn yeşil, 2–1 sn sarı, son 1 sn kırmızı + hafif titreşim.
3. **Cevap:** Şıkka dokununca hemen şıklar kilitlenir, sayaç durur, seçilen şık "bekliyor" görünür, `POST /answers/` atılır. Aynı anda ikinci istek atılmaz (çift dokunma koruması).
4. **Süre doldu:** Sayaç 0'a inince `choice_id: null` ile aynı istek atılır.
5. **Geri bildirim:** Yanıt gelince `nextStartsAt = şimdi + next_question.starts_in_ms` (≈800) hesaplanır. Doğru/yanlış, `correct_choice_id` ve `+puan` gösterilir. Yanlışta hafif titreşim. **`nextStartsAt` gelince** doğrudan 2. adıma geçilir, ek bekleme eklenmez.
6. **Son soru:** `finished: true` → geri bildirim ~900 ms gösterilir → `GET /result/` → Sonuç ekranı.

### 5.3 Şık durumları

| Durum | Görünüm |
| --- | --- |
| `idle` | Normal, dokunulabilir |
| `pending` | Seçildi, yanıt bekleniyor (diğerleri soluk) |
| `correct` | Seçilen = doğru → yeşil + ✓ |
| `wrong` | Seçilen ama yanlış → kırmızı + ✕ (hafif sallanma) |
| `reveal` | Seçilmedi ama doğru → yeşil çerçeve + ✓ |
| `dimmed` | Diğerleri, soluk |

Doğru/yanlış yalnızca renkle değil ikonla da belirtilir.

### 5.4 Senkron ve kesintiler

- Uygulama oyun sırasında **arka plana gider ve geri gelirse:** sayaç durdurulur, `GET /current/` çağrılır, gelen duruma göre devam edilir (sunucu bu arada süresi dolan soruları kapatmış olabilir). `finished: true` ise sonuç ekranına geçilir.
- `409 question_mismatch` veya `409 session_not_finished` → `GET /current/` ile senkron.
- `403 / 404 session_not_found / 410` → "Oyun oturumu bulunamadı ya da süresi doldu. Yeni bir oyun başlat." + "Ana sayfaya dön".
- Cevap isteği ağ hatası verirse: bir kez "Tekrar dene" sunulur. Tekrar denemede yine aynı `question_id` gönderilir. Sunucu zaten işlediyse `409 question_mismatch` döner, o zaman `/current/` ile senkronlanır.
- Uygulama süreci tamamen kapanırsa oyun kaybolur (kabul edilen sadelik). Token kalıcı depoya yazılmaz.
- Oyun ekranında geri tuşu/kaydırma: "Oyundan çıkılsın mı?" onayı. Çıkılırsa oturum terk edilir (sunucu 30 dk sonra kendisi kapatır).

## 6. Tasarım

Açık zemin, canlı ve enerjik: krem arka plan üzerinde doygun renkli kartlar, hızlı mikro animasyonlar. Koyu tema yok.

| Token | Hex | Kullanım |
| --- | --- | --- |
| `bg` | `#FFF8F1` | Ekran arka planı |
| `surface` | `#FFFFFF` | Kart, soru kutusu |
| `ink` | `#1E1B4B` | Ana metin (siyah yerine lacivert) |
| `primary` | `#7C3AED` | Ana buton, logo, ilerleme |
| `accent` | `#FF4D8D` | Vurgu, puan animasyonu, kullanıcının satırı |
| `success` | `#22C55E` | Doğru |
| `danger` | `#EF4444` | Yanlış, son 1 sn |
| `warning` | `#FACC15` | Sayaç 2 sn altı |

- **Font:** başlıklar *Space Grotesk* Bold, metin *Plus Jakarta Sans* Regular/SemiBold (Google Fonts, OFL lisanslı, uygulamaya gömülür). Soru metni en az 20 pt/sp.
- **Köşeler:** kartlar 24, butonlar 16. Kategori kartında kategori renginin %25'i ile hafif gölge.
- **Şık butonu:** tam genişlik, en az 56 yükseklik, solda A/B/C/D rozeti, metin kalın.
- **Podyum:** 1. altın `#F5B301`, 2. gümüş `#A8B0BD`, 3. bronz `#CD7F32`.
- **Animasyon:** doğruda kısa pulse ve yukarı uçan `+132`. Yanlışta şık hafifçe sallanır. Sistemde "hareketi azalt" açıksa animasyonlar kapatılır.
- **Erişilebilirlik:** metin kontrastı en az 4.5:1. Şıkların ekran okuyucu etiketi "A şıkkı: …". Geri sayım "3 saniye kaldı" diye okunur. Dinamik yazı boyutu desteklenir.
- **İkon eşlemesi** (`category.icon` → platform ikonu): bkz. platform bölümü.

## 7. Arayüz metinleri (Türkçe, webdekiyle aynı)

| Anahtar | Metin |
| --- | --- |
| app_name | Rapid Quiz |
| slogan | 20 soru. Her biri 5 saniye. Ne kadar hızlısın? |
| leaderboard | Skor Tablosu |
| pick_category | Bir kategori seç |
| load_error_categories | Kategoriler yüklenemedi. |
| retry | Tekrar dene |
| get_ready | Hazır ol! |
| progress | %1$d/%2$d |
| score | Puan |
| seconds_left | %d saniye kaldı |
| correct | Doğru! |
| wrong | Yanlış! |
| time_up | Süre doldu! |
| correct_answer_was | Doğru cevap: %s |
| points_plus | +%d |
| result_title | Oyun bitti! |
| result_correct | Doğru |
| result_time | Toplam süre |
| seconds_fmt | %s sn (ondalık ayırıcı virgül: 41,2 sn) |
| name_prompt | Skor tablosuna adını yaz |
| name_placeholder | Adın (2–20 karakter) |
| name_too_short | İsim en az 2 karakter olmalı. |
| save | Kaydet |
| saving | Kaydediliyor… |
| already_saved | Skorun “%s” adıyla kaydedildi. |
| see_leaderboard | Skor tablosunu gör |
| play_again | Tekrar oyna |
| other_category | Başka kategori |
| top10 | İlk 10 |
| leaderboard_empty | Henüz skor yok. İlk sen ol! |
| you | Sen |
| your_rank | Senin sıran: %d. |
| n_correct | %d doğru |
| points | puan |
| load_error_leaderboard | Skor tablosu yüklenemedi. |
| error_generic | Bir şeyler ters gitti. Lütfen tekrar dene. |
| error_network | Sunucuya ulaşılamadı. İnternet bağlantını kontrol et. |
| error_session_lost | Oyun oturumu bulunamadı ya da süresi doldu. Yeni bir oyun başlat. |
| back_home | Ana sayfaya dön |
| quit_title | Oyundan çıkılsın mı? |
| quit_message | İlerlemen kaybolacak. |
| quit_confirm | Çık |
| quit_cancel | Devam et |

## 8. Teknoloji (Ekim 2026)

| Bileşen | Seçim | Not |
| --- | --- | --- |
| IDE | Xcode 27 | macOS Tahoe 26.6 veya üstü gerekir |
| Dil | Swift 6.4, **Swift 6 dil modu** (katı eşzamanlılık) | UI tarafı `@MainActor` |
| UI | SwiftUI | Yeni proje: iOS › App, Interface: SwiftUI |
| Minimum iOS | 17.0 | `@Observable`, `.sensoryFeedback` için |
| Durum | Observation (`@Observable`) | `ObservableObject`/Combine yok |
| Navigasyon | `NavigationStack(path:)` + `enum Route` | |
| Ağ | `URLSession` + `async/await` | |
| JSON | `Codable` (`JSONDecoder.keyDecodingStrategy = .convertFromSnakeCase`) | |
| Saat | `ContinuousClock` | monoton |
| Test | Swift Testing (`import Testing`) + `URLProtocol` stub'ı, XCUITest (isteğe bağlı) | |

## 9. Yapılandırma

### 9.1 Ortama göre API adresi (xcconfig)

Proje kökünde `Config/Debug.xcconfig` ve `Config/Release.xcconfig` oluştur, Project › Info › Configurations'da Debug/Release'e bağla:

```
// Debug.xcconfig. xcconfig'te "//" yorum başlatır, bu yüzden "/$()/" yazılır.
API_BASE_URL = http:/$()/localhost:8000
```

```
// Release.xcconfig
API_BASE_URL = https:/$()/rapidap.co
```

Target › Info'ya özel anahtar ekle: `APIBaseURL` = `$(API_BASE_URL)`. Kodda:

```swift
enum AppConfig {
    static let apiBaseURL: URL = {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String,
              let url = URL(string: raw) else { fatalError("APIBaseURL ayarlı değil") }
        return url
    }()
}
```

Canlı sunucuya Debug'dan bağlanmak istersen `Debug.xcconfig`'teki değeri geçici olarak `https:/$()/rapidap.co` (veya DO adresi) yap.

### 9.2 App Transport Security ve yerel ağ

iOS varsayılan olarak yalnızca HTTPS'e izin verir. Yerel sunucu için Target › Info'ya:

- `App Transport Security Settings` › `Allows Local Networking` = `YES` (`NSAllowsLocalNetworking`). Bu yalnızca `localhost` ve `.local` adreslerini açar, canlı trafik yine HTTPS olur. `NSAllowsArbitraryLoads` **kullanma.**
- Gerçek iPhone ile Mac'e bağlanırken: `Privacy - Local Network Usage Description` (`NSLocalNetworkUsageDescription`) = "Geliştirme sunucusuna bağlanmak için". iOS ilk istekte izin sorar.

### 9.3 Yerel ortam özeti

| Cihaz | Base URL | Gerekenler |
| --- | --- | --- |
| Simülatör | `http://localhost:8000` | Mac'te `runserver` yeterli |
| Gerçek iPhone (aynı Wi-Fi) | `http://<mac-adı>.local:8000` | `runserver 0.0.0.0:8000`, `<mac-adı>.local`'ı backend `DJANGO_ALLOWED_HOSTS`'a ekle. Mac adı: Sistem Ayarları › Genel › Paylaşma › Yerel ana bilgisayar adı |
| Canlı | `https://rapidap.co` | Alan adı alınmış ve DO'ya bağlanmış olmalı |

Gerçek cihazda çalıştırmak için ücretsiz Apple ID ile "Personal Team" imzası yeterli. App Store yayını için ücretli Apple Developer Program üyeliği gerekir (sonraki iş).

## 10. Mimari ve kod iskeleti

### 10.1 Klasör yapısı

```
RapidQuiz/
├── RapidQuizApp.swift            # @main, WindowGroup { RootView() }
├── Config/AppConfig.swift
├── Networking/
│   ├── APIClient.swift           # URLSession, istek kurma, hata çözme
│   ├── APIError.swift            # .server(status, code, message), .network, .decoding
│   └── Models.swift              # Codable modeller
├── Game/
│   ├── GameModel.swift           # @Observable @MainActor: oyun durumu + zamanlama
│   └── GameView.swift            # 3-2-1, soru, şıklar, geri bildirim
├── Home/HomeView.swift (+ HomeModel)
├── Result/ResultView.swift (+ ResultModel)
├── Leaderboard/LeaderboardView.swift (+ LeaderboardModel)
├── Components/                   # CategoryCard, ChoiceButton, CountdownRing, ProgressSegments, Podium, ErrorPanel
├── Design/                       # Colors.swift (Color(hex:)), Fonts.swift
└── Resources/
    ├── Localizable.xcstrings     # 7. bölümdeki metinler (tr)
    └── Fonts/*.ttf
```

### 10.2 Modeller

```swift
struct Category: Codable, Identifiable, Hashable, Sendable {
    let slug, name: String
    let description: String?
    let icon: String?
    let color: String
    let order: Int?
    var id: String { slug }
}

struct CategoryBrief: Codable, Hashable, Sendable { let slug, name, color: String }
struct Choice: Codable, Identifiable, Hashable, Sendable { let id: Int; let text: String }

struct Question: Codable, Identifiable, Hashable, Sendable {
    let index, id: Int
    let text: String
    let difficulty: Int
    let choices: [Choice]
    let servedAt: String
    let startsInMs: Int
    let remainingMs: Int
}

struct StartSessionRequest: Encodable, Sendable { let category: String; var clientType = "ios" }

struct SessionStart: Decodable, Sendable {
    let sessionId, sessionToken: String
    let category: CategoryBrief
    let totalQuestions, timeLimitMs: Int
    let question: Question
}

/// DİKKAT: Otomatik Encodable nil değeri HİÇ yazmaz (encodeIfPresent). Süre dolunca
/// "choice_id": null gönderilmesi gerekir (alan yoksa sunucu 400 döner) → elle encode.
struct AnswerRequest: Encodable, Sendable {
    let questionId: Int
    let choiceId: Int?
    enum CodingKeys: String, CodingKey { case questionId = "question_id", choiceId = "choice_id" }
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(questionId, forKey: .questionId)
        try c.encode(choiceId, forKey: .choiceId)   // nil → null
    }
}

struct AnswerResult: Decodable, Sendable {
    let isCorrect, timedOut: Bool
    let correctChoiceId: Int
    let selectedChoiceId: Int?
    let points, score, correctCount, answeredCount: Int
    let finished: Bool
    let nextQuestion: Question?
}

struct AnswerSummary: Decodable, Hashable, Sendable {
    let index: Int; let isCorrect, timedOut: Bool; let points, responseMs: Int
}

struct SessionState: Decodable, Sendable {
    let sessionId, status: String
    let category: CategoryBrief
    let totalQuestions, timeLimitMs, score, correctCount, answeredCount: Int
    let finished: Bool
    let question: Question?
    let answers: [AnswerSummary]
}

struct GameResult: Decodable, Sendable {
    let sessionId: String
    let category: CategoryBrief
    let score, maxScore, correctCount, totalQuestions, totalTimeMs: Int
    let finishedAt: String?
    let answers: [AnswerSummary]
    let scoreSaved: Bool
    let playerName: String?
    let rank: Int?
}

struct ScoreRequest: Encodable, Sendable { let playerName: String }

struct LeaderboardEntry: Decodable, Identifiable, Hashable, Sendable {
    let id, rank: Int
    let playerName: String
    let score, correctCount, totalTimeMs: Int
    let createdAt: String
}

struct Leaderboard: Decodable, Sendable { let category: CategoryBrief; let entries: [LeaderboardEntry] }
struct ScoreSaved: Decodable, Sendable { let entry: LeaderboardEntry; let rank: Int; let inTop: Bool; let leaderboard: Leaderboard }
struct APIErrorBody: Decodable, Sendable { let error: Detail; struct Detail: Decodable, Sendable { let code, message: String } }
```

Decoder: `keyDecodingStrategy = .convertFromSnakeCase`. Encoder: `keyEncodingStrategy = .convertToSnakeCase` (`AnswerRequest` kendi anahtarlarını kullanır). Fazla gelen alanlar Codable'da sorun çıkarmaz.

### 10.3 APIClient

```swift
struct APIClient: Sendable {
    var baseURL = AppConfig.apiBaseURL
    var session: URLSession = {
        let c = URLSessionConfiguration.default
        c.timeoutIntervalForRequest = 10
        return URLSession(configuration: c)
    }()

    func categories() async throws -> [Category] { try await send("GET", "api/v1/categories/") }
    func startSession(_ slug: String) async throws -> SessionStart {
        try await send("POST", "api/v1/sessions/", body: StartSessionRequest(category: slug))
    }
    func answer(_ id: String, token: String, questionId: Int, choiceId: Int?) async throws -> AnswerResult {
        try await send("POST", "api/v1/sessions/\(id)/answers/", token: token,
                       body: AnswerRequest(questionId: questionId, choiceId: choiceId))
    }
    func current(_ id: String, token: String) async throws -> SessionState { try await send("GET", "api/v1/sessions/\(id)/current/", token: token) }
    func result(_ id: String, token: String) async throws -> GameResult { try await send("GET", "api/v1/sessions/\(id)/result/", token: token) }
    func saveScore(_ id: String, token: String, name: String) async throws -> ScoreSaved {
        try await send("POST", "api/v1/sessions/\(id)/score/", token: token, body: ScoreRequest(playerName: name))
    }
    func leaderboard(_ slug: String) async throws -> Leaderboard {
        try await send("GET", "api/v1/leaderboard/", query: [URLQueryItem(name: "category", value: slug)])
    }

    // send(): URLRequest kur → Accept/Content-Type, varsa "X-Session-Token" başlığı →
    // 2xx ise decode; değilse APIErrorBody çöz → APIError.server(status:code:message:);
    // URLError → APIError.network.
}
```

Yollar `/` ile biter. `baseURL.appending(path:)` kullanılır. Token loglanmaz.

### 10.4 Oyun durumu (GameModel)

```swift
@Observable @MainActor
final class GameModel {
    enum Phase: Equatable {
        case starting                 // POST /sessions/ bekleniyor
        case countdown                // 3-2-1 (ilk soru)
        case playing                  // soru görünür, sayaç akıyor
        case answering(selected: Int?)
        case feedback(AnswerResult)
        case finished                 // → Sonuç ekranı
        case error(message: String, sessionLost: Bool)
    }

    private(set) var phase: Phase = .starting
    private(set) var category: CategoryBrief?
    private(set) var question: Question?
    private(set) var questionStartsAt: ContinuousClock.Instant = .now
    private(set) var score = 0
    private(set) var answers: [AnswerSummary] = []
    private(set) var totalQuestions = 20
    private(set) var timeLimitMs = 5000

    private(set) var sessionId: String?
    private(set) var token: String?          // yalnızca bellekte
    private let api: APIClient
    private let clock = ContinuousClock()
    private var timerTask: Task<Void, Never>?
}
```

(`AnswerResult`'ı `Equatable` yap ya da `feedback` durumunda yalnızca gerekli alanları tut.)

Kurallar (5. bölümün Swift karşılığı):

- Yanıt alınır alınmaz `questionStartsAt = clock.now + .milliseconds(question.startsInMs)`.
- Kalan süre: `max(0, remainingMs − max(0, (clock.now − questionStartsAt) ms))`.
- Sayaç: `timerTask = Task { try? await clock.sleep(until: questionStartsAt); phase = .playing; try? await clock.sleep(until: questionStartsAt + .milliseconds(remaining)); if !Task.isCancelled { await submit(nil) } }`. Cevap verilince ya da ekran kapanınca `timerTask?.cancel()`.
- Halka animasyonu: `TimelineView(.animation)` içinde kalan süre `GameModel`'den hesaplanır (saniyelik timer ile değil, akıcı olsun).
- `submit` yalnızca `.playing` iken çalışır (çift dokunma koruması).
- Geri bildirimden sonra: `clock.sleep(until: nextStartsAt)` → sıradaki soru. **Ek bekleme yok.**
- `finished` → `sleep(for: .milliseconds(900))` → `.finished`.
- `@Environment(\.scenePhase)`: `.background` → sayacı durdur. `.active` → `resync()` (`GET /current/`).
- Geri: oyun ekranında `.navigationBarBackButtonHidden(true)`, kendi "Çık" butonu + `confirmationDialog("Oyundan çıkılsın mı?")`. Kaydırarak geri dönme de engellenir.
- Haptik: `.sensoryFeedback(.error, trigger: wrongCount)` ve son 1 saniyede `.sensoryFeedback(.warning, …)`.
- Sonuç ekranı aynı oturumu kullanır: `sessionId` ve `token` rota ile geçirilir ya da `GameModel` ortamda (`.environment`) paylaşılır. Kalıcı depoya (UserDefaults/Keychain) yazılmaz.

### 10.5 Navigasyon

```swift
enum Route: Hashable {
    case game(slug: String)
    case result(sessionId: String, token: String)
    case leaderboard(slug: String?, highlightId: Int?, myRank: Int?)
}
```

`RootView`: `NavigationStack(path: $path) { HomeView() .navigationDestination(for: Route.self) { … } }`.

- Home → Game: `path.append(.game(slug:))`.
- Game → Result: son eleman değiştirilir (`path.removeLast(); path.append(.result(…))`), geri gelince oyuna dönülmesin.
- Result → Leaderboard (kayıttan sonra): `.leaderboard(slug:, highlightId: entry.id, myRank: rank)`.
- "Tekrar oyna": `path = [.game(slug:)]`. "Başka kategori": `path.removeAll()`.

### 10.6 Tema ve ikonlar

- `Colors.swift`: 6. bölümdeki tokenlar + `Color(hex: "#3B82F6")` init'i (hatalı değerde `primary`).
- Fontlar: `.ttf` dosyalarını target'a ekle, Info'da `Fonts provided by application` (`UIAppFonts`). Kullanım: `Font.custom("SpaceGrotesk-Bold", size: 28, relativeTo: .title)` (Dinamik Yazı desteklensin).
- `category.icon` → SF Symbols: `code` → `chevron.left.forwardslash.chevron.right`, `brain` → `brain`, `cpu` → `cpu`, `globe` → `globe.europe.africa.fill`, `atom` → `atom`, diğer → `questionmark.circle`.
- Metinler `Localizable.xcstrings` (yalnızca `tr`). Proje dili Türkçe (Development Region = tr).
- Süre biçimi: `(Double(ms) / 1000).formatted(.number.precision(.fractionLength(1)).locale(Locale(identifier: "tr_TR")))` + " sn".
- Hareketi azalt: `@Environment(\.accessibilityReduceMotion)` açıksa sallanma/pulse kapalı.

## 11. Test planı

| Seviye | Ne | Araç |
| --- | --- | --- |
| Birim | Zamanlama: `startsAt` hesaplama, kalan süre, süre dolunca `nil` gönderimi, geri bildirimin tek kez beklenmesi (saat enjekte edilerek) | Swift Testing |
| Birim | JSON: 4. bölümdeki örnek yanıtlar çözülüyor mu; `AnswerRequest(questionId: 1, choiceId: nil)` → `{"question_id":1,"choice_id":null}` | Swift Testing |
| Entegrasyon | APIClient: 201/200 yanıtları, 4xx hata gövdesi → `APIError.server(code:)` | `URLProtocol` stub |
| UI | Ana ekran → kategori → 20 soru → isim → skor tablosu | XCUITest (isteğe bağlı) |
| Elle | Simülatör + yerel backend ile bir tam oyun, uçak modu, arka plana atıp 10 sn sonra dönme, isim hataları, Release ile canlı adres | |


## 12. Backend tarafı: mobil için gerekenler

API kodunda **değişiklik gerekmez.** Mobil için tasarlandı: cookie/CSRF yok (token başlıkta), `client_type` zaten `web/ios/android` kabul ediyor, cevap yanıtı sıradaki soruyu da içeriyor. CORS yalnızca tarayıcıları ilgilendirir, yerel uygulamalar etkilenmez.

Yapılması gereken **ayarlar**:

1. **Yerel geliştirme:** Android emülatörü Mac'e `10.0.2.2` adresiyle gelir, gerçek cihazlar Mac'in ağ adresiyle gelir. Django bu `Host` değerlerini tanımıyorsa `400 Bad Request` döner. Backend `.env` dosyasında:
   `DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0,10.0.2.2,<mac-adı>.local,<mac-ip>`
   ve sunucu `uv run manage.py runserver 0.0.0.0:8000` ile başlatılır (yalnızca `127.0.0.1`'i dinlerse cihazlar ulaşamaz).
2. **Canlı:** backend HTTPS ile yayında olmalı (DO kaynakları silindiyse `docs/deploy.md` › "Panelden kurulum" ile yeniden kurulur). `rapidap.co` alınıp DO'ya bağlandığında `api` bileşeninde:
   `DJANGO_ALLOWED_HOSTS=rapidap.co,www.rapidap.co` ve `CSRF_TRUSTED_ORIGINS=https://rapidap.co,https://www.rapidap.co` (CSRF yalnızca admin paneli için).
   iOS (ATS) ve Android (cleartext kapalı) canlıda yalnızca HTTPS'e izin verir. DO sertifikayı otomatik verir.
3. **İsteğe bağlı, şimdilik gerek yok:** tüm kategorileri birleştiren "genel skor tablosu" istenirse yeni bir uç nokta (ör. `GET /api/v1/leaderboard/overall/`) gerekir, çünkü bugün API'de ve webde yok. Ayrıca mobil operatörler çok kullanıcıyı aynı IP'den çıkarabilir (CGNAT). Kullanıcı sayısı artarsa IP başına limitler (`THROTTLE_*`) gevşetilebilir.

## 13. Yol haritası (sırayla, her adım ayrı commit)

1. Proje kurulumu: iOS 17 hedefi, Swift 6 modu, xcconfig'ler, ATS/yerel ağ ayarları, renkler/fontlar, `Localizable.xcstrings`.
2. Ağ katmanı: modeller, APIClient, hata çözme, JSON testleri.
3. Kategoriler ekranı (yükleniyor/hata/liste).
4. Oyun ekranı: 3-2-1, soru, sayaç, cevap, geri bildirim, ilerleme çubuğu + zamanlama testleri.
5. Arka plan/geri/senkron ve hata durumları.
6. Sonuç ekranı + isimle kaydetme.
7. Skor tablosu ekranı (kategori seçici, podyum, vurgu, "Senin sıran").
8. Erişilebilirlik (VoiceOver, Dinamik Yazı, hareketi azalt), küçük ekran (iPhone SE) kontrolü.
9. Release ile canlı adreste test. App Store ikonu/ekran görüntüleri sonra.

Commit yazarı: `Büşra Cankit <cankitbusra@gmail.com>`. Push'u Büşra yapar.
