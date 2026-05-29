import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

class EditProfileScreen extends StatefulWidget {
  static String tag = '/EditProfileScreen';

  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  FocusNode nameFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode bioFocus = FocusNode();

  bool isLoading = false;
  bool isImageLoading = false;
  File? _selectedImage;

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
    _loadUserData();
  }

  void _loadUserData() {
    final user = authStore.currentUser;
    if (user != null) {
      nameController.text = user.name ?? '';
      phoneController.text = user.phone ?? '';
      bioController.text = user.bio ?? '';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    phoneController.dispose();
    bioController.dispose();
    nameFocus.dispose();
    phoneFocus.dispose();
    bioFocus.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });

        // Hemen yükle
        await _uploadImage();
      }
    } catch (e) {
      toast(e.toString());
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() => isImageLoading = true);

    try {
      final response = await updateAvatar(imageFile: _selectedImage!);

      if (response.success == true && response.user != null) {
        await authStore.setUser(response.user);
        toast(language.lblAvatarUpdated);
        // Başarılı yükleme sonrası local dosyayı temizleyip güncel user avatarının (network) kullanılmasını sağlayabiliriz.
        // Ancak kullanıcı deneyimi açısından local resim kalabilir, sorun yok.
      } else {
        toast(response.message ?? language.lblSomethingWentWrong);
        // Hata durumunda seçili resmi geri al
        setState(() {
          _selectedImage = null;
        });
      }
    } catch (e) {
      toast(e.toString());
      // Hata durumunda seçili resmi geri al
      setState(() {
        _selectedImage = null;
      });
    } finally {
      setState(() => isImageLoading = false);
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: radius(2),
              ),
            ),
            20.height,
            Text(
              language.lblChoosePhoto,
              style: boldTextStyle(size: 18),
            ),
            24.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  icon: Icons.camera_alt,
                  label: language.lblCamera,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildPickerOption(
                  icon: Icons.photo_library,
                  label: language.lblGallery,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (authStore.currentUser?.avatar != null)
                  _buildPickerOption(
                    icon: Icons.delete,
                    label: language.lblRemove,
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      // Avatar silme işlemi
                    },
                  ),
              ],
            ),
            20.height,
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: radius(16),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (color ?? primaryColor).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color ?? primaryColor, size: 28),
            ),
            12.height,
            Text(label, style: primaryTextStyle()),
          ],
        ),
      ),
    );
  }

  Future<void> handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        final response = await updateProfile(
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
          bio: bioController.text.trim(),
        );

        if (response.success == true && response.user != null) {
          await authStore.setUser(response.user);
          toast(language.lblProfileUpdated);
          Navigator.pop(context);
        } else {
          toast(response.message ?? language.lblSomethingWentWrong);
        }
      } catch (e) {
        toast(e.toString());
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = authStore.currentUser;

    return Scaffold(
      body: Stack(
        children: [
          // Header Background
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.8),
                ],
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // App bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            language.lblEditProfile,
                            style: boldTextStyle(color: Colors.white, size: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        48.width, // Balance için
                      ],
                    ),
                  ),

                  // İçerik
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
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
                                  radius: 60,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: _selectedImage != null
                                      ? FileImage(_selectedImage!)
                                      : (user?.avatar != null && user!.avatar!.isNotEmpty
                                          ? NetworkImage(user.avatar!) as ImageProvider
                                          : null),
                                  child: _selectedImage == null &&
                                          (user?.avatar == null || user!.avatar!.isEmpty)
                                      ? Icon(Icons.person, size: 60, color: primaryColor)
                                      : null,
                                ),
                              ),

                              // Düzenle butonu
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _showImagePickerOptions,
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: isImageLoading
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          30.height,

                          // Form
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 24),
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: appStore.isDarkModeOn
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.white,
                              borderRadius: radius(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Email (Değiştirilemez)
                                  _buildReadOnlyField(
                                    label: language.lblEmail,
                                    value: user?.email ?? '',
                                    icon: Icons.email_outlined,
                                  ),

                                  24.height,

                                  // Ad Soyad
                                  _buildInputField(
                                    label: language.lblFullName,
                                    hint: language.lblEnterFullName,
                                    controller: nameController,
                                    focusNode: nameFocus,
                                    nextFocus: phoneFocus,
                                    prefixIcon: Icons.person_outline,
                                    textFieldType: TextFieldType.NAME,
                                  ),

                                  24.height,

                                  // Telefon
                                  _buildInputField(
                                    label: language.lblPhone,
                                    hint: language.lblEnterPhone,
                                    controller: phoneController,
                                    focusNode: phoneFocus,
                                    nextFocus: bioFocus,
                                    prefixIcon: Icons.phone_outlined,
                                    textFieldType: TextFieldType.PHONE,
                                    isRequired: false,
                                  ),

                                  24.height,

                                  // Biyografi
                                  _buildInputLabel(language.lblBio),
                                  8.height,
                                  Container(
                                    decoration: BoxDecoration(
                                      color: appStore.isDarkModeOn
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.grey[100],
                                      borderRadius: radius(16),
                                    ),
                                    child: TextField(
                                      controller: bioController,
                                      focusNode: bioFocus,
                                      maxLines: 4,
                                      maxLength: 200,
                                      decoration: InputDecoration(
                                        hintText: language.lblEnterBio,
                                        hintStyle: secondaryTextStyle(),
                                        border: OutlineInputBorder(
                                          borderRadius: radius(16),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: EdgeInsets.all(16),
                                        counterStyle: secondaryTextStyle(size: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          30.height,

                          // Kaydet Butonu
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: AppButtonWidget(
                              width: context.width(),
                              height: 56,
                              color: primaryColor,
                              shapeBorder: RoundedRectangleBorder(
                                borderRadius: radius(16),
                              ),
                              onTap: isLoading ? null : handleSave,
                              child: isLoading
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.save, color: Colors.white),
                                        12.width,
                                        Text(
                                          language.lblSaveChanges,
                                          style: boldTextStyle(
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          30.height,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInputLabel(label),
        8.height,
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: radius(16),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey, size: 22),
              16.width,
              Expanded(
                child: Text(
                  value,
                  style: primaryTextStyle(color: Colors.grey),
                ),
              ),
              Icon(Icons.lock, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: boldTextStyle(size: 14),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    required IconData prefixIcon,
    required TextFieldType textFieldType,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildInputLabel(label),
            if (isRequired)
              Text(' *', style: boldTextStyle(color: Colors.red, size: 14)),
          ],
        ),
        8.height,
        Container(
          decoration: BoxDecoration(
            color: appStore.isDarkModeOn
                ? Colors.white.withOpacity(0.1)
                : Colors.grey[100],
            borderRadius: radius(16),
          ),
          child: AppTextField(
            controller: controller,
            textFieldType: textFieldType,
            focus: focusNode,
            nextFocus: nextFocus,
            isValidationRequired: isRequired,
            decoration: InputDecoration(
              hintText: hint,
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
            ),
          ),
        ),
      ],
    );
  }
}
