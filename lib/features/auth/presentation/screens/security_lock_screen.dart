import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utils/database_helper.dart';

class SecurityLockScreen extends ConsumerStatefulWidget {
  final Widget nextScreen;
  const SecurityLockScreen({super.key, required this.nextScreen});
  @override
  ConsumerState<SecurityLockScreen> createState() => _SecurityLockScreenState();
}

class _SecurityLockScreenState extends ConsumerState<SecurityLockScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  final TextEditingController _pinCtrl = TextEditingController();
  String _errorMessage = '';
  String _savedPin = '1234';
  bool _loading = true;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadPin();
    await _checkBiometric();
    setState(() => _loading = false);
    // Auto-trigger fingerprint
    if (_biometricAvailable) {
      await Future.delayed(const Duration(milliseconds: 500));
      _authenticateWithBiometrics();
    }
  }

  Future<void> _loadPin() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query('users', limit: 1);
      if (result.isNotEmpty) {
        _savedPin = result.first['pin'] as String;
      }
    } catch (e) {
      _savedPin = '1234';
    }
  }

  Future<void> _checkBiometric() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      setState(() => _biometricAvailable = canCheck || isSupported);
    } catch (_) {
      setState(() => _biometricAvailable = false);
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    final lang = ref.read(languageProvider);
    try {
      final result = await _auth.authenticate(
        localizedReason: AppStrings.getText(lang, 'biometric_reason'),
        options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
      );
      if (result && mounted) _goToApp();
    } catch (_) {}
  }

  void _verifyPin() {
    final lang = ref.read(languageProvider);
    if (_pinCtrl.text == _savedPin) {
      _goToApp();
    } else {
      setState(() {
        _errorMessage = AppStrings.getText(lang, 'invalid_pin');
        _pinCtrl.clear();
      });
    }
  }

  void _goToApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => widget.nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final isUrdu = lang == AppLanguage.urdu;

    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            // Language toggle top right
            Align(
              alignment: Alignment.topRight,
              child: TextButton.icon(
                onPressed: () => ref.read(languageProvider.notifier).toggleLanguage(),
                icon: const Icon(Icons.language, size: 18),
                label: Text(isUrdu ? 'English' : 'اردو'),
              ),
            ),
            const Spacer(),
            // Logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_outline, size: 60,
                  color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text(AppStrings.getText(lang, 'app_title'),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(AppStrings.getText(lang, 'security_subtitle'),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 40),
            // PIN field
            TextField(
              controller: _pinCtrl,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, letterSpacing: 20),
              decoration: InputDecoration(
                counterText: '',
                hintText: '••••',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
              onChanged: (v) { if (v.length >= 4) _verifyPin(); },
            ),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            // Buttons
            Row(children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: _verifyPin,
                  child: Text(AppStrings.getText(lang, 'verify_button'),
                      style: const TextStyle(fontSize: 16)),
                ),
              ),
              if (_biometricAvailable) ...[
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.fingerprint, size: 36),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: _authenticateWithBiometrics,
                    tooltip: 'Fingerprint',
                  ),
                ),
              ],
            ]),
            const SizedBox(height: 16),
            // Change PIN button
            TextButton.icon(
              onPressed: () => _showChangePinDialog(lang),
              icon: const Icon(Icons.edit, size: 16),
              label: Text(AppStrings.getText(lang, 'change_pin')),
            ),
            const Spacer(),
          ]),
        ),
      ),
    );
  }

  void _showChangePinDialog(AppLanguage lang) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String dialogError = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text(AppStrings.getText(lang, 'change_pin')),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: oldCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: AppStrings.getText(lang, 'old_pin'),
                border: const OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: AppStrings.getText(lang, 'new_pin'),
                border: const OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: AppStrings.getText(lang, 'confirm_pin'),
                border: const OutlineInputBorder(),
                counterText: '',
              ),
            ),
            if (dialogError.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(dialogError, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ],
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppStrings.getText(lang, 'cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (oldCtrl.text != _savedPin) {
                  setDlgState(() => dialogError = AppStrings.getText(lang, 'invalid_pin'));
                  return;
                }
                if (newCtrl.text.length < 4) {
                  setDlgState(() => dialogError = AppStrings.getText(lang, 'pin_min_length'));
                  return;
                }
                if (newCtrl.text != confirmCtrl.text) {
                  setDlgState(() => dialogError = AppStrings.getText(lang, 'pin_mismatch'));
                  return;
                }
                // Save to DB
                final db = await DatabaseHelper.instance.database;
                await db.update('users', {'pin': newCtrl.text});
                setState(() => _savedPin = newCtrl.text);
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppStrings.getText(lang, 'pin_changed'))));
                }
              },
              child: Text(AppStrings.getText(lang, 'save')),
            ),
          ],
        ),
      ),
    );
  }
}
