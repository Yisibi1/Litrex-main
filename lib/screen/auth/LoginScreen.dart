import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../main.dart';
import '../../network/AuthApis.dart';
import '../../utils/Extensions/AppTextField.dart';
import '../../utils/Extensions/Commons.dart';
import '../../utils/Extensions/Widget_extensions.dart';
import '../../utils/Extensions/context_extensions.dart';
import '../../utils/Extensions/decorations.dart';
import '../../utils/Extensions/text_styles.dart';
import '../../utils/Extensions/shared_pref.dart';
import '../../utils/colors.dart';
import '../../utils/constant.dart';
import '../../utils/images.dart';
import '../ChooseTopicScreen.dart';
import 'ForgotPasswordScreen.dart';
import 'RegisterScreen.dart';
import '../DashboardScreen.dart';

class LoginScreen extends StatefulWidget {
  static String tag = '/LoginScreen';

  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  
  bool isLoading = false;
  bool rememberMe = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  Future<String?> _getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id; // unique ID on Android
    }
    return null;
  }

  Future<void> handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      
      try {
        String? deviceId = await _getDeviceId();
        
        final response = await loginUser(
          email: emailController.text.trim(),
          password: passwordController.text,
          deviceId: deviceId,
        );
        
        if (response.success == true && response.user != null) {
          log("Login API Response Status: ${response.user?.status}");
          if (response.user?.status == 'banned') {
            toast(language.lblAccountSuspended);
            return;
          }
          await authStore.setUser(response.user);
          await authStore.setAuthToken(response.token);
          await authStore.setLoggedIn(true);
          
          toast(language.lblLoginSuccess);
          
          if (getStringListAsync(chooseTopicList) != null) {
            DashboardScreen().launch(context, isNewTask: true);
          } else {
            ChooseTopicScreen(isVisibleBack: false).launch(context, isNewTask: true);
          }
        } else {
          toast(response.message ?? language.lblLoginFailed);
        }
      } catch (e) {
        toast(e.toString());
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => isLoading = true);
    
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      
      // Önceki oturumu kapat (farklı hesap seçebilmek için)
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        String? deviceId = await _getDeviceId();
        
        final response = await googleLogin(
          email: googleUser.email,
          displayName: googleUser.displayName ?? "",
          idToken: googleAuth.idToken,
          photoUrl: googleUser.photoUrl,
          deviceId: deviceId,
        );
        
        if (response.success == true && response.user != null) {
          log("Google Login API Response Status: ${response.user?.status}");
          if (response.user?.status == 'banned') {
            toast(language.lblAccountSuspended);
            return;
          }
          await authStore.setUser(response.user);
          await authStore.setAuthToken(response.token);
          await authStore.setLoggedIn(true);
          
          toast(language.lblLoginSuccess);
          
          if (getStringListAsync(chooseTopicList) != null) {
            DashboardScreen().launch(context, isNewTask: true);
          } else {
            ChooseTopicScreen(isVisibleBack: false).launch(context, isNewTask: true);
          }
        } else {
          toast(response.message ?? language.lblLoginFailed);
        }
      }
    } catch (e) {
      log(e.toString());
      toast("Google giriş hatası: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleAppleLogin() async {
    setState(() => isLoading = true);
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );
      String? deviceId = await _getDeviceId();
      String email = credential.email ?? '${credential.userIdentifier}@apple.id';
      String displayName = credential.givenName != null ? '${credential.givenName} ${credential.familyName ?? ''}'.trim() : 'Apple User';
      final response = await appleLogin(email: email, displayName: displayName, appleId: credential.userIdentifier ?? '', deviceId: deviceId);
      if (response.success == true && response.user != null) {
        if (response.user?.status == 'banned') {
          toast(language.lblAccountSuspended);
          return;
        }
        await authStore.setUser(response.user);
        await authStore.setAuthToken(response.token);
        await authStore.setLoggedIn(true);
        toast(language.lblLoginSuccess);
        if (getStringListAsync(chooseTopicList) != null) DashboardScreen().launch(context, isNewTask: true);
        else ChooseTopicScreen(isVisibleBack: false).launch(context, isNewTask: true);
      } else {
        toast(response.message ?? language.lblLoginFailed);
      }
    } catch (e) {
      log(e.toString());
      if (e.toString().contains('canceled')) toast('Giris iptal edildi.');
      else toast("Apple giris hatasi: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  } //

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.height();
    final screenWidth = context.width();
    final isSmallScreen = screenHeight < 700;
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: appStore.isDarkModeOn
                    ? [Color(0xFF1A1A2E), Color(0xFF16213E)]
                    : [primaryColor.withOpacity(0.08), Colors.white],
              ),
            ),
          ),
          
          // Decorative Circle
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryColor.withOpacity(0.3),
                    primaryColor.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: isSmallScreen ? 20 : 40),
                      
                      // Logo ve Başlık
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.4),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          ic_logo,
                          width: isSmallScreen ? 40 : 50,
                          height: isSmallScreen ? 40 : 50,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      Text(
                        language.lblWelcomeBack,
                        style: boldTextStyle(size: isSmallScreen ? 22 : 26),
                      ),
                      SizedBox(height: 4),
                      Text(
                        language.lblLoginToContinue,
                        style: secondaryTextStyle(size: 14),
                      ),
                      
                      Spacer(flex: 1),
                      
                      // Email Alanı
                      Container(
                        decoration: _inputContainerDecoration(),
                        child: AppTextField(
                          controller: emailController,
                          textFieldType: TextFieldType.EMAIL,
                          focus: emailFocus,
                          nextFocus: passwordFocus,
                          decoration: _inputDecoration(
                            hintText: language.lblEnterEmail,
                            prefixIcon: Icons.email_outlined,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      
                      // Şifre Alanı
                      Container(
                        decoration: _inputContainerDecoration(),
                        child: AppTextField(
                          controller: passwordController,
                          textFieldType: TextFieldType.PASSWORD,
                          focus: passwordFocus,
                          decoration: _inputDecoration(
                            hintText: language.lblEnterPassword,
                            prefixIcon: Icons.lock_outline,
                          ),
                          onFieldSubmitted: (s) => handleLogin(),
                        ),
                      ),
                      
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      
                      // Şifremi Unuttum
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => ForgotPasswordScreen().launch(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            language.lblForgotPassword,
                            style: primaryTextStyle(color: primaryColor, size: 13),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: isSmallScreen ? 16 : 24),
                      
                      // Giriş Butonu
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: radius(14),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  language.lblLogin,
                                  style: boldTextStyle(color: Colors.white, size: 15),
                                ),
                        ),
                      ),
                      
                      Spacer(flex: 1),
                      
                      // Veya şununla devam et
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.withOpacity(0.4))),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              language.lblOrContinueWith,
                              style: secondaryTextStyle(size: 12),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.withOpacity(0.4))),
                        ],
                      ),
                      
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      
                      // Google ve Apple Butonları
                      Row(
                        children: [
                          Expanded(
                            child: _buildSocialButton(
                              icon: Icons.g_mobiledata,
                              label: 'Google',
                              onTap: _handleGoogleLogin,
                              isGoogle: true,
                            ),
                          ),
                          if (Platform.isIOS || Platform.isMacOS) ...[ SizedBox(width: 12), Expanded( child: _buildSocialButton( icon: Icons.apple, label: 'Apple', onTap: _handleAppleLogin, isGoogle: false, ), ), ]
                        ],
                      ),
                      
                      Spacer(flex: 1),
                      
                      // Kayıt Ol Linki
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            language.lblDontHaveAccount,
                            style: primaryTextStyle(size: 13),
                          ),
                          TextButton(
                            onPressed: () => RegisterScreen().launch(context),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              minimumSize: Size.zero,
                            ),
                            child: Text(
                              language.lblRegister,
                              style: boldTextStyle(color: primaryColor, size: 14),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: isSmallScreen ? 8 : 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  BoxDecoration _inputContainerDecoration() {
    return BoxDecoration(
      color: appStore.isDarkModeOn ? Colors.white.withOpacity(0.1) : Colors.white,
      borderRadius: radius(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 15,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: secondaryTextStyle(size: 14),
      prefixIcon: Icon(prefixIcon, color: primaryColor.withOpacity(0.7), size: 20),
      border: OutlineInputBorder(borderRadius: radius(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: radius(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius(14),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isGoogle,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: radius(12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: appStore.isDarkModeOn ? Colors.white.withOpacity(0.1) : Colors.white,
          borderRadius: radius(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isGoogle
                ? Image.asset('asset/ic_google.png', width: 24, height: 24)
                : Icon(
                    icon,
                    size: 24,
                    color: appStore.isDarkModeOn ? Colors.white : Colors.black,
                  ),
            SizedBox(width: 8),
            Text(
              label,
              style: primaryTextStyle(size: 13),
            ),
          ],
        ),
      ),
    );
  }
}




