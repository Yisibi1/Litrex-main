import 'BaseLanguage.dart';
class LanguageFr extends BaseLanguage {
  @override
  String get lblCategory => "Catégories";

  @override
  String get lblFavourite => "Signets";

  @override
  String get lblPopular => "Livres populaires";

  @override
  String get lblLatest => "Derniers livres";

  @override
  String get lblFeatured => "Livres en vedette";

  @override
  String get lblSuggested => "Livres suggérés";

  @override
  String get lblAboutUs => "À propos de nous";

  @override
  String get lblPrivacyPolicy => "Politique de confidentialité";

  @override
  String get lblTermsCondition => "termes et conditions";

  @override
  String get lblTermsOfUseEula => "termes et conditions (EULA)";

  @override
  String get lblNoDataFound => "Aucune donnée disponible";

  @override
  String get lblNoInternet => "Votre Internet ne fonctionne pas";

  @override
  String get lblRateUs => "Évaluez nous";

  @override
  String get lblDarkMode => "Mode sombre";

  @override
  String get lblSystemDefault => "Défaillance du système";

  @override
  String get lblLightMode => "Mode léger";

  @override
  String get lblPushNotification => "Désactiver la notification push";

  @override
  String get lblSearchBook => "Livre de recherche";

  @override
  String get lblSetting => "Réglages";

  @override
  String get lblSeeMore => "Voir plus";

  @override
  String get lblRemoveBookmark => "Êtes-vous sûr de vouloir supprimer le signet?";

  @override
  String get lblTryAgain => "Veuillez réessayer";

  @override
  String get lblReadBook => "Lire un livre";

  @override
  String get lblSelectTheme => "Sélectionne un thème";

  @override
  String get lblChooseTopic => "Choisir le sujet";

  @override
  String get lblContinue => "Continuez";

  @override
  String get lblChooseTopicMsg => "Veuillez sélectionner au moins 3 sujets";

  @override
  String get lblChooseTopicTitle => "Sélectionnez votre catégorie intéressée";

  @override
  String get lblChooseTopicDesc => "Choisissez trois ou plus.";

  @override
  String get lblCancel => "Annuler";

  @override
  String get lblYes => "Oui";

  @override
  String get lblUrlEmpty => "L'URL est vide";

  @override
  String get lblChooseTheme => "Choisissez le thème de votre application";

  @override
  String get lblDisableNotification => "Activer / désactiver les notifications push";

  @override
  String get lblOthers => "Autres";

  @override
  String get lblBy => "Par";

  @override
  String get lblAuthors => "Auteurs";

  @override
  String get lblAuthorsDes => "Trouvez vos livres par des auteurs";

  @override
  String get lblAbout => "Sur";

  @override
  String get lblBooksBy => "Publier des livres";

  @override
  String get lblDescription => "La description";

  @override
  String get lblRemove => "Éliminer";

  @override
  String get lblWalk1 => "Bienvenue à Mighty Ebook";

  @override
  String get lblWalk1Desc => "Lorem Ipsum est simplement un texte muet de l'industrie de l'impression et de la composition.";

  @override
  String get lblWalk2 => "Lire le fichier PDF";

  @override
  String get lblWalk2Desc => "Lorem Ipsum est simplement un texte muet de l'industrie de l'impression et de la composition.";

  @override
  String get lblWalk3 => "Bookmark votre livre";

  @override
  String get lblWalk3Desc => "Lorem Ipsum est simplement un texte muet de l'industrie de l'impression et de la composition.";

  @override
  String get lblGetStarted => "Commencer";

  @override
  String get lblSkip => "Sauter";

  @override
  String get lblLanguage => "Sélectionner la langue de l'élecqueur en langues";

  @override
  String get lblLanguageDesc => "Choisissez votre langue";

// YENI EKLENENLER
  @override String get lblSearchAuthor => "Rechercher un auteur";
  @override String get lblNoAuthorsFound => "Aucun auteur trouvé";

  // ==================== AUTH STRINGS ====================
  @override String get lblWelcomeBack => "Bienvenue!";
  @override String get lblLoginToContinue => "Connectez-vous pour continuer";
  @override String get lblEmail => "Email";
  @override String get lblEnterEmail => "Entrez votre email";
  @override String get lblPassword => "Mot de passe";
  @override String get lblEnterPassword => "Entrez votre mot de passe";
  @override String get lblRememberMe => "Se souvenir de moi";
  @override String get lblForgotPassword => "Mot de passe oublié?";
  @override String get lblLogin => "Connexion";
  @override String get lblOrContinueWith => "ou continuer avec";
  @override String get lblDontHaveAccount => "Vous n'avez pas de compte?";
  @override String get lblRegister => "S'inscrire";
  @override String get lblLoginSuccess => "Connexion réussie!";
  @override String get lblLoginFailed => "Échec de la connexion";
  @override String get lblComingSoon => "Bientôt disponible!";
  @override String get lblCreateAccount => "Créer un compte";
  @override String get lblRegisterToGetStarted => "Inscrivez-vous pour commencer";
  @override String get lblFullName => "Nom complet";
  @override String get lblEnterFullName => "Entrez votre nom complet";
  @override String get lblPhone => "Téléphone";
  @override String get lblEnterPhone => "Entrez votre numéro";
  @override String get lblConfirmPassword => "Confirmer le mot de passe";
  @override String get lblReEnterPassword => "Ressaisissez le mot de passe";
  @override String get lblIAgreeToThe => "J'accepte les";
  @override String get lblTermsOfService => "Conditions d'utilisation";
  @override String get lblAnd => "et";
  @override String get lblPleaseAcceptTerms => "Veuillez accepter les conditions";
  @override String get lblPasswordsDoNotMatch => "Les mots de passe ne correspondent pas";
  @override String get lblRegistrationSuccess => "Inscription réussie!";
  @override String get lblRegistrationFailed => "Échec de l'inscription";
  @override String get lblAlreadyHaveAccount => "Vous avez déjà un compte?";
  @override String get lblVerifyCode => "Vérifier le code";
  @override String get lblNewPassword => "Nouveau mot de passe";
  @override String get lblSuccess => "Succès!";
  @override String get lblEnterEmailToReset => "Entrez votre email pour réinitialiser";
  @override String get lblSendCode => "Envoyer le code";
  @override String get lblResetCodeSent => "Code envoyé à votre email";
  @override String get lblSomethingWentWrong => "Une erreur s'est produite";
  @override String get lblPleaseEnterEmail => "Veuillez entrer votre email";
  @override String get lblEnterCodeSentToEmail => "Entrez le code envoyé";
  @override String get lblEnterVerificationCode => "Entrez le code de vérification";
  @override String get lblResendCode => "Renvoyer le code";
  @override String get lblVerify => "Vérifier";
  @override String get lblEnterNewPassword => "Entrez le nouveau mot de passe";
  @override String get lblConfirmNewPassword => "Confirmez le nouveau mot de passe";
  @override String get lblPleaseEnterCode => "Veuillez entrer le code";
  @override String get lblPleaseEnterPassword => "Veuillez entrer le mot de passe";
  @override String get lblPasswordTooShort => "Le mot de passe doit contenir au moins 6 caractères";
  @override String get lblResetPassword => "Réinitialiser le mot de passe";
  @override String get lblPasswordResetSuccess => "Mot de passe réinitialisé!";
  @override String get lblBackToLogin => "Retour à la connexion";
  @override String get lblProfile => "Profil";
  @override String get lblEditProfile => "Modifier le profil";
  @override String get lblUpdateYourInfo => "Mettre à jour vos informations";
  @override String get lblChangePassword => "Changer le mot de passe";
  @override String get lblUpdateYourPassword => "Mettre à jour votre mot de passe";
  @override String get lblYourBookmarks => "Voir vos signets";
  @override String get lblNotifications => "Notifications";
  @override String get lblManageNotifications => "Gérer les notifications";
  @override String get lblHelpSupport => "Aide et support";
  @override String get lblGetHelp => "Obtenir de l'aide";
  @override String get lblLogout => "Déconnexion";
  @override String get lblLogoutConfirmation => "Voulez-vous vous déconnecter?";
  @override String get lblLogoutSuccess => "Déconnexion réussie";
  @override String get lblDeleteAccount => "Supprimer le compte";
  @override String get lblDeleteAccountWarning => "Cette action est irréversible!";
  @override String get lblEnterPasswordToConfirm => "Entrez le mot de passe pour confirmer";
  @override String get lblAccountDeleted => "Compte supprimé";
  @override String get lblDelete => "Supprimer";
  @override String get lblNotLoggedIn => "Non connecté";
  @override String get lblLoginToAccessProfile => "Connectez-vous pour accéder";
  @override String get lblBio => "Bio";
  @override String get lblBooksRead => "Lus";
  @override String get lblBookmarks => "Signets";
  @override String get lblFavorites => "Favoris";
  @override String get lblCurrentPassword => "Mot de passe actuel";
  @override String get lblPasswordChangedSuccess => "Mot de passe modifié!";
  @override String get lblUpdate => "Mettre à jour";
  @override String get lblEnterBio => "Parlez-nous de vous...";
  @override String get lblSaveChanges => "Enregistrer";
  @override String get lblProfileUpdated => "Profil mis à jour!";
  @override String get lblAvatarUpdated => "Photo mise à jour!";
  @override String get lblChoosePhoto => "Choisir une photo";
  @override String get lblCamera => "Caméra";
  @override String get lblGallery => "Galerie";

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

  @override String get lblAdLoadingWait => "Ad is loading, please wait...";

  // Monetization / Ad Limit
  @override String get lblDailyAdLimitReached => "Daily Limit Reached!";
  @override String get lblDailyAdLimitMsg => "You've reached today's ad watching limit. Try again tomorrow or get Premium.";
  @override String get lblGetPremiumNow => "Get Premium Now";
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
