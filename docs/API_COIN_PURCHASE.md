# Jeton (Coin) Satın Alma – API Gereksinimleri

Bu doküman, uygulama tarafında jeton satın alma ve jeton harcama akışı için backend’de yapılması gerekenleri açıklar.

---

## 1. Jeton paketlerini listeleme

Admin panelden eklenen jeton paketleri uygulama tarafından bu endpoint ile çekilir. Her paketin **SKU** alanı, Google Play Console’da tanımlı **consumable** ürün ID’si ile birebir aynı olmalıdır; uygulama bu SKU ile Google’dan fiyat bilgisini alır.

### Endpoint

```
GET /api/coins/packages.php
```

**Headers:**  
- `Authorization: Bearer <token>` (giriş yapmış kullanıcı)

**Body:** Yok (GET)

### Başarılı yanıt (200)

İki format desteklenir; uygulama ikisini de parse eder.

**Seçenek A – Doğrudan liste:**

```json
[
  {
    "id": 1,
    "sku": "coins_100",
    "coin_amount": 100,
    "title": "100 Jeton",
    "sort_order": 1,
    "currency": "TRY",
    "display_price": "19,99 TL"
  },
  {
    "id": 2,
    "sku": "coins_500",
    "coin_amount": 500,
    "title": "500 Jeton",
    "sort_order": 2
  }
]
```

**Seçenek B – Obje içinde `packages`:**

```json
{
  "packages": [
    {
      "id": 1,
      "sku": "coins_100",
      "coin_amount": 100,
      "title": "100 Jeton",
      "sort_order": 1
    }
  ]
}
```

### Alan açıklamaları

| Alan          | Zorunlu | Açıklama |
|---------------|--------|----------|
| `id`          | Evet   | Paket birincil anahtarı |
| `sku`         | Evet   | Google Play’deki consumable product ID (örn. `coins_100`) |
| `coin_amount` | Evet   | Bu paketle verilecek jeton miktarı |
| `title`       | Hayır  | Gösterim adı (örn. "100 Jeton") |
| `sort_order`  | Hayır  | Listeleme sırası (küçük önce) |
| `currency`    | Hayır  | Para birimi kodu |
| `display_price` | Hayır | Mağaza fiyatı yüklenemezse gösterilecek metin |

- Sadece **aktif** paketler dönmeli (silinmiş / pasif olanlar hariç).
- `sort_order` varsa paketler bu alana göre sıralanmalı.

---

## 2. Jeton satın alımını doğrulama

Kullanıcı uygulamada Google Play üzerinden jeton paketi satın aldığında, uygulama satın alma bilgilerini bu endpoint’e gönderir. Backend, Google ile doğrulama yapıp kullanıcıya jeton eklemelidir.

### Endpoint

```
POST /api/coins/verify-purchase.php
```

**Headers:**  
- `Content-Type: application/json`  
- `Authorization: Bearer <token>`

**Body (JSON):**

```json
{
  "purchase_token": "google_play_purchase_token_string...",
  "product_id": "coins_100",
  "order_id": "GPA.1234-5678-9012-34567",
  "purchase_time": "2025-03-04T12:00:00.000Z",
  "type": "android"
}
```

| Alan             | Açıklama |
|------------------|----------|
| `purchase_token` | Google Play’den gelen doğrulama token’ı |
| `product_id`     | Satın alınan ürün ID’si (SKU) |
| `order_id`       | Sipariş / transaction ID |
| `purchase_time`  | Satın alma zamanı (ISO string) |
| `type`           | `"android"` veya `"ios"` |

### Doğrulama adımları (backend)

1. Kullanıcıyı token’dan tespit edin; yetkisiz ise 401 dönün.
2. **Android:** Google Play Developer API (Purchases.products.acknowledge / verify) ile `purchase_token` ve `product_id` doğrulayın.
3. **iOS:** App Store Server API ile receipt doğrulaması yapın (gerekirse receipt bu endpoint’e farklı bir alanla gönderilebilir).
4. **Çift kullanım:** Aynı `order_id` veya `purchase_token` ile daha önce jeton eklenmişse tekrar eklemeyin (idempotent davranın).
5. `product_id` (SKU) ile `coins/packages` veya kendi tablonuzdaki paket bilgisinden `coin_amount` değerini alın.
6. Kullanıcının mevcut jeton bakiyesine bu miktarı ekleyin ve güncel bakiyeyi hesaplayın.
7. (İsteğe bağlı) Bir `coin_transactions` tablosuna kayıt ekleyin: tip = satın alma, miktar, order_id, product_id, user_id, tarih.

### Başarılı yanıt (200)

```json
{
  "success": true,
  "new_balance": 150,
  "message": "Jetonlar hesabınıza eklendi."
}
```

- `new_balance`: Güncel toplam jeton bakiyesi (integer).

### Hata yanıtları

- **401:** Oturum yok veya geçersiz.
- **400:** Eksik alan, geçersiz token veya Google doğrulama hatası.

Örnek:

```json
{
  "success": false,
  "message": "Bu satın alma zaten işlendi."
}
```

---

## 3. Jeton ile kitap açma (mevcut endpoint – kilit davranışı)

Mevcut endpoint davranışı, “harcanan jetonlar iade edilmez” kuralına uygun olmalıdır.

### Endpoint

```
POST /api/books/unlock-with-coins.php
```

**Body:** `book_id` (premium kitap ID’si)

### Backend’de yapılması gerekenler

1. **Bakiye kontrolü:** Kitabın `coin_price` değeri kadar jeton bakiyesi var mı kontrol edin.
2. **Tek seferlik düşüm:** Bakiyeden jetonu düşün. Bu işlem **geri alınamaz** olmalı (iade ile bakiyeye tekrar ekleme yapılmamalı).
3. **Unlock kaydı:** Kullanıcı–kitap için unlock kaydı oluşturun (bitiş tarihi vb. mevcut mantığınız ne ise).
4. **İsteğe bağlı – harcama kilidi:**  
   - Bir `coin_transactions` (veya benzeri) tabloda her harcamayı `type = 'spent'` veya `refundable = 0` gibi işaretleyin.  
   - İade/iptal akışlarında sadece “satın alma” tipi işlemlere izin verin; “spent” kayıtlarına göre bakiye geri eklenmesin.

### Yanıt (mevcut uygulama beklentisi)

```json
{
  "success": true,
  "new_balance": 80,
  "expires_at": "2025-03-05T12:00:00.000Z",
  "message": "Kitap açıldı."
}
```

- `new_balance`: İşlem sonrası güncel jeton bakiyesi.

---

## 4. Admin panel – Jeton paketleri

Admin panelde jeton paketleri yönetimi için önerilen alanlar:

- **SKU (product id):** Google Play Console’da oluşturduğunuz consumable ürün ID’si (örn. `coins_100`, `coins_500`). Bu alan **zorunlu** ve **benzersiz** olmalı.
- **Jeton miktarı:** Paket başına verilecek jeton sayısı.
- **Başlık:** Kullanıcıya gösterilecek isim (örn. "100 Jeton").
- **Sıra:** Listeleme sırası (sort_order).
- **Durum:** Aktif / pasif (sadece aktif paketler `GET coins/packages.php` ile dönmeli).

Google Play Console’da her paket için **consumable** tipinde in-app product tanımlanmalı ve SKU’lar admin’e girilen SKU ile birebir aynı olmalıdır.

---

## 5. Özet kontrol listesi

- [ ] `GET /api/coins/packages.php` – Aktif paketleri döndürüyor (SKU, coin_amount, title, sort_order).
- [ ] `POST /api/coins/verify-purchase.php` – Token + product_id ile Google doğrulaması, çift kullanım engeli, bakiye güncellemesi, `new_balance` dönülüyor.
- [ ] `POST /api/books/unlock-with-coins.php` – Jeton düşümü geri alınamıyor; isteğe bağlı olarak harcama “spent” olarak işaretleniyor.
- [ ] Admin panelde jeton paketleri SKU ve jeton miktarı ile yönetilebiliyor; SKU’lar Google Play consumable ID’leri ile eşleşiyor.

Bu adımlar tamamlandığında uygulama tarafındaki jeton satın alma ve “iade edilmez” akışı backend ile uyumlu çalışır.
