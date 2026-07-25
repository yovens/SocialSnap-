// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get loginWelcomeBack => 'BON RETOUR PARMI NOUS';

  @override
  String get emailLabel => 'EMAIL';

  @override
  String get emailHint => 'Adresse e-mail';

  @override
  String get passwordLabel => 'MOT DE PASSE';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get loginButton => 'SE CONNECTER';

  @override
  String get noAccountRegister => 'Pas encore de compte ? Créer un compte';

  @override
  String get fillAllFields => 'Veuillez remplir tous les champs.';

  @override
  String get verifyEmailBeforeLogin =>
      'Veuillez vérifier votre e-mail avant de vous connecter.';

  @override
  String get resetPasswordTitle => 'Réinitialiser le mot de passe';

  @override
  String get resetPasswordDesc =>
      'Entrez votre e-mail pour recevoir un lien de réinitialisation.';

  @override
  String get emailAddressLabel => 'ADRESSE E-MAIL';

  @override
  String get emailAddressHint => 'exemple@gmail.com';

  @override
  String get cancel => 'Annuler';

  @override
  String get send => 'Envoyer';

  @override
  String get resetEmailSent =>
      'E-mail de réinitialisation envoyé ! Vérifiez votre boîte mail.';

  @override
  String get createAccountTitle => 'CRÉER UN COMPTE';

  @override
  String get joinCommunity => 'Rejoignez la communauté SocialSnap';

  @override
  String get usernameLabel => 'PSEUDONYME';

  @override
  String get usernameHint => 'Choisissez un pseudo';

  @override
  String get passwordHintCreate => 'Créez un mot de passe sécurisé';

  @override
  String get confirmPasswordLabel => 'CONFIRMER LE MOT DE PASSE';

  @override
  String get confirmPasswordHint => 'Confirmez le mot de passe';

  @override
  String get registerButton => 'S\'INSCRIRE';

  @override
  String get passwordsDontMatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get usernameTaken => 'Ce pseudonyme est déjà pris.';

  @override
  String get userFetchError =>
      'Erreur lors de la récupération de l\'utilisateur.';

  @override
  String get accountCreatedVerify =>
      'Compte créé ! Veuillez vérifier votre e-mail avant de vous connecter.';

  @override
  String genericErrorWithDetail(String error) {
    return 'Une erreur est survenue : $error';
  }

  @override
  String get alreadyHaveAccount => 'Déjà un compte ? Se connecter';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get defaultUserName => 'Utilisateur';

  @override
  String get emailVerified => 'Email vérifié';

  @override
  String get emailNotVerified => 'Email non vérifié';

  @override
  String get resendVerificationEmail => 'Renvoyer email de vérification';

  @override
  String get appearanceSection => 'Apparence';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get securitySection => 'Sécurité';

  @override
  String get changePassword => 'Changer mot de passe';

  @override
  String get verifyEmail => 'Vérifier email';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get othersSection => 'Autres';

  @override
  String get languageSetting => 'Langue';

  @override
  String get languageSubtitle => 'Changer la langue de l\'application';

  @override
  String get privacySetting => 'Confidentialité';

  @override
  String get privacySubtitle => 'Gérer vos données et permissions';

  @override
  String get helpSetting => 'Aide';

  @override
  String get helpSubtitle => 'FAQ et support utilisateur';

  @override
  String get settingsFooterInfo =>
      'Gérez vos préférences et informations de l\'application';

  @override
  String get dangerSection => 'Danger';

  @override
  String get logout => 'Déconnexion';

  @override
  String get deleteAccount => 'Supprimer compte';

  @override
  String get verificationEmailSent => 'Email de vérification envoyé';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get currentPasswordHint => 'Saisissez votre mot de passe actuel';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get newPasswordHint => 'Au moins 6 caractères';

  @override
  String get validate => 'Valider';

  @override
  String get passwordChangedSuccess => 'Mot de passe modifié avec succès !';

  @override
  String get wrongCurrentPassword => 'Le mot de passe actuel est incorrect.';

  @override
  String get newPasswordTooShort =>
      'Le nouveau mot de passe doit contenir au moins 6 caractères.';

  @override
  String get logoutConfirmTitle => 'Déconnexion';

  @override
  String get logoutConfirmMessage =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get deleteAccountConfirmMessage => 'Cette action est irréversible.';

  @override
  String get delete => 'Supprimer';

  @override
  String errorWithDetail(String error) {
    return 'Erreur : $error';
  }

  @override
  String get languagePageTitle => 'Langue';

  @override
  String get chooseLanguage => 'Choisissez votre langue';

  @override
  String get french => 'Français';

  @override
  String get haitianCreole => 'Kreyòl Ayisyen';

  @override
  String get languageChangedRestartHint =>
      'La langue de l\'application a été changée.';
}
