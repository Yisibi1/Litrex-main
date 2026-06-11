import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
import '../DashboardScreen.dart';
import '../WebViewScreen.dart';

class RegisterScreen extends StatefulWidget {
  static String tag = '/RegisterScreen';

  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  FocusNode nameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();

  bool isLoading = false;
  bool acceptTerms = false;
  int _currentStep = 0; // 0: Kişisel bilgiler, 1: Şifre ve onay

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameFocus.dispose();
    emailFocus.dispose();
    phoneFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<String?> _getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor;
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id;
    }
    return null;
  }

  void _nextStep() {
    if (_currentStep == 0) {
      // İlk adım validasyonu
      if (nameController.text.trim().isEmpty) {
        toast(language.lblEnterFullName);
        return;
      }
      if (emailController.text.trim().isEmpty || !emailController.text.contains('@')) {
        toast(language.lblEnterEmail);
        return;
      }
      
      setState(() => _currentStep = 1);
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _animationController.reset();
      _animationController.forward();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> handleRegister() async {
    if (!acceptTerms) {
      toast(language.lblPleaseAcceptTerms);
      return;
    }

    if (passwordController.text.isEmpty) {
      toast(language.lblEnterPassword);
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      toast(language.lblPasswordsDoNotMatch);
      return;
    }

    if (passwordController.text.length < 6) {
      toast(language.lblPasswordTooShort);
      return;
    }

    setState(() => isLoading = true);

    try {
      String? deviceId = await _getDeviceId();

      final response = await registerUser(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        phone: phoneController.text.trim(),
        deviceId: deviceId,
      );

      if (response.success == true && response.user != null) {
        await authStore.setUser(response.user);
        await authStore.setAuthToken(response.token);
        await authStore.setLoggedIn(true);

        toast(language.lblRegistrationSuccess);
        ChooseTopicScreen(isVisibleBack: false).launch(context, isNewTask: true);
      } else {
        toast(response.message ?? language.lblRegistrationFailed);
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

Future<void> _handleGoogleRegister() async {
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = context.height();
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
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: appStore.isDarkModeOn
                    ? [Color(0xFF1A1A2E), Color(0xFF16213E)]
                    : [Colors.white, primaryColor.withOpacity(0.08)],
              ),
            ),
          ),

          // Decorative Circle
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
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
              child: Column(
                children: [
                  SizedBox(height: isSmallScreen ? 16 : 30),

                  // Başlık
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
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
                      width: isSmallScreen ? 35 : 45,
                      height: isSmallScreen ? 35 : 45,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 10 : 14),
                  Text(
                    language.lblCreateAccount,
                    style: boldTextStyle(size: isSmallScreen ? 20 : 24),
                  ),
                  SizedBox(height: 4),
                  Text(
                    language.lblRegisterToGetStarted,
                    style: secondaryTextStyle(size: 13),
                  ),

                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Step Indicators
                  _buildStepIndicators(),

                  SizedBox(height: isSmallScreen ? 20 : 28),

                  // Form Content
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _currentStep == 0
                          ? _buildStep1()
                          : _buildStep2(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Geri Butonu
          Positioned(
            top: context.statusBarHeight + 10,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: appStore.isDarkModeOn
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: _previousStep,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildStepIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepDot(0, language.lblFullName.split(' ')[0]),
        Container(
          width: 40,
          height: 2,
          color: _currentStep >= 1 ? primaryColor : Colors.grey.withOpacity(0.3),
        ),
        _buildStepDot(1, language.lblPassword),
      ],
    );
  }

  Widget _buildStepDot(int step, String label) {
    bool isActive = _currentStep >= step;
    bool isCurrent = _currentStep == step;

    return Column(
      children: [
        Container(
          width: isCurrent ? 32 : 28,
          height: isCurrent ? 32 : 28,
          decoration: BoxDecoration(
            color: isActive ? primaryColor : Colors.grey.withOpacity(0.3),
            shape: BoxShape.circle,
            boxShadow: isCurrent
                ? [BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 8)]
                : null,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: boldTextStyle(
                color: isActive ? Colors.white : Colors.grey,
                size: 13,
              ),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: secondaryTextStyle(
            size: 11,
            color: isActive ? primaryColor : Colors.grey,
          ),
        ),
      ],
    );
  }

  // STEP 1: Kişisel Bilgiler
  Widget _buildStep1() {
    final isSmallScreen = context.height() < 700;

    return Column(
      children: [
        // Ad Soyad
        Container(
          decoration: _inputContainerDecoration(),
          child: AppTextField(
            controller: nameController,
            textFieldType: TextFieldType.NAME,
            focus: nameFocus,
            nextFocus: emailFocus,
            decoration: _inputDecoration(
              hintText: language.lblEnterFullName,
              prefixIcon: Icons.person_outline,
            ),
          ),
        ),

        SizedBox(height: isSmallScreen ? 12 : 16),

        // Email
        Container(
          decoration: _inputContainerDecoration(),
          child: AppTextField(
            controller: emailController,
            textFieldType: TextFieldType.EMAIL,
            focus: emailFocus,
            nextFocus: phoneFocus,
            decoration: _inputDecoration(
              hintText: language.lblEnterEmail,
              prefixIcon: Icons.email_outlined,
            ),
          ),
        ),

        SizedBox(height: isSmallScreen ? 12 : 16),

        // Telefon (Opsiyonel)
        Container(
          decoration: _inputContainerDecoration(),
          child: AppTextField(
            controller: phoneController,
            textFieldType: TextFieldType.PHONE,
            focus: phoneFocus,
            isValidationRequired: false,
            decoration: _inputDecoration(
              hintText: '${language.lblEnterPhone} (${language.lblOthers})',
              prefixIcon: Icons.phone_outlined,
            ),
          ),
        ),

        Spacer(),

        // Sosyal Kayıt
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

        SizedBox(height: isSmallScreen ? 12 : 16),

        Row(
          children: [
Expanded(
              child: _buildSocialButton(
                icon: Icons.g_mobiledata,
                label: 'Google',
                onTap: _handleGoogleRegister,
                isGoogle: true,
              ),
            ),
          ],
        ),

        Spacer(),

        // İleri Butonu
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: radius(14)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(language.lblContinue, style: boldTextStyle(color: Colors.white, size: 15)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),

        SizedBox(height: isSmallScreen ? 12 : 20),

        // Giriş Yap Linki
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(language.lblAlreadyHaveAccount, style: primaryTextStyle(size: 13)),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
              ),
              child: Text(
                language.lblLogin,
                style: boldTextStyle(color: primaryColor, size: 14),
              ),
            ),
          ],
        ),

        SizedBox(height: isSmallScreen ? 8 : 16),
      ],
    );
  }

  // STEP 2: Şifre ve Onay
  Widget _buildStep2() {
    final isSmallScreen = context.height() < 700;

    return Column(
      children: [
        // Şifre
        Container(
          decoration: _inputContainerDecoration(),
          child: AppTextField(
            controller: passwordController,
            textFieldType: TextFieldType.PASSWORD,
            focus: passwordFocus,
            nextFocus: confirmPasswordFocus,
            decoration: _inputDecoration(
              hintText: language.lblEnterPassword,
              prefixIcon: Icons.lock_outline,
            ),
          ),
        ),

        SizedBox(height: isSmallScreen ? 12 : 16),

        // Şifre Tekrar
        Container(
          decoration: _inputContainerDecoration(),
          child: AppTextField(
            controller: confirmPasswordController,
            textFieldType: TextFieldType.PASSWORD,
            focus: confirmPasswordFocus,
            decoration: _inputDecoration(
              hintText: language.lblReEnterPassword,
              prefixIcon: Icons.lock_outline,
            ),
          ),
        ),

        SizedBox(height: isSmallScreen ? 16 : 24),

        // Kullanım Şartları
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 22,
              width: 22,
              child: Checkbox(
                value: acceptTerms,
                onChanged: (val) => setState(() => acceptTerms = val ?? false),
                activeColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: radius(5)),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: primaryTextStyle(size: 13),
                  children: [
                    TextSpan(text: '${language.lblIAgreeToThe} '),
                    TextSpan(
                      text: language.lblTermsOfService,
                      style: boldTextStyle(color: primaryColor, size: 13),
                      recognizer: TapGestureRecognizer()..onTap = () {
                        if (getStringAsync(TERMS_AND_CONDITION_PREF).isNotEmpty) {
                          WebViewScreen(title: language.lblTermsOfService, mInitialUrl: getStringAsync(TERMS_AND_CONDITION_PREF)).launch(context);
                        } else {
                          toast(language.lblUrlEmpty);
                        }
                      },
                    ),
                    TextSpan(text: ' ${language.lblAnd} '),
                    TextSpan(
                      text: language.lblPrivacyPolicy,
                      style: boldTextStyle(color: primaryColor, size: 13),
                      recognizer: TapGestureRecognizer()..onTap = () {
                        if (getStringAsync(PRIVACY_POLICY_PREF).isNotEmpty) {
                          WebViewScreen(title: language.lblPrivacyPolicy, mInitialUrl: getStringAsync(PRIVACY_POLICY_PREF)).launch(context);
                        } else {
                          toast(language.lblUrlEmpty);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        Spacer(),

        // Kayıt Ol Butonu
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: acceptTerms && !isLoading ? handleRegister : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: acceptTerms ? primaryColor : Colors.grey,
              shape: RoundedRectangleBorder(borderRadius: radius(14)),
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
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add_outlined, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        language.lblRegister,
                        style: boldTextStyle(color: Colors.white, size: 15),
                      ),
                    ],
                  ),
          ),
        ),

        SizedBox(height: isSmallScreen ? 12 : 20),

        // Giriş Yap Linki
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(language.lblAlreadyHaveAccount, style: primaryTextStyle(size: 13)),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
              ),
              child: Text(
                language.lblLogin,
                style: boldTextStyle(color: primaryColor, size: 14),
              ),
            ),
          ],
        ),

        SizedBox(height: isSmallScreen ? 8 : 16),
      ],
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
        height: 46,
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
            Icon(
              icon,
              size: isGoogle ? 26 : 20,
              color: isGoogle ? Colors.red : (appStore.isDarkModeOn ? Colors.white : Colors.black),
            ),
            SizedBox(width: 8),
            Text(label, style: primaryTextStyle(size: 13)),
          ],
        ),
      ),
    );
  }
}
