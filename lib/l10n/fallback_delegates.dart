import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// 🟢 Flutter SDK a poko gen tradiksyon entegre pou Kreyòl Ayisyen ("ht")
/// pou MaterialLocalizations/CupertinoLocalizations/WidgetsLocalizations.
/// San anbalaj sa a, aplikasyon an ta "crash" ak yon erè "No
/// MaterialLocalizations found" chak fwa locale a se 'ht'.
///
/// Solisyon: nou di delegate yo "wi, mwen sipòte 'ht'", men anndan, nou
/// chaje done Fransè yo (ki pi pwòch la) pou eleman natif yo (dat picker,
/// bouton "OK/Annuler" sistèm, elatriye). Sèl tèks pa nou yo (AppLocalizations)
/// ap parèt an Kreyòl; eleman natif Flutter yo ap rete an Fransè.
class HtMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const HtMaterialLocalizationsDelegate();

  static const Locale _fallback = Locale('fr');

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'ht' ||
      GlobalMaterialLocalizations.delegate.isSupported(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    final effective = locale.languageCode == 'ht' ? _fallback : locale;
    return GlobalMaterialLocalizations.delegate.load(effective);
  }

  @override
  bool shouldReload(HtMaterialLocalizationsDelegate old) => false;
}

class HtCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const HtCupertinoLocalizationsDelegate();

  static const Locale _fallback = Locale('fr');

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'ht' ||
      GlobalCupertinoLocalizations.delegate.isSupported(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    final effective = locale.languageCode == 'ht' ? _fallback : locale;
    return GlobalCupertinoLocalizations.delegate.load(effective);
  }

  @override
  bool shouldReload(HtCupertinoLocalizationsDelegate old) => false;
}

class HtWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const HtWidgetsLocalizationsDelegate();

  static const Locale _fallback = Locale('fr');

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'ht' ||
      GlobalWidgetsLocalizations.delegate.isSupported(locale);

  @override
  Future<WidgetsLocalizations> load(Locale locale) {
    final effective = locale.languageCode == 'ht' ? _fallback : locale;
    return GlobalWidgetsLocalizations.delegate.load(effective);
  }

  @override
  bool shouldReload(HtWidgetsLocalizationsDelegate old) => false;
}
