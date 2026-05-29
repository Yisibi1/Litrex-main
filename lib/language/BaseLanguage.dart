import 'package:flutter/material.dart';

abstract class BaseLanguage {
  static BaseLanguage? of(BuildContext context) => Localizations.of<BaseLanguage>(context, BaseLanguage);

  String get lblCategory;
  String get lblFavourite;
  String get lblPopular;
  String get lblLatest;
  String get lblFeatured;
  String get lblSuggested;
  String get lblAboutUs;
  String get lblPrivacyPolicy;
  String get lblTermsCondition;
  String get lblNoDataFound;
  String get lblNoInternet;
  String get lblRateUs;
  String get lblDarkMode;
  String get lblSystemDefault;
  String get lblLightMode;
  String get lblPushNotification;
  String get lblSearchBook;
  String get lblSetting;
  String get lblSeeMore;
  String get lblRemoveBookmark;
  String get lblTryAgain;
  String get lblReadBook;
  String get lblSelectTheme;
  String get lblChooseTopic;
  String get lblContinue;
  String get lblChooseTopicMsg;
  String get lblChooseTopicTitle;
  String get lblChooseTopicDesc;
  String get lblCancel;
  String get lblYes;
  String get lblUrlEmpty;
  String get lblChooseTheme;
  String get lblDisableNotification;
  String get lblOthers;
  String get lblBy;
  String get lblAuthors;
  String get lblAuthorsDes;
  String get lblAbout;
  String get lblBooksBy;
  String get lblDescription;
  String get lblRemove;
  String get lblWalk1;
  String get lblWalk1Desc;
  String get lblWalk2;
  String get lblWalk2Desc;
  String get lblWalk3;
  String get lblWalk3Desc;
  String get lblGetStarted;
  String get lblSkip;
  String get lblLanguage;
  String get lblLanguageDesc;

  // YENİ EKLENENLER
  String get lblSearchAuthor;
  String get lblNoAuthorsFound;

  // ==================== AUTH STRINGS ====================
  // Login Screen
  String get lblWelcomeBack;
  String get lblLoginToContinue;
  String get lblEmail;
  String get lblEnterEmail;
  String get lblPassword;
  String get lblEnterPassword;
  String get lblRememberMe;
  String get lblForgotPassword;
  String get lblLogin;
  String get lblOrContinueWith;
  String get lblDontHaveAccount;
  String get lblRegister;
  String get lblLoginSuccess;
  String get lblLoginFailed;
  String get lblComingSoon;

  // Register Screen
  String get lblCreateAccount;
  String get lblRegisterToGetStarted;
  String get lblFullName;
  String get lblEnterFullName;
  String get lblPhone;
  String get lblEnterPhone;
  String get lblConfirmPassword;
  String get lblReEnterPassword;
  String get lblIAgreeToThe;
  String get lblTermsOfService;
  String get lblAnd;
  String get lblPleaseAcceptTerms;
  String get lblPasswordsDoNotMatch;
  String get lblRegistrationSuccess;
  String get lblRegistrationFailed;
  String get lblAlreadyHaveAccount;

  // Forgot Password Screen
  String get lblVerifyCode;
  String get lblNewPassword;
  String get lblSuccess;
  String get lblEnterEmailToReset;
  String get lblSendCode;
  String get lblResetCodeSent;
  String get lblSomethingWentWrong;
  String get lblPleaseEnterEmail;
  String get lblEnterCodeSentToEmail;
  String get lblEnterVerificationCode;
  String get lblResendCode;
  String get lblVerify;
  String get lblEnterNewPassword;
  String get lblConfirmNewPassword;
  String get lblPleaseEnterCode;
  String get lblPleaseEnterPassword;
  String get lblPasswordTooShort;
  String get lblResetPassword;
  String get lblPasswordResetSuccess;
  String get lblBackToLogin;

  // Profile Screen
  String get lblProfile;
  String get lblEditProfile;
  String get lblUpdateYourInfo;
  String get lblChangePassword;
  String get lblUpdateYourPassword;
  String get lblYourBookmarks;
  String get lblNotifications;
  String get lblManageNotifications;
  String get lblHelpSupport;
  String get lblGetHelp;
  String get lblLogout;
  String get lblLogoutConfirmation;
  String get lblLogoutSuccess;
  String get lblDeleteAccount;
  String get lblDeleteAccountWarning;
  String get lblEnterPasswordToConfirm;
  String get lblAccountDeleted;
  String get lblDelete;
  String get lblNotLoggedIn;
  String get lblLoginToAccessProfile;
  String get lblBio;
  String get lblBooksRead;
  String get lblBookmarks;
  String get lblFavorites;
  String get lblCurrentPassword;
  String get lblPasswordChangedSuccess;
  String get lblUpdate;

  // Edit Profile Screen
  String get lblEnterBio;
  String get lblSaveChanges;
  String get lblProfileUpdated;
  String get lblAvatarUpdated;
  String get lblChoosePhoto;
  String get lblCamera;
  String get lblGallery;

  // Offline Reading / Downloads
  String get lblDownloads;
  String get lblOfflineLibrary;
  String get lblYouHave;
  String get lblDownloadedBooks;
  String get lblTapToStartReading;
  String get lblNoDownloadedBooks;
  String get lblDownloadToReadOffline;
  String get lblRemoveDownloadTitle;
  String get lblRemoveDownloadMsg;
  String get lblDeleteBookTitle;
  String get lblDeleteBookMsg;
  String get lblDownloadComplete;
  String get lblDownloadFailed;
  String get lblOfflineReadToast;
  String get lblErrorOpeningBook;
  String get lblUnknownTitle;
  String get lblDeviceResetByAdmin;
  String get lblAccountSuspended;
  String get lblGetPremiumToRead;
  String get lblYouArePremium;
  String get lblPremiumDesc;

  // Support Screen
  String get lblSubject;
  String get lblEnterSubject;
  String get lblMessage;
  String get lblEnterMessage;
  String get lblSend;
  String get lblMessageSent;
  String get lblSending;
  String get lblFailedToSend;

  // Addons / Eklentiler
  String get lblAddons;
  String get lblAddonConnected;
  String get lblAddonConnectHarici;
  String get lblAddonConnectedStatus;
  String get lblAddonDisconnectedStatus;
  String get lblAddonManager;
  String get lblNoAddonsYet;
  String get lblAddonDeleted;
  String get lblClose;
  String get lblSave;
  String get lblAddNewAddon;
  String get lblEnterManifestUrl;
  String get lblAddonHint;
  String get lblAddonAddedSuccess;
  String get lblUrlAlreadyExists;
  String get lblUrlCannotBeEmpty;
  String get lblMaxAddonsLimit;
  String get lblAdLoadingWait => "Ad is loading, please wait...";

  // Monetizasiya / Reklam Limiti
  String get lblDailyAdLimitReached;
  String get lblDailyAdLimitMsg;
  String get lblGetPremiumNow;
  String get lblOfflineBlockTitle;
  String get lblOfflineBlockMsg;
  String get lblDownloadPremiumOnly;

  String get lblTimeUntilReset;
  String get lblBuyCoins;
  String get lblLimitReached;
  String get lblGoToPremium;
  String get lblChecking;
  String get lblWatchVideoToEarn;
  String get lblCoins;

  // Yeniləmə / Update
  String get lblUpdateAvailable;
  String get lblUpdateRequiredMsg;
  String get lblUpdateNow;

  // Dəyərləndirmə / Rating
  String get lblRateUsTitle;
  String get lblRateUsMsg;
  String get lblRateNow;
  String get lblMaybeLater;
}