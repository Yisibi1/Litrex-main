import 'package:flutter/material.dart';
import '../../main.dart';
import '../../network/AuthApis.dart';
import '../../utils/Extensions/AppButton.dart';
import '../../utils/Extensions/AppTextField.dart';
import '../../utils/Extensions/Commons.dart';
import '../../utils/Extensions/context_extensions.dart';
import '../../utils/Extensions/decorations.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../utils/Extensions/text_styles.dart';
import '../../utils/colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static String tag = '/ForgotPasswordScreen';

  const ForgotPasswordScreen({super.key});

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  int _currentStep = 0;

  // 0: Email giriş
  // 1: Kod doğrulama
  // 2: Yeni şifre belirleme
  // 3: Başarılı

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
    codeController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Step 1: Email ile kod gönder
  Future<void> handleSendCode() async {
    if (emailController.text.trim().isEmpty) {
      toast(language.lblPleaseEnterEmail);
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await forgotPassword(email: emailController.text.trim());

      if (response['success'] == true) {
        toast(language.lblResetCodeSent);
        setState(() => _currentStep = 1);
        _animationController.reset();
        _animationController.forward();
      } else {
        toast(response['message'] ?? language.lblSomethingWentWrong);
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Step 2: Kodu doğrula
  Future<void> handleVerifyCode() async {
    if (codeController.text.trim().isEmpty) {
      toast(language.lblPleaseEnterCode);
      return;
    }

    setState(() => _currentStep = 2);
    _animationController.reset();
    _animationController.forward();
  }

  // Step 3: Yeni şifre belirle
  Future<void> handleResetPassword() async {
    if (newPasswordController.text.isEmpty) {
      toast(language.lblPleaseEnterPassword);
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      toast(language.lblPasswordsDoNotMatch);
      return;
    }

    if (newPasswordController.text.length < 6) {
      toast(language.lblPasswordTooShort);
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await resetPassword(
        email: emailController.text.trim(),
        token: codeController.text.trim(),
        newPassword: newPasswordController.text,
      );

      if (response['success'] == true) {
        setState(() => _currentStep = 3);
        _animationController.reset();
        _animationController.forward();
      } else {
        toast(response['message'] ?? language.lblSomethingWentWrong);
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: appStore.isDarkModeOn
                    ? [Color(0xFF1A1A2E), Color(0xFF16213E)]
                    : [Colors.white, primaryColor.withOpacity(0.05)],
              ),
            ),
          ),

          // Decorative Element
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryColor.withOpacity(0.2),
                    primaryColor.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    60.height,

                    // İkon
                    _buildStepIcon(),

                    30.height,

                    // Ana içerik
                    if (_currentStep == 0) _buildEmailStep(),
                    if (_currentStep == 1) _buildCodeStep(),
                    if (_currentStep == 2) _buildNewPasswordStep(),
                    if (_currentStep == 3) _buildSuccessStep(),
                  ],
                ),
              ),
            ),
          ),

          // Geri Butonu
          if (_currentStep != 3)
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
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () {
                    if (_currentStep > 0) {
                      setState(() => _currentStep--);
                      _animationController.reset();
                      _animationController.forward();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepIcon() {
    IconData icon;
    Color bgColor;
    String title;

    switch (_currentStep) {
      case 0:
        icon = Icons.lock_reset;
        bgColor = primaryColor;
        title = language.lblForgotPassword;
        break;
      case 1:
        icon = Icons.mark_email_read_outlined;
        bgColor = Colors.orange;
        title = language.lblVerifyCode;
        break;
      case 2:
        icon = Icons.password;
        bgColor = Colors.green;
        title = language.lblNewPassword;
        break;
      case 3:
        icon = Icons.check_circle_outline;
        bgColor = Colors.green;
        title = language.lblSuccess;
        break;
      default:
        icon = Icons.lock_reset;
        bgColor = primaryColor;
        title = language.lblForgotPassword;
    }

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: bgColor.withOpacity(0.4),
                blurRadius: 30,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Icon(icon, size: 50, color: Colors.white),
        ),
        24.height,
        Text(title, style: boldTextStyle(size: 24)),
      ],
    );
  }

  Widget _buildEmailStep() {
    return Column(
      children: [
        16.height,
        Text(
          language.lblEnterEmailToReset,
          style: secondaryTextStyle(size: 16),
          textAlign: TextAlign.center,
        ),
        40.height,

        // Progress
        _buildProgress(1),
        30.height,

        // Email input
        Container(
          decoration: BoxDecoration(
            color: appStore.isDarkModeOn
                ? Colors.white.withOpacity(0.1)
                : Colors.white,
            borderRadius: radius(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: AppTextField(
            controller: emailController,
            textFieldType: TextFieldType.EMAIL,
            decoration: _inputDecoration(
              hintText: language.lblEnterEmail,
              prefixIcon: Icons.email_outlined,
            ),
          ),
        ),
        30.height,

        // Gönder butonu
        AppButtonWidget(
          width: context.width(),
          height: 56,
          color: primaryColor,
          shapeBorder: RoundedRectangleBorder(borderRadius: radius(16)),
          onTap: isLoading ? null : handleSendCode,
          child: isLoading
              ? _loadingIndicator()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send, color: Colors.white, size: 20),
                    10.width,
                    Text(
                      language.lblSendCode,
                      style: boldTextStyle(color: Colors.white, size: 16),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildCodeStep() {
    return Column(
      children: [
        16.height,
        Text(
          language.lblEnterCodeSentToEmail,
          style: secondaryTextStyle(size: 16),
          textAlign: TextAlign.center,
        ),
        8.height,
        Text(
          emailController.text,
          style: boldTextStyle(color: primaryColor),
        ),
        40.height,

        _buildProgress(2),
        30.height,

        // Kod input
        Container(
          decoration: BoxDecoration(
            color: appStore.isDarkModeOn
                ? Colors.white.withOpacity(0.1)
                : Colors.white,
            borderRadius: radius(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: AppTextField(
            controller: codeController,
            textFieldType: TextFieldType.OTHER,
            decoration: _inputDecoration(
              hintText: language.lblEnterVerificationCode,
              prefixIcon: Icons.pin_outlined,
            ),
          ),
        ),
        20.height,

        // Tekrar gönder
        TextButton(
          onPressed: handleSendCode,
          child: Text(
            language.lblResendCode,
            style: primaryTextStyle(color: primaryColor),
          ),
        ),
        20.height,

        // Doğrula butonu
        AppButtonWidget(
          width: context.width(),
          height: 56,
          color: primaryColor,
          shapeBorder: RoundedRectangleBorder(borderRadius: radius(16)),
          onTap: handleVerifyCode,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_outlined, color: Colors.white, size: 20),
              10.width,
              Text(
                language.lblVerify,
                style: boldTextStyle(color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewPasswordStep() {
    return Column(
      children: [
        16.height,
        Text(
          language.lblEnterNewPassword,
          style: secondaryTextStyle(size: 16),
          textAlign: TextAlign.center,
        ),
        40.height,

        _buildProgress(3),
        30.height,

        // Yeni şifre
        Container(
          decoration: BoxDecoration(
            color: appStore.isDarkModeOn
                ? Colors.white.withOpacity(0.1)
                : Colors.white,
            borderRadius: radius(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: AppTextField(
            controller: newPasswordController,
            textFieldType: TextFieldType.PASSWORD,
            decoration: _inputDecoration(
              hintText: language.lblEnterNewPassword,
              prefixIcon: Icons.lock_outline,
            ),
          ),
        ),
        20.height,

        // Şifre tekrar
        Container(
          decoration: BoxDecoration(
            color: appStore.isDarkModeOn
                ? Colors.white.withOpacity(0.1)
                : Colors.white,
            borderRadius: radius(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: AppTextField(
            controller: confirmPasswordController,
            textFieldType: TextFieldType.PASSWORD,
            decoration: _inputDecoration(
              hintText: language.lblConfirmNewPassword,
              prefixIcon: Icons.lock_outline,
            ),
          ),
        ),
        30.height,

        // Şifreyi değiştir butonu
        AppButtonWidget(
          width: context.width(),
          height: 56,
          color: primaryColor,
          shapeBorder: RoundedRectangleBorder(borderRadius: radius(16)),
          onTap: isLoading ? null : handleResetPassword,
          child: isLoading
              ? _loadingIndicator()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_reset, color: Colors.white, size: 20),
                    10.width,
                    Text(
                      language.lblResetPassword,
                      style: boldTextStyle(color: Colors.white, size: 16),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      children: [
        16.height,
        Text(
          language.lblPasswordResetSuccess,
          style: secondaryTextStyle(size: 16),
          textAlign: TextAlign.center,
        ),
        60.height,

        // Animasyonlu ikon
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 600),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 80,
                  color: Colors.green,
                ),
              ),
            );
          },
        ),
        40.height,

        // Giriş yap butonu
        AppButtonWidget(
          width: context.width(),
          height: 56,
          color: primaryColor,
          shapeBorder: RoundedRectangleBorder(borderRadius: radius(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, color: Colors.white, size: 20),
              10.width,
              Text(
                language.lblBackToLogin,
                style: boldTextStyle(color: Colors.white, size: 16),
              ),
            ],
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildProgress(int step) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        bool isActive = index < step;
        bool isCurrent = index == step - 1;

        return Row(
          children: [
            Container(
              width: isCurrent ? 12 : 10,
              height: isCurrent ? 12 : 10,
              decoration: BoxDecoration(
                color: isActive ? primaryColor : Colors.grey.withOpacity(0.3),
                shape: BoxShape.circle,
                border: isCurrent
                    ? Border.all(color: primaryColor, width: 2)
                    : null,
              ),
            ),
            if (index < 2)
              Container(
                width: 50,
                height: 2,
                color: index < step - 1
                    ? primaryColor
                    : Colors.grey.withOpacity(0.3),
              ),
          ],
        );
      }),
    );
  }

  Widget _loadingIndicator() {
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: secondaryTextStyle(),
      prefixIcon: Icon(
        prefixIcon,
        color: primaryColor.withOpacity(0.7),
        size: 22,
      ),
      border: OutlineInputBorder(
        borderRadius: radius(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius(16),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }
}
