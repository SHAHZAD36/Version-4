import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../../data/models/settings_model.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/localization/app_strings.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<<SettingsScreen> {
  late TextEditingController _bizCtrl;
  late TextEditingController _ownerCtrl;
  bool _init = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final lang = ref.watch(languageProvider);
    final isUrdu = lang == AppLanguage.urdu;

    if (settings != null && !_init) {
      _bizCtrl = TextEditingController(text: settings.businessName);
      _ownerCtrl = TextEditingController(text: settings.ownerName ?? '');
      _init = true;
    } else if (!_init) {
      _bizCtrl = TextEditingController();
      _ownerCtrl = TextEditingController();
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.getText(lang, 'settings'))),
      body: settings == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                // Language Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      Text(AppStrings.getText(lang, 'language'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => ref.read(languageProvider.notifier).setLanguage(AppLanguage.urdu),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isUrdu ? Theme.of(context).colorScheme.primary : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(child: Text('اردو',
                                  style: TextStyle(color: isUrdu ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.bold, fontSize: 16))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => ref.read(languageProvider.notifier).setLanguage(AppLanguage.english),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: !isUrdu ? Theme.of(context).colorScheme.primary : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(child: Text('English',
                                  style: TextStyle(color: !isUrdu ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.bold, fontSize: 16))),
                            ),
                          ),
                        ),
                      ]),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
                // Business Info Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      Text(AppStrings.getText(lang, 'business_info'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      TextField(controller: _bizCtrl,
                          decoration: InputDecoration(labelText: AppStrings.getText(lang, 'business_name'),
                              border: const OutlineInputBorder())),
                      const SizedBox(height: 12),
                      TextField(controller: _ownerCtrl,
                          decoration: InputDecoration(labelText: AppStrings.getText(lang, 'owner_name'),
                              border: const OutlineInputBorder())),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                        onPressed: () {
                          ref.read(settingsProvider.notifier).update(SettingsModel(
                              id: settings.id, businessName: _bizCtrl.text, ownerName: _ownerCtrl.text,
                              currencySymbol: settings.currencySymbol, themeMode: settings.themeMode,
                              language: isUrdu ? 'ur' : 'en'));
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppStrings.getText(lang, 'settings_saved'))));
                        },
                        child: Text(AppStrings.getText(lang, 'save')),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(children: [
                    ListTile(leading: const Icon(Icons.info),
                        title: Text(AppStrings.getText(lang, 'version')), trailing: const Text('1.0.0')),
                    const Divider(height: 1),
                    ListTile(leading: const Icon(Icons.business),
                        title: Text(AppStrings.getText(lang, 'app_title')),
                        subtitle: Text(AppStrings.getText(lang, 'inventory_title'))),
                  ]),
                ),
              ]),
            ),
    );
  }
}
