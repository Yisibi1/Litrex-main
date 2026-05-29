import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../screen/auth/LoginScreen.dart';
import '../main.dart';
import '../utils/Extensions/Commons.dart';


import '../utils/Extensions/int_extensions.dart';
import '../utils/constant.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

import '../utils/Extensions/Constants.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/network_utils.dart';
import '../utils/Extensions/string_extensions.dart';
import '../utils/Extensions/shared_pref.dart';

Map<String, String> buildHeaderTokens({String? endPoint}) {
  Map<String, String> header = {
    HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    HttpHeaders.cacheControlHeader: 'no-cache',
    HttpHeaders.acceptHeader: 'application/json; charset=utf-8',
    'Access-Control-Allow-Headers': '*',
    'Access-Control-Allow-Origin': '*',
    'App-Version': getStringAsync('CURRENT_APP_VERSION_CODE'),
  };

  // Auth ile ilgili uç noktaların listesi
  List<String> authEndpoints = [
    'auth/login.php',
    'auth/register.php',
    'auth/google_login.php',
    'auth/forgot_password.php',
    'auth/reset_password.php',
    'auth/send_verification.php',
    'auth/verify_email.php',
    'auth/check_reset.php'
  ];

  // Eğer istek bir auth uç noktasına değilse token ekle
  bool isAuthRequest = endPoint != null && authEndpoints.any((element) => endPoint.contains(element));

  if (!isAuthRequest) {
    // Token yüklenmemişse ama oturum açıksa prefs'ten çekmeyi dene
    if (authStore.authToken.validate().isEmpty && authStore.isLoggedIn) {
      authStore.authToken = getStringAsync(AUTH_TOKEN);
    }

    if (authStore.authToken.validate().isNotEmpty) {
      header.putIfAbsent(HttpHeaders.authorizationHeader, () => 'Bearer ${authStore.authToken}');
    }
  }

  log("Request Headers (Endpoint: $endPoint): ${jsonEncode(header)}");
  return header;
}

Uri buildBaseUrl(String endPoint) {
  Uri url = Uri.parse(endPoint);
  if (!endPoint.startsWith('http')) url = Uri.parse('$mDomainUrl$endPoint');

  log('URL: ${url.toString()}');

  return url;
}

Future<Response> buildHttpResponse(String endPoint, {HttpMethod method = HttpMethod.GET, Map? request}) async {
  if (await isNetworkAvailable()) {
    var headers = buildHeaderTokens(endPoint: endPoint);
    Uri url = buildBaseUrl(endPoint);

    Response response;

    if (method == HttpMethod.POST) {
      log('Request: $request');
      response = await http.post(url, body: jsonEncode(request), headers: headers);
    } else if (method == HttpMethod.DELETE) {
      response = await delete(url, headers: headers);
    } else if (method == HttpMethod.PUT) {
      response = await put(url, body: jsonEncode(request), headers: headers);
    } else {
      response = await get(url, headers: headers);
    }

    log('Response ($method): ${response.statusCode} ${response.body}');

    return response;
  } else {
    throw errorInternetNotAvailable;
  }
}

@deprecated
Future<Response> getRequest(String endPoint) async => buildHttpResponse(endPoint);

@deprecated
Future<Response> postRequest(String endPoint, Map request) async => buildHttpResponse(endPoint, request: request, method: HttpMethod.POST);

Future handleResponse(Response response) async {
  if (!await isNetworkAvailable()) {
    throw errorInternetNotAvailable;
  }
  

  // 401 Unauthorized: Token süresi dolmuş veya geçersiz
  if (response.statusCode == 401) {
    await authStore.forceLogout();
    toast('Oturumunuzun süresi dolduğu için tekrar giriş yapmanız gerekiyor.');
    
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    }
    
    throw 'Oturumunuzun süresi dolduğu için tekrar giriş yapmanız gerekiyor.';
  }

  // 409 Conflict: Başka cihazda oturum açıldı
  if (response.statusCode == 409) {
    await authStore.forceLogout();
    
    toast('Oturumunuz başka bir cihazda açıldığı için sonlandırıldı.');
    
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    }
    
    throw 'Oturumunuz başka bir cihazda açıldığı için sonlandırıldı.';
  }

  if (response.statusCode.isSuccessful()) {
    return jsonDecode(response.body);
  } else {
    var string = await (isJsonValid(response.body));
    if (string!.isNotEmpty) {
      throw string;
    } else {
      throw 'Please try again later.';
    }
  }
}

//region Common
enum HttpMethod { GET, POST, DELETE, PUT }

class TokenException implements Exception {
  final String message;

  const TokenException([this.message = ""]);

  @override
  String toString() => "FormatException: $message";
}
//endregion

Future<String?> isJsonValid(json) async {
  try {
    var f = jsonDecode(json) as Map<String, dynamic>;
    return f[msg];
  } catch (e) {
    log(e.toString());
    return "";
  }
}

Future<http.Response> httpGetWithAddonHeaders(String url, {Duration timeout = const Duration(seconds: 10)}) async {
  return http.get(
    Uri.parse(url),
    headers: {
      'User-Agent': 'LitrexOfficialApp/1.0',
      'X-OLibrary-Key': 'Litrex_Secret_Addon_Token_2026_Secure',
    },
  ).timeout(timeout);
}
