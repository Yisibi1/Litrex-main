# Litrex Uygulaması - Backend API Güncelleme Rehberi

Mobil uygulamada (Flutter tarafında) yapılan son geliştirmelerin ve anlık işlemlerin sorunsuz çalışabilmesi için backend (PHP/MySQL) tarafında yapılması gereken güncellemeler aşağıda 3 ana başlık altında toplanmıştır.

---

## 1. Video Reklam Jeton Ödülünü Dinamik Yapma
Uygulama içerisindeki "Video izle ve X Jeton kazan" özelliği artık API'den gelen dinamik veriye göre çalışmaktadır.

**A. Veritabanı Değişikliği:**
`app_configuration` (veya ilgili ayarlar tablosu) tablosuna ödül miktarını tutacak bir sütun ekleyin:
```sql
ALTER TABLE app_configuration ADD COLUMN ad_reward_coins INT DEFAULT 1;
```

**B. `dashboard.php` Güncellemesi:**
`dashboard.php` apisinin döndürdüğü JSON'daki `appconfiguration` nesnesi içerisine `ad_reward_coins` değerini ekleyin. Örnek JSON:
```json
{
  "appconfiguration": {
    "facebook": "...",
    "ad_reward_coins": 5
  }
}
```

**C. `coins/reward-ad.php` Güncellemesi:**
Kullanıcı reklamı izlediğinde jeton ekleyen bu dosyada, sabit `+1` jeton eklemek yerine `ad_reward_coins` değerini baz alarak kullanıcının bakiyesine ekleme yapın.

---

## 2. Anlık Kitap Erişim Kontrolü (Check Access API)
Kullanıcı bir kitabı daha önce jetonla açmışsa ve uygulamayı kapatıp açtığında kitabın tekrar kilitli görünmemesi için anlık doğrulama yapacak özel bir API endpoint'i oluşturulmalıdır.

**A. Yeni API Dosyası: `books/check-access.php`**
Aşağıdaki mantıkta çalışacak, `book_id` ve `user_id` POST parametrelerini alan bir script oluşturun:
```php
<?php
// 1. Kitap ücretsizse -> Açık dön.
// 2. Kullanıcı is_premium ise -> Açık dön.
// 3. Kullanıcı bu kitabı süreli/süresiz jetonla açmış mı (unlocked_books vb. tablodan) kontrol et.
//    - Süresi varsa ve geçmemişse -> Açık dön (expires_at ile birlikte).
// 4. Yukarıdakiler tutmuyorsa -> Kapalı dön.

// Örnek Başarılı Çıktı (Kitap Açık):
// { "success": true, "is_unlocked": true, "expires_at": "2026-03-08 15:00:00" }

// Örnek Başarısız Çıktı (Kitap Kilitli):
// { "success": true, "is_unlocked": false, "expires_at": null }
?>
```

---

## 3. Ödüllü Reklam (Rewarded Ads) ID'lerini Dinamik Yapma
Uygulamada gösterilen Ödüllü Video reklamlarının Key/ID'leri artık sabit değil, API üzerinden dinamik okunmaktadır.

**A. Veritabanı Değişikliği:**
`ads_configuration` tablomuza aşağıdaki sütunları ekleyin:
```sql
ALTER TABLE ads_configuration ADD COLUMN admob_rewarded_id VARCHAR(255) NULL;
ALTER TABLE ads_configuration ADD COLUMN admob_rewarded_id_ios VARCHAR(255) NULL;
ALTER TABLE ads_configuration ADD COLUMN facebook_rewarded_id VARCHAR(255) NULL;
ALTER TABLE ads_configuration ADD COLUMN facebook_rewarded_id_ios VARCHAR(255) NULL;
```

**B. `dashboard.php` Güncellemesi:**
`dashboard.php` apisinin döndürdüğü JSON'daki `adsconfiguration` nesnesi içerisine bu ID'leri ekleyin. Mobil uygulama bunları algılayıp doğrudan reklamlara yansıtacaktır.
```json
{
  "adsconfiguration": {
    "ads_type": "admob",
    "admob_rewarded_id": "YOUR_ADMOB_REWARDED_ID",
    "admob_rewarded_id_ios": "YOUR_ADMOB_REWARDED_ID_IOS",
    "facebook_rewarded_id": "YOUR_FB_REWARDED_ID",
    "facebook_rewarded_id_ios": "YOUR_FB_REWARDED_ID_IOS"
  }
}
```

---

**Not:** Mobil uygulama tarafı yukarıdaki tüm bu endpoint formatlarına, POST parametrelerine ve JSON yapılarına tam uyumlu olacak şekilde kodlanmıştır. Backend tarafını bu formata göre hazırlamanız yeterlidir.
