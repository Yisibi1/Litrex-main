import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../main.dart';
import '../../network/AuthApis.dart';
import '../../utils/Extensions/Commons.dart';
import '../../utils/Extensions/Widget_extensions.dart';
import '../../utils/Extensions/context_extensions.dart';
import '../../utils/Extensions/decorations.dart';
import '../../utils/Extensions/int_extensions.dart';
import '../../utils/Extensions/text_styles.dart';
import '../../utils/colors.dart';
import '../SettingScreen.dart';
import '../BookmarkScreen.dart';
import 'EditProfileScreen.dart';
import 'LoginScreen.dart';
import '../PremiumScreen.dart';
import '../HelpSupportScreen.dart';
import '../DownloadScreen.dart';

class ProfileScreen extends StatefulWidget {
  static String tag = '/ProfileScreen';

  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (authStore.isLoggedIn && authStore.authToken != null) {
      setState(() => isLoading = true);
      try {
        final user = await getProfile();
        await authStore.setUser(user);
      } catch (e) {
        // Sessizce hata yönet
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: radius(16)),
        title: Text(language.lblLogout, style: boldTextStyle(size: 18)),
        content: Text(language.lblLogoutConfirmation, style: primaryTextStyle()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(language.lblCancel, style: primaryTextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authStore.logout();
              toast(language.lblLogoutSuccess);
              LoginScreen().launch(context, isNewTask: true);
            },
            child: Text(language.lblLogout, style: boldTextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        if (!authStore.isLoggedIn) {
          return _buildNotLoggedInView();
        }
        return _buildProfileView();
      },
    );
  }

  Widget _buildNotLoggedInView() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: appStore.isDarkModeOn
                ? [Color(0xFF1A1A2E), Color(0xFF16213E)]
                : [primaryColor.withOpacity(0.1), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Ionicons.person_outline,
                    size: 60,
                    color: primaryColor,
                  ),
                ),
                24.height,
                Text(
                  language.lblNotLoggedIn,
                  style: boldTextStyle(size: 22),
                ),
                12.height,
                Text(
                  language.lblLoginToAccessProfile,
                  style: secondaryTextStyle(size: 15),
                  textAlign: TextAlign.center,
                ),
                40.height,
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => LoginScreen().launch(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: radius(14)),
                    ),
                    child: Text(
                      language.lblLogin,
                      style: boldTextStyle(color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileView() {
    final user = authStore.currentUser;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Top Bar
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            language.lblProfile,
                            style: boldTextStyle(color: Colors.white, size: 22),
                          ),
                          IconButton(
                            onPressed: () => SettingScreen(onTap: () {}).launch(context),
                            icon: Icon(Ionicons.settings_outline, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    
                    20.height,
                    
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: user?.avatar != null && user!.avatar!.isNotEmpty
                                ? NetworkImage(user.avatar!)
                                : null,
                            child: user?.avatar == null || user!.avatar!.isEmpty
                                ? Icon(Ionicons.person, size: 50, color: primaryColor)
                                : null,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () => EditProfileScreen().launch(context).then((_) => _loadProfile()),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(Icons.edit, size: 18, color: primaryColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    16.height,
                    
                    // Name & Email
                    Text(
                      user?.name ?? 'User',
                      style: boldTextStyle(color: Colors.white, size: 22),
                    ),
                    6.height,
                    Text(
                      user?.email ?? '',
                      style: primaryTextStyle(color: Colors.white70, size: 14),
                    ),
                    

                    
                    20.height,

                     // Premium Banner
                    if (authStore.isPremiumUser)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 24),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA000)]),
                          borderRadius: radius(16),
                          boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 10, offset: Offset(0, 4))],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                              child: Icon(Icons.verified, color: Colors.white, size: 24),
                            ),
                            16.width,
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(language.lblYouArePremium, style: boldTextStyle(color: Colors.white, size: 18)),
                                Text(language.lblPremiumDesc, style: secondaryTextStyle(color: Colors.white, size: 12)),
                              ],
                            )),
                          ],
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () => PremiumScreen().launch(context),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 24),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.amber.shade700, Colors.amber.shade400]),
                            borderRadius: radius(16),
                            boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 10, offset: Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                                child: Icon(Icons.diamond, color: Colors.white, size: 24),
                              ),
                              16.width,
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Premium'a Geçin", style: boldTextStyle(color: Colors.white, size: 18)),
                                  Text("Sınırsız erişim ve ayrıcalıklar", style: secondaryTextStyle(color: Colors.white, size: 12)),
                                ],
                              )),
                              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ),

                    30.height,
                  ],
                ),
              ),
            ),
          ),
          
          // Menu Items
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: context.scaffoldBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  24.height,
                  
                  // Profil Düzenle
                  _buildMenuItem(
                    icon: Ionicons.person_outline,
                    title: language.lblEditProfile,
                    subtitle: language.lblUpdateYourInfo,
                    onTap: () => EditProfileScreen().launch(context).then((_) => _loadProfile()),
                  ),
                  
                  // Şifre Değiştir
                  _buildMenuItem(
                    icon: Ionicons.lock_closed_outline,
                    title: language.lblChangePassword,
                    subtitle: language.lblUpdateYourPassword,
                    onTap: _showChangePasswordDialog,
                  ),
                  


                  // Downloaded Books
                  _buildMenuItem(
                    icon: Ionicons.cloud_download_outline,
                    title: language.lblDownloads,
                    subtitle: language.lblOfflineLibrary,
                    onTap: () => DownloadScreen().launch(context),
                  ),

                  // Bookmarks
                  _buildMenuItem(
                    icon: Ionicons.bookmarks_outline,
                    title: language.lblBookmarks,
                    subtitle: language.lblYourBookmarks,
                    onTap: () => BookmarkScreen().launch(context),
                  ),
                  
                  // Ayarlar
                  _buildMenuItem(
                    icon: Ionicons.settings_outline,
                    title: language.lblSetting,
                    subtitle: language.lblChooseTheme,
                    onTap: () => SettingScreen(onTap: () {}).launch(context),
                  ),
                  
                  // Bildirimler
                  _buildMenuItem(
                    icon: Ionicons.notifications_outline,
                    title: language.lblNotifications,
                    subtitle: language.lblManageNotifications,
                    trailing: Switch(
                      value: appStore.isNotificationOn,
                      onChanged: (val) {
                        appStore.setNotification(val);
                        setState(() {});
                      },
                      activeThumbColor: primaryColor,
                    ),
                  ),
                  
                  // Yardım
                  _buildMenuItem(
                    icon: Ionicons.help_circle_outline,
                    title: language.lblHelpSupport,
                    subtitle: language.lblGetHelp,
                    onTap: () => HelpSupportScreen().launch(context),
                  ),

                  // Hesabı Sil
                   _buildMenuItem(
                    icon: Ionicons.trash_outline,
                    title: language.lblDeleteAccount,
                    subtitle: language.lblDeleteAccountWarning,
                    onTap: _showDeleteAccountDialog,
                    iconColor: Colors.red,
                    titleColor: Colors.red,
                  ),
                  
                  24.height,
                  
                  // Çıkış Yap
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _showLogoutDialog,
                        icon: Icon(Ionicons.log_out_outline, color: Colors.red),
                        label: Text(
                          language.lblLogout,
                          style: boldTextStyle(color: Colors.red, size: 15),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(borderRadius: radius(14)),
                        ),
                      ),
                    ),
                  ),
                  
                  40.height,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: boldTextStyle(color: Colors.white, size: 22),
        ),
        4.height,
        Text(
          label,
          style: secondaryTextStyle(color: Colors.white70, size: 12),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? iconColor,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? primaryColor).withOpacity(0.1),
                borderRadius: radius(12),
              ),
              child: Icon(icon, color: iconColor ?? primaryColor, size: 22),
            ),
            16.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: boldTextStyle(size: 15, color: titleColor)),
                  4.height,
                  Text(subtitle, style: secondaryTextStyle(size: 12)),
                ],
              ),
            ),
            trailing ?? Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: radius(16)),
        title: Text(language.lblChangePassword, style: boldTextStyle(size: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: language.lblCurrentPassword,
                border: OutlineInputBorder(borderRadius: radius(12)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            16.height,
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: language.lblNewPassword,
                border: OutlineInputBorder(borderRadius: radius(12)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            16.height,
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: language.lblConfirmNewPassword,
                border: OutlineInputBorder(borderRadius: radius(12)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(language.lblCancel, style: primaryTextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                toast(language.lblPasswordsDoNotMatch);
                return;
              }
              if (newPasswordController.text.length < 6) {
                toast(language.lblPasswordTooShort);
                return;
              }
              
              Navigator.pop(context);
              
              try {
                final response = await changePassword(
                  currentPassword: currentPasswordController.text,
                  newPassword: newPasswordController.text,
                );
                
                if (response['success'] == true) {
                  toast(language.lblPasswordChangedSuccess);
                } else {
                  toast(response['message'] ?? language.lblSomethingWentWrong);
                }
              } catch (e) {
                toast(e.toString());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: radius(10)),
            ),
            child: Text(language.lblUpdate, style: boldTextStyle(color: Colors.white, size: 14)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: radius(16)),
        title: Text(language.lblDeleteAccount, style: boldTextStyle(size: 18, color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(language.lblDeleteAccountWarning, style: primaryTextStyle(size: 14)),
            16.height,
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: language.lblPassword,
                hintText: language.lblEnterPasswordToConfirm,
                border: OutlineInputBorder(borderRadius: radius(12)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(language.lblCancel, style: primaryTextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text.isEmpty) {
                toast(language.lblPleaseEnterPassword);
                return;
              }
              
              Navigator.pop(context);
              
              setState(() => isLoading = true);
              try {
                final response = await deleteAccount(password: passwordController.text);
                
                if (response['success'] == true) {
                  await authStore.logout();
                  toast(language.lblAccountDeleted);
                  LoginScreen().launch(context, isNewTask: true);
                } else {
                  toast(response['message'] ?? language.lblSomethingWentWrong);
                }
              } catch (e) {
                toast(e.toString());
              } finally {
                setState(() => isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: radius(10)),
            ),
            child: Text(language.lblDelete, style: boldTextStyle(color: Colors.white, size: 14)),
          ),
        ],
      ),
    );
  }
}
