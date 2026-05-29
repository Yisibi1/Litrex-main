# Jeton Satın Alma – Test Planı ve Test Senaryoları

Bu doküman, jeton satın alma ve jeton harcama özelliği için yazılan testleri ve manuel test senaryolarını listeler.

---

## 1. Otomatik testler (unit + widget)

### 1.1 Model: `test/model/coin_package_model_test.dart`

| Test | Açıklama |
|------|----------|
| Tüm alanlar dolu map ile doğru parse | `fromJson` ile id, sku, coin_amount, title, sort_order, currency, display_price doğru atanır |
| String id ve coin_amount | API bazen sayıları string gönderir; string'den int parse edilir |
| Eksik alanlar null | Eksik key'ler null olur, uygulama çökmez |
| Boş map | Boş map ile çökmez |
| toJson round-trip | fromJson → toJson ile alanlar korunur |
| toJson null alanlar | Sadece dolu alanlarla toJson üretilir |

### 1.2 API parsing: `test/network/coin_packages_parsing_test.dart`

| Test | Açıklama |
|------|----------|
| List yanıtı | `[{...}, {...}]` formatı ile iki paket parse edilir |
| Map + packages | `{ "packages": [...] }` formatı ile liste alınır |
| Boş List | `[]` → boş liste |
| packages null/yok | Map'te packages yok veya null → boş liste |
| Geçersiz tip (string) | `"invalid"` → boş liste |
| null | `null` → boş liste |
| String sayılar | List içinde id/coin_amount/sort_order string ise int'e çevrilir |

### 1.3 Widget: `test/widget/coin_balance_component_test.dart`

| Test | Açıklama |
|------|----------|
| Bakiye gösterimi | `authStore.coins = 10` iken "10" metni görünür |
| Tıklanabilir alan | InkWell bulunur (jeton alanına tıklanabilir) |
| onTapForTesting | Test callback verildiğinde tıklanınca callback çağrılır, gerçek ekran açılmaz |
| Observer güncellemesi | Bakiye 10 → 25 yapılınca ekranda 25 görünür |

**Çalıştırma:**
```bash
flutter test test/model/coin_package_model_test.dart
flutter test test/network/coin_packages_parsing_test.dart
flutter test test/widget/coin_balance_component_test.dart
# veya hepsi:
flutter test test/
```

---

## 2. Manuel / entegrasyon test senaryoları

### 2.1 Jeton satın alma ekranı (CoinPurchaseScreen)

| # | Senaryo | Adımlar | Beklenen |
|---|---------|---------|----------|
| M1 | Paket listesi boş | Giriş yap → Header’da jetonlara tıkla | "Henüz jeton paketi yok" mesajı, uyarı metni (iade edilmez) görünür |
| M2 | Paket listesi dolu | Backend’de paket var, API dönüyor → Ekran aç | Paketler listelenir; her satırda jeton miktarı ve fiyat (Google’dan veya display_price) |
| M3 | Mağaza kapalı | Uçak modu veya Play Hizmetleri yok → Ekran aç | "Mağaza bağlantısı yok" uyarısı, paketler fiyatsız veya — ile |
| M4 | Satın alma başlat | Bir pakete tıkla | Google ödeme ekranı açılır |
| M5 | Satın alma iptal | Ödeme ekranında iptal et | "İşlem iptal edildi." toast, bakiye değişmez |
| M6 | Satın alma tamamla | Ödemeyi tamamla (test kartı) | "Jetonlar hesabınıza eklendi." toast, header’daki bakiye artar |
| M7 | Oturum yok | Çıkış yap → Jeton satın al ekranına git → (test için satın almayı tetikle) | "Oturum açmanız gerekiyor." veya benzeri uyarı |
| M8 | İade uyarısı | Ekranı aç | Altta "Satın alınan jetonlar kullanıldığında (kitap açma vb.) iade edilmez." metni görünür |

### 2.2 Header ve yönlendirme

| # | Senaryo | Adımlar | Beklenen |
|---|---------|---------|----------|
| M9 | Header’dan jeton satın alma | Ana sayfada header’daki jeton bakiyesine tıkla | Jeton satın alma ekranı açılır |
| M10 | Modal’dan jeton satın al | Premium kilitli kitap aç → "Jeton ile Aç" modal → "Jeton satın al" butonuna tıkla | Modal kapanır, jeton satın alma ekranı açılır |

### 2.3 Jeton ile kitap açma ve iade uyarısı

| # | Senaryo | Adımlar | Beklenen |
|---|---------|---------|----------|
| M11 | Yeterli jeton – onay diyaloğu | Premium kitap → Jeton ile Aç → "Aç" butonuna bas | "Bu kitap için X jeton harcanacak. Harcanan jetonlar iade edilmez. Devam etmek istiyor musunuz?" diyaloğu çıkar |
| M12 | Onayla harca | Diyaloğda "Evet, harca" | Kitap açılır, bakiye düşer, toast: "Kitap başarıyla açıldı!" |
| M13 | İptal et | Diyaloğda "İptal" | Modal açık kalır, jeton harcanmaz |
| M14 | Yetersiz jeton | Bakiyen kitap fiyatından az → Premium kitap → Jeton ile Aç | "Yetersiz" buton, "Jeton satın al" butonu görünür; tıklanınca jeton satın alma ekranına gider |

### 2.4 Backend / API

| # | Senaryo | Adımlar | Beklenen |
|---|---------|---------|----------|
| M15 | GET coins/packages | API’yi doğrudan çağır (Postman/curl) | 200, liste veya `{ "packages": [...] }` |
| M16 | POST verify-purchase | Geçerli token ile istek at | 200, `success: true`, `new_balance` güncel |
| M17 | Aynı token tekrar | Aynı purchase_token ile ikinci istek | Çift jeton eklenmez (idempotent), uygun hata veya aynı new_balance |
| M18 | Unlock-with-coins | Jetonla kitap aç → API’de bakiye | Bakiye bir kez düşer, iade/rollback ile tekrar eklenmez |

---

## 3. Hızlı kontrol listesi (release öncesi)

- [ ] `flutter test test/model/coin_package_model_test.dart` geçiyor
- [ ] `flutter test test/network/coin_packages_parsing_test.dart` geçiyor
- [ ] `flutter test test/widget/coin_balance_component_test.dart` geçiyor
- [ ] Header’da jetonlara tıklanınca CoinPurchaseScreen açılıyor (M9)
- [ ] Modal’da "Jeton satın al" → CoinPurchaseScreen (M10)
- [ ] Jetonla kitap açarken "iade edilmez" onay diyaloğu çıkıyor (M11–M13)
- [ ] Satın alma sonrası bakiye güncelleniyor (M6)
- [ ] Backend verify-purchase çift kullanımı engelliyor (M17)

Bu doküman, `docs/API_COIN_PURCHASE.md` ile birlikte kullanılabilir.
