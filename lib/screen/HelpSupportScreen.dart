import 'package:flutter/material.dart';
import '../utils/Extensions/AppButton.dart';
import '../utils/Extensions/AppTextField.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/colors.dart';
import '../main.dart';
import '../utils/Extensions/Commons.dart';
import '../network/RestApis.dart';

import '../utils/Extensions/context_extensions.dart';

class HelpSupportScreen extends StatefulWidget {
  static String tag = '/HelpSupportScreen';

  const HelpSupportScreen({super.key});

  @override
  HelpSupportScreenState createState() => HelpSupportScreenState();
}

class HelpSupportScreenState extends State<HelpSupportScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _submit() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        await sendSupportMessage(
          subject: subjectController.text.trim(),
          message: messageController.text.trim(),
          email: authStore.isLoggedIn ? authStore.currentUser?.email : null,
          name: authStore.isLoggedIn ? authStore.currentUser?.name : null,
        );
        
        toast(language.lblMessageSent);
        finish(context);
      } catch (e) {
        toast(language.lblFailedToSend);
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language.lblHelpSupport,
        color: primaryColor,
        textColor: Colors.white,
        showBack: true,
        elevation: 0,
      ),
      body: SizedBox(
        height: context.height(),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: context.width(),
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.support_agent_rounded, size: 60, color: primaryColor),
                        16.height,
                        Text(
                          language.lblGetHelp,
                          style: boldTextStyle(size: 22),
                          textAlign: TextAlign.center,
                        ),
                        8.height,
                        Text(
                          "We are here to help you with any questions or issues you may have.",
                          style: secondaryTextStyle(),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  32.height,
                  Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(language.lblSubject, style: boldTextStyle(size: 16)),
                        8.height,
                        AppTextField(
                          controller: subjectController,
                          textFieldType: TextFieldType.NAME,
                          textStyle: primaryTextStyle(),
                          decoration: InputDecoration(
                            hintText: language.lblEnterSubject,
                            hintStyle: secondaryTextStyle(),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryColor),
                            ),
                            filled: true,
                            fillColor: context.cardColor,
                            prefixIcon: Icon(Icons.short_text_rounded, color: Colors.grey),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          nextFocus: FocusNode(),
                        ),
                        24.height,
                        Text(language.lblMessage, style: boldTextStyle(size: 16)),
                        8.height,
                        AppTextField(
                          controller: messageController,
                          textFieldType: TextFieldType.OTHER,
                          maxLines: 8,
                          minLines: 5,
                          textStyle: primaryTextStyle(),
                          decoration: InputDecoration(
                            hintText: language.lblEnterMessage,
                            hintStyle: secondaryTextStyle(),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryColor),
                            ),
                            filled: true,
                            fillColor: context.cardColor,
                            alignLabelWithHint: true,
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 20),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: AppButtonWidget(
                text: language.lblSend,
                color: primaryColor,
                textColor: Colors.white,
                width: context.width(),
                onTap: _submit,
                enableScaleAnimation: false,
                padding: EdgeInsets.symmetric(vertical: 16),
                shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 10,
              ).visible(!isLoading),
            ),
            Center(child: CircularProgressIndicator().visible(isLoading)),
          ],
        ),
      ),
    );
  }
}
