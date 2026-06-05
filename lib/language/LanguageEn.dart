import 'BaseLanguage.dart';
class LanguageEn extends BaseLanguage {
  @override
  String get lblCategory => "Categories";

  @override
  String get lblFavourite => "Bookmarks";

  @override
  String get lblPopular => "Popular Books";

  @override
  String get lblLatest => "Latest Books";

  @override
  String get lblFeatured => "Featured Books";

  @override
  String get lblSuggested => "Suggested Books";

  @override
  String get lblAboutUs => "About Us";

  @override
  String get lblPrivacyPolicy => "Privacy Policy";

  @override
  String get lblTermsCondition => "Terms & Conditions";

  @override
  String get lblTermsOfUseEula => "Terms & Conditions (EULA)";

  @override
  String get lblNoDataFound => "No Data Found";

  @override
  String get lblNoInternet => "Your internet is not working";

  @override
  String get lblRateUs => "Rate Us";

  @override
  String get lblDarkMode => "Dark Mode";

  @override
  String get lblSystemDefault => "System Default";

  @override
  String get lblLightMode => "Light Mode";

  @override
  String get lblPushNotification => "Disable Push Notification";

  @override
  String get lblSearchBook => "Search Book";

  @override
  String get lblSetting => "Settings";

  @override
  String get lblSeeMore => "See More";

  @override
  String get lblRemoveBookmark => "Are you sure you want to remove bookmark?";

  @override
  String get lblTryAgain => "Please Try Again";

  @override
  String get lblReadBook => "Read Book";

  @override
  String get lblSelectTheme => "Select Theme";

  @override
  String get lblChooseTopic => "Choose Topic";

  @override
  String get lblContinue => "Continue";

  @override
  String get lblChooseTopicMsg => "Please select at least 3 topics";

  @override
  String get lblChooseTopicTitle => "Select your interested category";

  @override
  String get lblChooseTopicDesc => "Choose three or more.";

  @override
  String get lblCancel => "Cancel";

  @override
  String get lblYes => "Yes";

  @override
  String get lblUrlEmpty => "Url is Empty";

  @override
  String get lblChooseTheme => "Choose your app theme";

  @override
  String get lblDisableNotification => "Enable/Disable push notifications";

  @override
  String get lblOthers => "Others";

  @override
  String get lblBy => "By";

  @override
  String get lblAuthors => "Authors";

  @override
  String get lblAuthorsDes => "Find your books by authors";

  @override
  String get lblAbout => "About";

  @override
  String get lblBooksBy => "Publish Books";

  @override
  String get lblDescription => "Description";

  @override
  String get lblRemove => "Remove";

  @override
  String get lblWalk1 => "Welcome to Litrex eBook";

  @override
  String get lblWalk1Desc => "Yeni çıkan kitapların özetlerini keşfet, edebiyat dünyasındaki yenilikleri takip et.";

  @override
  String get lblWalk2 => "Read PDF File";

  @override
  String get lblWalk2Desc => "Lorem Ipsum is simply dummy text of the printing and typesetting industry.";

  @override
  String get lblWalk3 => "Bookmark your book";

  @override
  String get lblWalk3Desc => "Lorem Ipsum is simply dummy text of the printing and typesetting industry.";

  @override
  String get lblGetStarted => "Get Started";

  @override
  String get lblSkip => "Skip";

  @override
  String get lblLanguage => "Select Language";

  @override
  String get lblLanguageDesc => "Choose your language";

// YENİ EKLENENLER
  @override String get lblSearchAuthor => "Search Author";
  @override String get lblNoAuthorsFound => "No authors found";

  // ==================== AUTH STRINGS ====================
  // Login Screen
  @override String get lblWelcomeBack => "Welcome Back!";
  @override String get lblLoginToContinue => "Login to continue";
  @override String get lblEmail => "Email";
  @override String get lblEnterEmail => "Enter your email";
  @override String get lblPassword => "Password";
  @override String get lblEnterPassword => "Enter your password";
  @override String get lblRememberMe => "Remember Me";
  @override String get lblForgotPassword => "Forgot Password?";
  @override String get lblLogin => "Login";
  @override String get lblOrContinueWith => "or continue with";
  @override String get lblDontHaveAccount => "Don't have an account?";
  @override String get lblRegister => "Register";
  @override String get lblLoginSuccess => "Login successful!";
  @override String get lblLoginFailed => "Login failed. Please check your credentials.";
  @override String get lblComingSoon => "Coming soon!";

  // Register Screen
  @override String get lblCreateAccount => "Create Account";
  @override String get lblRegisterToGetStarted => "Register to get started";
  @override String get lblFullName => "Full Name";
  @override String get lblEnterFullName => "Enter your full name";
  @override String get lblPhone => "Phone";
  @override String get lblEnterPhone => "Enter your phone number";
  @override String get lblConfirmPassword => "Confirm Password";
  @override String get lblReEnterPassword => "Re-enter your password";
  @override String get lblIAgreeToThe => "I agree to the";
  @override String get lblTermsOfService => "Terms of Service";
  @override String get lblAnd => "and";
  @override String get lblPleaseAcceptTerms => "Please accept terms and conditions";
  @override String get lblPasswordsDoNotMatch => "Passwords do not match";
  @override String get lblRegistrationSuccess => "Registration successful! Welcome!";
  @override String get lblRegistrationFailed => "Registration failed. Please try again.";
  @override String get lblAlreadyHaveAccount => "Already have an account?";

  // Forgot Password Screen
  @override String get lblVerifyCode => "Verify Code";
  @override String get lblNewPassword => "New Password";
  @override String get lblSuccess => "Success!";
  @override String get lblEnterEmailToReset => "Enter your email to reset password";
  @override String get lblSendCode => "Send Code";
  @override String get lblResetCodeSent => "Reset code sent to your email";
  @override String get lblSomethingWentWrong => "Something went wrong. Please try again.";
  @override String get lblPleaseEnterEmail => "Please enter your email";
  @override String get lblEnterCodeSentToEmail => "Enter the code sent to your email";
  @override String get lblEnterVerificationCode => "Enter verification code";
  @override String get lblResendCode => "Resend Code";
  @override String get lblVerify => "Verify";
  @override String get lblEnterNewPassword => "Enter new password";
  @override String get lblConfirmNewPassword => "Confirm new password";
  @override String get lblPleaseEnterCode => "Please enter verification code";
  @override String get lblPleaseEnterPassword => "Please enter password";
  @override String get lblPasswordTooShort => "Password must be at least 6 characters";
  @override String get lblResetPassword => "Reset Password";
  @override String get lblPasswordResetSuccess => "Password reset successfully!";
  @override String get lblBackToLogin => "Back to Login";

  // Profile Screen
  @override String get lblProfile => "Profile";
  @override String get lblEditProfile => "Edit Profile";
  @override String get lblUpdateYourInfo => "Update your information";
  @override String get lblChangePassword => "Change Password";
  @override String get lblUpdateYourPassword => "Update your password";
  @override String get lblYourBookmarks => "View your bookmarks";
  @override String get lblNotifications => "Notifications";
  @override String get lblManageNotifications => "Manage notifications";
  @override String get lblHelpSupport => "Help & Support";
  @override String get lblGetHelp => "Get help";
  @override String get lblLogout => "Logout";
  @override String get lblLogoutConfirmation => "Are you sure you want to logout?";
  @override String get lblLogoutSuccess => "Logged out successfully";
  @override String get lblDeleteAccount => "Delete Account";
  @override String get lblDeleteAccountWarning => "This action cannot be undone! Your account and all data will be permanently deleted.";
  @override String get lblEnterPasswordToConfirm => "Enter password to confirm";
  @override String get lblAccountDeleted => "Account deleted successfully";
  @override String get lblDelete => "Delete";
  @override String get lblNotLoggedIn => "Not Logged In";
  @override String get lblLoginToAccessProfile => "Please login to access your profile";
  @override String get lblBio => "Bio";
  @override String get lblBooksRead => "Read";
  @override String get lblBookmarks => "Bookmarks";
  @override String get lblFavorites => "Favorites";
  @override String get lblCurrentPassword => "Current Password";
  @override String get lblPasswordChangedSuccess => "Password changed successfully!";
  @override String get lblUpdate => "Update";

  // Edit Profile Screen
  @override String get lblEnterBio => "Tell us about yourself...";
  @override String get lblSaveChanges => "Save Changes";
  @override String get lblProfileUpdated => "Profile updated successfully!";
  @override String get lblAvatarUpdated => "Profile photo updated!";
  @override String get lblChoosePhoto => "Choose Photo";
  @override String get lblCamera => "Camera";
  @override String get lblGallery => "Gallery";
  
  // Offline Reading / Downloads
  @override String get lblDownloads => "Downloads";
  @override String get lblOfflineLibrary => "Offline Library";
  @override String get lblYouHave => "You have";
  @override String get lblDownloadedBooks => "downloaded books";
  @override String get lblTapToStartReading => "Tap to start reading";
  @override String get lblNoDownloadedBooks => "No downloaded books found";
  @override String get lblDownloadToReadOffline => "Download books to read offline";
  @override String get lblRemoveDownloadTitle => "Remove Download?";
  @override String get lblRemoveDownloadMsg => "Are you sure you want to remove this book from offline storage?";
  @override String get lblDeleteBookTitle => "Delete Book?";
  @override String get lblDeleteBookMsg => "Are you sure you want to remove this book from downloads?";
  @override String get lblDownloadComplete => "Download Complete";
  @override String get lblDownloadFailed => "Download Failed";
  @override String get lblOfflineReadToast => "Start reading from your offline library.";
  @override String get lblErrorOpeningBook => "Error opening book. File might be corrupted.";
  @override String get lblUnknownTitle => "Unknown Title";
  @override String get lblDeviceResetByAdmin => "Your device has been reset by the administrator.";
  @override String get lblAccountSuspended => "Your account has been suspended. Please contact support.";
  @override String get lblGetPremiumToRead => "Get Premium to Read";
  @override String get lblYouArePremium => "You are a Premium Member";
  @override String get lblPremiumDesc => "Enjoy your exclusive benefits";
  
  // Support Screen
  @override String get lblSubject => "Subject";
  @override String get lblEnterSubject => "Enter subject";
  @override String get lblMessage => "Message";
  @override String get lblEnterMessage => "Enter your message";
  @override String get lblSend => "Send";
  @override String get lblMessageSent => "Your message has been sent successfully.";
  @override String get lblSending => "Sending...";
  @override String get lblFailedToSend => "Failed to send message. Please try again.";

  // Addons
  @override String get lblAddons => "Addons";
  @override String get lblAddonConnected => "external databases connected";
  @override String get lblAddonConnectHarici => "Add external book database";
  @override String get lblAddonConnectedStatus => "Connected";
  @override String get lblAddonDisconnectedStatus => "Not Connected";
  @override String get lblAddonManager => "Addon Manager";
  @override String get lblNoAddonsYet => "No external databases added yet.";
  @override String get lblAddonDeleted => "Addon deleted.";
  @override String get lblClose => "Close";
  @override String get lblSave => "Save";
  @override String get lblAddNewAddon => "Add New Addon";
  @override String get lblEnterManifestUrl => "Enter the external content manifest.json link.";
  @override String get lblAddonHint => "Example: https://example.com/addon.json";
  @override String get lblAddonAddedSuccess => "New addon added successfully!";
  @override String get lblUrlAlreadyExists => "This URL already exists!";
  @override String get lblUrlCannotBeEmpty => "URL cannot be empty!";
  @override String get lblMaxAddonsLimit => "Maximum 5 addons limit reached!";
  @override String get lblAdLoadingWait => "Ad is currently loading, please try again in a few seconds.";

  // Monetization / Ad Limit
  @override String get lblDailyAdLimitReached => "Daily Limit Reached!";
  @override String get lblDailyAdLimitMsg => "You've reached the ad watching limit. Please try again after the specified time or get Premium.";
  @override String get lblGetPremiumNow => "Switch to Premium";
  @override String get lblOfflineBlockTitle => "Internet Connection Required";
  @override String get lblOfflineBlockMsg => "Internet connection is required to read this book. Get Premium to read offline.";
  @override String get lblDownloadPremiumOnly => "Download feature is only available for Premium members.";

  @override String get lblTimeUntilReset => "TIME UNTIL RENEWAL";
  @override String get lblBuyCoins => "Buy Coins";
  @override String get lblLimitReached => "Limit Reached: ";
  @override String get lblGoToPremium => "Go to Premium";
  @override String get lblChecking => "Checking...";
  @override String get lblWatchVideoToEarn => "Watch video and earn ";
  @override String get lblCoins => " Coins";

  @override String get lblUpdateAvailable => "Update Available";
  @override String get lblUpdateRequiredMsg => "A new version of the app is available. Please update to continue.";
  @override String get lblUpdateNow => "Update Now";

  @override String get lblRateUsTitle => "Enjoying the App?";
  @override String get lblRateUsMsg => "If you like our app, please take a moment to rate it. It really helps us!";
  @override String get lblRateNow => "Rate Now";
  @override String get lblMaybeLater => "Maybe Later";
}
