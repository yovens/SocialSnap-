import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentCode = localeProvider.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.languagePageTitle),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.chooseLanguage,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          RadioListTile<String>(
            value: "fr",
            groupValue: currentCode,
            onChanged: (_) => _selectLocale(context, const Locale('fr')),
            title: Text(l10n.french),
          ),

          RadioListTile<String>(
            value: "ht",
            groupValue: currentCode,
            onChanged: (_) => _selectLocale(context, const Locale('ht')),
            title: Text(l10n.haitianCreole),
          ),
        ],
      ),
    );
  }

  void _selectLocale(BuildContext context, Locale locale) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    localeProvider.setLocale(locale);

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.languageChangedRestartHint)),
    );
  }
}
