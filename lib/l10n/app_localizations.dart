import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_fr.dart';
import 'app_localizations_ht.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
    Locale('ht'),
  ];

  /// No description provided for @loginWelcomeBack.
  ///
  /// In fr, this message translates to:
  /// **'BON RETOUR PARMI NOUS'**
  String get loginWelcomeBack;

  /// No description provided for @emailLabel.
  ///
  /// In fr, this message translates to:
  /// **'EMAIL'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In fr, this message translates to:
  /// **'MOT DE PASSE'**
  String get passwordLabel;

  /// No description provided for @forgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In fr, this message translates to:
  /// **'SE CONNECTER'**
  String get loginButton;

  /// No description provided for @noAccountRegister.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ? Créer un compte'**
  String get noAccountRegister;

  /// No description provided for @fillAllFields.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez remplir tous les champs.'**
  String get fillAllFields;

  /// No description provided for @verifyEmailBeforeLogin.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez vérifier votre e-mail avant de vous connecter.'**
  String get verifyEmailBeforeLogin;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser le mot de passe'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordDesc.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre e-mail pour recevoir un lien de réinitialisation.'**
  String get resetPasswordDesc;

  /// No description provided for @emailAddressLabel.
  ///
  /// In fr, this message translates to:
  /// **'ADRESSE E-MAIL'**
  String get emailAddressLabel;

  /// No description provided for @emailAddressHint.
  ///
  /// In fr, this message translates to:
  /// **'exemple@gmail.com'**
  String get emailAddressHint;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @send.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get send;

  /// No description provided for @resetEmailSent.
  ///
  /// In fr, this message translates to:
  /// **'E-mail de réinitialisation envoyé ! Vérifiez votre boîte mail.'**
  String get resetEmailSent;

  /// No description provided for @createAccountTitle.
  ///
  /// In fr, this message translates to:
  /// **'CRÉER UN COMPTE'**
  String get createAccountTitle;

  /// No description provided for @joinCommunity.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez la communauté SocialSnap'**
  String get joinCommunity;

  /// No description provided for @usernameLabel.
  ///
  /// In fr, this message translates to:
  /// **'PSEUDONYME'**
  String get usernameLabel;

  /// No description provided for @usernameHint.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez un pseudo'**
  String get usernameHint;

  /// No description provided for @passwordHintCreate.
  ///
  /// In fr, this message translates to:
  /// **'Créez un mot de passe sécurisé'**
  String get passwordHintCreate;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'CONFIRMER LE MOT DE PASSE'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez le mot de passe'**
  String get confirmPasswordHint;

  /// No description provided for @registerButton.
  ///
  /// In fr, this message translates to:
  /// **'S\'INSCRIRE'**
  String get registerButton;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas.'**
  String get passwordsDontMatch;

  /// No description provided for @usernameTaken.
  ///
  /// In fr, this message translates to:
  /// **'Ce pseudonyme est déjà pris.'**
  String get usernameTaken;

  /// No description provided for @userFetchError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la récupération de l\'utilisateur.'**
  String get userFetchError;

  /// No description provided for @accountCreatedVerify.
  ///
  /// In fr, this message translates to:
  /// **'Compte créé ! Veuillez vérifier votre e-mail avant de vous connecter.'**
  String get accountCreatedVerify;

  /// No description provided for @genericErrorWithDetail.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue : {error}'**
  String genericErrorWithDetail(String error);

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ? Se connecter'**
  String get alreadyHaveAccount;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @defaultUserName.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get defaultUserName;

  /// No description provided for @emailVerified.
  ///
  /// In fr, this message translates to:
  /// **'Email vérifié'**
  String get emailVerified;

  /// No description provided for @emailNotVerified.
  ///
  /// In fr, this message translates to:
  /// **'Email non vérifié'**
  String get emailNotVerified;

  /// No description provided for @resendVerificationEmail.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer email de vérification'**
  String get resendVerificationEmail;

  /// No description provided for @appearanceSection.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get appearanceSection;

  /// No description provided for @darkMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode sombre'**
  String get darkMode;

  /// No description provided for @securitySection.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get securitySection;

  /// No description provided for @changePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer mot de passe'**
  String get changePassword;

  /// No description provided for @verifyEmail.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier email'**
  String get verifyEmail;

  /// No description provided for @notificationsSection.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notificationsSection;

  /// No description provided for @pushNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @othersSection.
  ///
  /// In fr, this message translates to:
  /// **'Autres'**
  String get othersSection;

  /// No description provided for @languageSetting.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get languageSetting;

  /// No description provided for @languageSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Changer la langue de l\'application'**
  String get languageSubtitle;

  /// No description provided for @privacySetting.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get privacySetting;

  /// No description provided for @privacySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérer vos données et permissions'**
  String get privacySubtitle;

  /// No description provided for @helpSetting.
  ///
  /// In fr, this message translates to:
  /// **'Aide'**
  String get helpSetting;

  /// No description provided for @helpSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'FAQ et support utilisateur'**
  String get helpSubtitle;

  /// No description provided for @settingsFooterInfo.
  ///
  /// In fr, this message translates to:
  /// **'Gérez vos préférences et informations de l\'application'**
  String get settingsFooterInfo;

  /// No description provided for @dangerSection.
  ///
  /// In fr, this message translates to:
  /// **'Danger'**
  String get dangerSection;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer compte'**
  String get deleteAccount;

  /// No description provided for @verificationEmailSent.
  ///
  /// In fr, this message translates to:
  /// **'Email de vérification envoyé'**
  String get verificationEmailSent;

  /// No description provided for @currentPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel'**
  String get currentPassword;

  /// No description provided for @currentPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre mot de passe actuel'**
  String get currentPasswordHint;

  /// No description provided for @newPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get newPassword;

  /// No description provided for @newPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 6 caractères'**
  String get newPasswordHint;

  /// No description provided for @validate.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get validate;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe modifié avec succès !'**
  String get passwordChangedSuccess;

  /// No description provided for @wrongCurrentPassword.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe actuel est incorrect.'**
  String get wrongCurrentPassword;

  /// No description provided for @newPasswordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Le nouveau mot de passe doit contenir au moins 6 caractères.'**
  String get newPasswordTooShort;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir vous déconnecter ?'**
  String get logoutConfirmMessage;

  /// No description provided for @deleteAccountConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible.'**
  String get deleteAccountConfirmMessage;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @errorWithDetail.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {error}'**
  String errorWithDetail(String error);

  /// No description provided for @languagePageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get languagePageTitle;

  /// No description provided for @chooseLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre langue'**
  String get chooseLanguage;

  /// No description provided for @french.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @haitianCreole.
  ///
  /// In fr, this message translates to:
  /// **'Kreyòl Ayisyen'**
  String get haitianCreole;

  /// No description provided for @languageChangedRestartHint.
  ///
  /// In fr, this message translates to:
  /// **'La langue de l\'application a été changée.'**
  String get languageChangedRestartHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['fr', 'ht'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fr':
      return AppLocalizationsFr();
    case 'ht':
      return AppLocalizationsHt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
