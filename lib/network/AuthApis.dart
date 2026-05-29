import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import '../main.dart';
import '../model/UserModel.dart';
import '../network/NetworkUtils.dart';
import '../utils/constant.dart';

/// Kullanıcı Girişi
Future<AuthResponse> loginUser({
  required String email,
  required String password,
  String? deviceId,
}) async {
  final response = await buildHttpResponse(
    'auth/login.php',
    method: HttpMethod.POST,
    request: {
      'email': email,
      'password': password,
      if (deviceId != null) 'device_id': deviceId,
    },
  );
  return AuthResponse.fromJson(await handleResponse(response));
}

/// Kullanıcı Kaydı
Future<AuthResponse> registerUser({
  required String name,
  required String email,
  required String password,
  String? phone,
  String? deviceId,
}) async {
  final response = await buildHttpResponse(
    'auth/register.php',
    method: HttpMethod.POST,
    request: {
      'name': name,
      'email': email,
      'password': password,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (deviceId != null) 'device_id': deviceId,
    },
  );
  return AuthResponse.fromJson(await handleResponse(response));
}

/// Şifre Sıfırlama İsteği
Future<Map<String, dynamic>> forgotPassword({
  required String email,
}) async {
  final response = await buildHttpResponse(
    'auth/forgot_password.php',
    method: HttpMethod.POST,
    request: {
      'email': email,
    },
  );
  return await handleResponse(response);
}

/// Şifre Sıfırlama (Token ile)
Future<Map<String, dynamic>> resetPassword({
  required String email,
  required String token,
  required String newPassword,
}) async {
  final response = await buildHttpResponse(
    'auth/reset_password.php',
    method: HttpMethod.POST,
    request: {
      'email': email,
      'token': token,
      'password': newPassword,
    },
  );
  return await handleResponse(response);
}

/// Profil Bilgilerini Al
Future<UserModel> getProfile() async {
  final response = await buildHttpResponse(
    'auth/profile.php',
    method: HttpMethod.GET,
  );
  final data = await handleResponse(response);
  return UserModel.fromJson(data['user']);
}

/// Profil Güncelle
Future<AuthResponse> updateProfile({
  required String name,
  String? phone,
  String? bio,
}) async {
  final response = await buildHttpResponse(
    'auth/update_profile.php',
    method: HttpMethod.POST,
    request: {
      'name': name,
      if (phone != null) 'phone': phone,
      if (bio != null) 'bio': bio,
    },
  );
  return AuthResponse.fromJson(await handleResponse(response));
}

/// Avatar Güncelle
Future<AuthResponse> updateAvatar({
  required File imageFile,
}) async {
  final request = MultipartRequest(
    'POST',
    Uri.parse('${mDomainUrl}auth/update_avatar.php'),
  );

  request.headers.addAll(buildHeaderTokens(endPoint: 'auth/update_avatar.php'));
  request.files.add(await MultipartFile.fromPath('avatar', imageFile.path));

  final streamedResponse = await request.send();
  final response = await Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    return AuthResponse.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Avatar yüklenemedi');
  }
}

/// Şifre Değiştir
Future<Map<String, dynamic>> changePassword({
  required String currentPassword,
  required String newPassword,
}) async {
  final response = await buildHttpResponse(
    'auth/change_password.php',
    method: HttpMethod.POST,
    request: {
      'current_password': currentPassword,
      'new_password': newPassword,
    },
  );
  return await handleResponse(response);
}

/// Çıkış Yap
Future<void> logoutUser() async {
  try {
    await buildHttpResponse(
      'auth/logout.php',
      method: HttpMethod.POST,
    );
  } catch (e) {
    // Sunucu hatası olsa bile local session'ı temizle
  }
  await authStore.logout();
}

/// Hesabı Sil
Future<Map<String, dynamic>> deleteAccount({
  required String password,
}) async {
  final response = await buildHttpResponse(
    'auth/delete_account.php',
    method: HttpMethod.POST,
    request: {
      'password': password,
    },
  );
  return await handleResponse(response);
}

/// Email Doğrulama Kodu Gönder
Future<Map<String, dynamic>> sendVerificationCode({
  required String email,
}) async {
  final response = await buildHttpResponse(
    'auth/send_verification.php',
    method: HttpMethod.POST,
    request: {
      'email': email,
    },
  );
  return await handleResponse(response);
}

/// Email Doğrulama Kodunu Onayla
Future<Map<String, dynamic>> verifyEmail({
  required String email,
  required String code,
}) async {
  final response = await buildHttpResponse(
    'auth/verify_email.php',
    method: HttpMethod.POST,
    request: {
      'email': email,
      'code': code,
    },
  );
  return await handleResponse(response);
}

/// Premium Durumunu Güncelle
Future<AuthResponse> updatePremiumStatus({
  required String purchaseToken,
  required String productId,
  required String orderId,
  required String purchaseTime,
}) async {
  final response = await buildHttpResponse(
    'OST_premium_status.php',
    method: HttpMethod.POST,
    request: {
      'purchase_token': purchaseToken,
      'product_id': productId,
      'order_id': orderId,
      'purchase_time': purchaseTime,
      'type': Platform.isAndroid ? 'android' : 'ios',
    },
  );
  return AuthResponse.fromJson(await handleResponse(response));
}

/// Google Giriş
Future<AuthResponse> googleLogin({
  required String email,
  required String displayName,
  String? idToken,
  String? photoUrl,
  String? deviceId,
}) async {
  final response = await buildHttpResponse(
    'auth/google_login.php',
    method: HttpMethod.POST,
    request: {
      'email': email,
      'name': displayName,
      if (idToken != null) 'id_token': idToken,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (deviceId != null) 'device_id': deviceId,
    },
  );
  return AuthResponse.fromJson(await handleResponse(response));
}
/// Cihaz Sıfırlama Kontrolü
Future<Map<String, dynamic>> checkDeviceReset({
  required String deviceId,
}) async {
  final response = await buildHttpResponse(
    'auth/check_reset.php',
    method: HttpMethod.POST,
    request: {
      'device_id': deviceId,
    },
  );
  return await handleResponse(response);
}

/// Seriya (Streak) Kontrolü
Future<Map<String, dynamic>> checkStreak() async {
  final response = await buildHttpResponse(
    'auth/check_streak.php',
    method: HttpMethod.GET,
  );
  return await handleResponse(response);
}
