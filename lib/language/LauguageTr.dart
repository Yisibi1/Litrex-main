import 'BaseLanguage.dart';
class LanguageTr extends BaseLanguage {
  @override
  String get lblCategory => "Kategoriler";

  @override
  String get lblFavourite => "Yer imleri";

  @override
  String get lblPopular => "Popüler Kitaplar";

  @override
  String get lblLatest => "Son Kitaplar";

  @override
  String get lblFeatured => "Öne çıkan kitaplar";

  @override
  String get lblSuggested => "Önerilen kitaplar";

  @override
  String get lblAboutUs => "Hakkımızda";

  @override
  String get lblPrivacyPolicy => "Gizlilik Politikası";

  @override
  String get lblTermsCondition => "Şartlar ve Koşullar";

  @override
  String get lblNoDataFound => "Veri bulunamadı";

  @override
  String get lblNoInternet => "İnternetiniz çalışmıyor";

  @override
  String get lblRateUs => "Bizi değerlendirin";

  @override
  String get lblDarkMode => "Karanlık mod";

  @override
  String get lblSystemDefault => "Sistem varsayılanı";

  @override
  String get lblLightMode => "Işık Modu";

  @override
  String get lblPushNotification => "Bildirimini devre dışı bırak";

  @override
  String get lblSearchBook => "Arama Kitabı";

  @override
  String get lblSetting => "Ayarlar";

  @override
  String get lblSeeMore => "Daha fazla gör";

  @override
  String get lblRemoveBookmark => "Bookmark'ı kaldırmak istediğinizden emin misiniz?";

  @override
  String get lblTryAgain => "Lütfen tekrar deneyin";

  @override
  String get lblReadBook => "Kitap oku";

  @override
  String get lblSelectTheme => "Tema seçin";

  @override
  String get lblChooseTopic => "Konu seçin";

  @override
  String get lblContinue => "Devam etmek";

  @override
  String get lblChooseTopicMsg => "Lütfen en az 3 konu seçin";

  @override
  String get lblChooseTopicTitle => "İlgilenen kategorinizi seçin";

  @override
  String get lblChooseTopicDesc => "Üç veya daha fazlasını seçin.";

  @override
  String get lblCancel => "İptal etmek";

  @override
  String get lblYes => "Evet";

  @override
  String get lblUrlEmpty => "URL boş";

  @override
  String get lblChooseTheme => "Uygulama Temanızı Seçin";

  @override
  String get lblDisableNotification => "Push bildirimlerini etkinleştir/devre dışı bırak";

  @override
  String get lblOthers => "Diğerleri";

  @override
  String get lblBy => "Yazar:";

  @override
  String get lblAuthors => "Yazarlar";

  @override
  String get lblAuthorsDes => "Kitaplarınızı yazarlar tarafından bulun";

  @override
  String get lblAbout => "Hakkında";

  @override
  String get lblBooksBy => "Kitapları";

  @override
  String get lblDescription => "Tanım";

  @override
  String get lblRemove => "Kaldırmak";

  @override
  String get lblWalk1 => "Litrex’e Hoş Geldin!";

  @override
  String get lblWalk1Desc => "Yeni çıkan kitapları keşfet, özetlerini oku ve edebiyat dünyasındaki yenilikleri takip et.";

  @override
  String get lblWalk2 => "Litrex ile Keyifli Okuma!";

  @override
  String get lblWalk2Desc => "Sade, hızlı ve eğlenceli bir okuma deneyimi seni bekliyor.";

  @override
  String get lblWalk3 => "Kitabınıza yer işareti koyun";

  @override
  String get lblWalk3Desc => "Favori bölümlerinizi kolayca işaretleyin, istediğiniz zaman geri dönün.";

  @override
  String get lblGetStarted => "Başlamak";

  @override
  String get lblSkip => "Atlamak";

  @override
  String get lblLanguage => "Dil Seçin";

  @override
  String get lblLanguageDesc => "Dilinizi seçin";

// YENİ EKLENENLER
  @override String get lblSearchAuthor => "Yazar Ara";
  @override String get lblNoAuthorsFound => "Yazar bulunamadı";

  // ==================== AUTH STRINGS ====================
  // Login Screen
  @override String get lblWelcomeBack => "Tekrar Hoş Geldin!";
  @override String get lblLoginToContinue => "Devam etmek için giriş yapın";
  @override String get lblEmail => "E-posta";
  @override String get lblEnterEmail => "E-posta adresinizi girin";
  @override String get lblPassword => "Şifre";
  @override String get lblEnterPassword => "Şifrenizi girin";
  @override String get lblRememberMe => "Beni Hatırla";
  @override String get lblForgotPassword => "Şifremi Unuttum";
  @override String get lblLogin => "Giriş Yap";
  @override String get lblOrContinueWith => "veya şununla devam et";
  @override String get lblDontHaveAccount => "Hesabınız yok mu?";
  @override String get lblRegister => "Kayıt Ol";
  @override String get lblLoginSuccess => "Giriş başarılı!";
  @override String get lblLoginFailed => "Giriş başarısız. Lütfen bilgilerinizi kontrol edin.";
  @override String get lblComingSoon => "Yakında eklenecek!";

  // Register Screen
  @override String get lblCreateAccount => "Hesap Oluştur";
  @override String get lblRegisterToGetStarted => "Başlamak için hesap oluşturun";
  @override String get lblFullName => "Ad Soyad";
  @override String get lblEnterFullName => "Adınızı ve soyadınızı girin";
  @override String get lblPhone => "Telefon";
  @override String get lblEnterPhone => "Telefon numaranızı girin";
  @override String get lblConfirmPassword => "Şifre Tekrar";
  @override String get lblReEnterPassword => "Şifrenizi tekrar girin";
  @override String get lblIAgreeToThe => "Kabul ediyorum";
  @override String get lblTermsOfService => "Kullanım Şartları";
  @override String get lblAnd => "ve";
  @override String get lblPleaseAcceptTerms => "Lütfen kullanım şartlarını kabul edin";
  @override String get lblPasswordsDoNotMatch => "Şifreler eşleşmiyor";
  @override String get lblRegistrationSuccess => "Kayıt başarılı! Hoş geldiniz!";
  @override String get lblRegistrationFailed => "Kayıt başarısız. Lütfen tekrar deneyin.";
  @override String get lblAlreadyHaveAccount => "Zaten hesabınız var mı?";

  // Forgot Password Screen
  @override String get lblVerifyCode => "Kodu Doğrula";
  @override String get lblNewPassword => "Yeni Şifre";
  @override String get lblSuccess => "Başarılı!";
  @override String get lblEnterEmailToReset => "Şifrenizi sıfırlamak için e-posta adresinizi girin";
  @override String get lblSendCode => "Kod Gönder";
  @override String get lblResetCodeSent => "Sıfırlama kodu e-posta adresinize gönderildi";
  @override String get lblSomethingWentWrong => "Bir şeyler yanlış gitti. Lütfen tekrar deneyin.";
  @override String get lblPleaseEnterEmail => "Lütfen e-posta adresinizi girin";
  @override String get lblEnterCodeSentToEmail => "E-postanıza gönderilen kodu girin";
  @override String get lblEnterVerificationCode => "Doğrulama kodunu girin";
  @override String get lblResendCode => "Kodu Tekrar Gönder";
  @override String get lblVerify => "Doğrula";
  @override String get lblEnterNewPassword => "Yeni şifrenizi girin";
  @override String get lblConfirmNewPassword => "Yeni şifrenizi onaylayın";
  @override String get lblPleaseEnterCode => "Lütfen doğrulama kodunu girin";
  @override String get lblPleaseEnterPassword => "Lütfen şifrenizi girin";
  @override String get lblPasswordTooShort => "Şifre en az 6 karakter olmalıdır";
  @override String get lblResetPassword => "Şifreyi Sıfırla";
  @override String get lblPasswordResetSuccess => "Şifreniz başarıyla değiştirildi!";
  @override String get lblBackToLogin => "Giriş Sayfasına Dön";

  // Profile Screen
  @override String get lblProfile => "Profil";
  @override String get lblEditProfile => "Profili Düzenle";
  @override String get lblUpdateYourInfo => "Bilgilerinizi güncelleyin";
  @override String get lblChangePassword => "Şifre Değiştir";
  @override String get lblUpdateYourPassword => "Şifrenizi güncelleyin";
  @override String get lblYourBookmarks => "Yer işaretlerinizi görüntüleyin";
  @override String get lblNotifications => "Bildirimler";
  @override String get lblManageNotifications => "Bildirimleri yönetin";
  @override String get lblHelpSupport => "Yardım ve Destek";
  @override String get lblGetHelp => "Yardım alın";
  @override String get lblLogout => "Çıkış Yap";
  @override String get lblLogoutConfirmation => "Çıkış yapmak istediğinizden emin misiniz?";
  @override String get lblLogoutSuccess => "Başarıyla çıkış yapıldı";
  @override String get lblDeleteAccount => "Hesabı Sil";
  @override String get lblDeleteAccountWarning => "Bu işlem geri alınamaz! Hesabınız ve tüm verileriniz kalıcı olarak silinecektir.";
  @override String get lblEnterPasswordToConfirm => "Onaylamak için şifrenizi girin";
  @override String get lblAccountDeleted => "Hesabınız başarıyla silindi";
  @override String get lblDelete => "Sil";
  @override String get lblNotLoggedIn => "Giriş Yapılmadı";
  @override String get lblLoginToAccessProfile => "Profilinize erişmek için lütfen giriş yapın";
  @override String get lblBio => "Hakkımda";
  @override String get lblBooksRead => "Okunan";
  @override String get lblBookmarks => "Yer İmi";
  @override String get lblFavorites => "Favori";
  @override String get lblCurrentPassword => "Mevcut Şifre";
  @override String get lblPasswordChangedSuccess => "Şifreniz başarıyla değiştirildi!";
  @override String get lblUpdate => "Güncelle";

  // Edit Profile Screen
  @override String get lblEnterBio => "Kendinizden bahsedin...";
  @override String get lblSaveChanges => "Değişiklikleri Kaydet";
  @override String get lblProfileUpdated => "Profiliniz başarıyla güncellendi!";
  @override String get lblAvatarUpdated => "Profil fotoğrafınız güncellendi!";
  @override String get lblChoosePhoto => "Fotoğraf Seç";
  @override String get lblCamera => "Kamera";
  @override String get lblGallery => "Galeri";
  
  // Offline Reading / Downloads
  @override String get lblDownloads => "İndirilenler";
  @override String get lblOfflineLibrary => "Çevrimdışı Kütüphane";
  @override String get lblYouHave => "";
  @override String get lblDownloadedBooks => "indirilmiş kitabınız var";
  @override String get lblTapToStartReading => "Tıklayarak okumaya başlayın";
  @override String get lblNoDownloadedBooks => "İndirilmiş kitap bulunamadı";
  @override String get lblDownloadToReadOffline => "Çevrimdışı okumak için kitap indirin";
  @override String get lblRemoveDownloadTitle => "İndirmeyi Kaldır?";
  @override String get lblRemoveDownloadMsg => "Bu kitabı çevrimdışı depolama alanından kaldırmak istediğinizden emin misiniz?";
  @override String get lblDeleteBookTitle => "Kitabı Sil?";
  @override String get lblDeleteBookMsg => "Bu kitabı indirilenlerden kaldırmak istediğinizden emin misiniz?";
  @override String get lblDownloadComplete => "İndirme Tamamlandı";
  @override String get lblDownloadFailed => "İndirme Başarısız";
  @override String get lblOfflineReadToast => "Çevrimdışı kütüphanenizden okumaya başlayın.";
  @override String get lblErrorOpeningBook => "Kitap açılırken hata oluştu. Dosya bozuk olabilir.";
  @override String get lblUnknownTitle => "Bilinmeyen Başlık";
  @override String get lblDeviceResetByAdmin => "Cihazınız yönetici tarafından sıfırlandı.";
  @override String get lblAccountSuspended => "Hesabınız askıya alınmıştır. Lütfen destek ile iletişime geçin.";
  @override String get lblGetPremiumToRead => "Okumak İçin Premium Alın";
  @override String get lblYouArePremium => "Premium Üyesiniz";
  @override String get lblPremiumDesc => "Sınırsız okumanın keyfini çıkarın";
  
  // Support Screen
  @override String get lblSubject => "Konu";
  @override String get lblEnterSubject => "Konuyu girin";
  @override String get lblMessage => "Mesaj";
  @override String get lblEnterMessage => "Mesajınızı girin";
  @override String get lblSend => "Gönder";
  @override String get lblMessageSent => "Mesajınız başarıyla gönderildi.";
  @override String get lblSending => "Gönderiliyor...";
  @override String get lblFailedToSend => "Mesaj gönderilemedi. Lütfen tekrar deneyin.";

  // Eklentiler
  @override String get lblAddons => "Eklentiler";
  @override String get lblAddonConnected => "harici kütüphane bağlı";
  @override String get lblAddonConnectHarici => "Harici kitap kütüphanesi ekle";
  @override String get lblAddonConnectedStatus => "Bağlı";
  @override String get lblAddonDisconnectedStatus => "Bağlı Değil";
  @override String get lblAddonManager => "Eklenti Yöneticisi";
  @override String get lblNoAddonsYet => "Henüz harici kütüphane eklenmedi.";
  @override String get lblAddonDeleted => "Eklenti silindi.";
  @override String get lblClose => "Kapat";
  @override String get lblSave => "Kaydet";
  @override String get lblAddNewAddon => "Yeni Eklenti Ekle";
  @override String get lblEnterManifestUrl => "Harici içerik manifest.json linkini girin.";
  @override String get lblAddonHint => "Örnek: https://example.com/addon.json";
  @override String get lblAddonAddedSuccess => "Yeni eklenti başarıyla eklendi!";
  @override String get lblUrlAlreadyExists => "Bu URL zaten eklenmiş!";
  @override String get lblUrlCannotBeEmpty => "URL boş olamaz!";
  @override String get lblMaxAddonsLimit => "En fazla 5 eklenti eklenebilir!";
  @override String get lblAdLoadingWait => "Reklam şu anda yükleniyor, lütfen birkaç saniye sonra tekrar deneyin.";

  // Monetizasiya / Reklam Limiti
  @override String get lblDailyAdLimitReached => "Günlük Limit Doldu!";
  @override String get lblDailyAdLimitMsg => "Reklam izleme limitiniz doldu. Lütfen belirtilen süre sonra tekrar deneyin veya Premium alın.";
  @override String get lblGetPremiumNow => "Premiuma Geç";
  @override String get lblOfflineBlockTitle => "İnternet Bağlantısı Gerekli";
  @override String get lblOfflineBlockMsg => "Bu kitabı okumak için internet bağlantısı gereklidir. Premium üye olarak çevrimdışı okuyabilirsiniz.";
  @override String get lblDownloadPremiumOnly => "İndirme özelliği yalnızca Premium üyelere açıktır.";

  @override String get lblTimeUntilReset => "YENİLENMEYE KALAN SÜRE";
  @override String get lblBuyCoins => "Jeton Al";
  @override String get lblLimitReached => "Limit Doldu: ";
  @override String get lblGoToPremium => "Premiuma Geç";
  @override String get lblChecking => "Kontrol ediliyor...";
  @override String get lblWatchVideoToEarn => "Video izle ve ";
  @override String get lblCoins => " Jeton kazan";

  @override String get lblUpdateAvailable => "Güncelleme Mevcut";
  @override String get lblUpdateRequiredMsg => "Uygulamanın yeni bir sürümü mevcut. Devam etmek için lütfen güncelleyin.";
  @override String get lblUpdateNow => "Şimdi Güncelle";

  @override String get lblRateUsTitle => "Bize Değer Verin!";
  @override String get lblRateUsMsg => "Uygulamamızı beğendiyseniz, lütfen bize 5 yıldız vererek destek olun!";
  @override String get lblRateNow => "Değerlendir";
  @override String get lblMaybeLater => "Daha Sonra";
}
