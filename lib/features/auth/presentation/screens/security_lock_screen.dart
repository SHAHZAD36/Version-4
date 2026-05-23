import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
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
    if (mounted) setState(() => _loading = false);
    if (_biometricAvailable) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) _authenticateWithBiometrics();
    }
  }

  Future<void> _loadPin() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query('users', limit: 1);
      if (result.isNotEmpty && result.first['pin'] != null) {
        _savedPin = result.first['pin'] as String;
      }
    } catch (_) {
      _savedPin = '1234';
    }
  }

  Future<void> _checkBiometric() async {
    try {
      final isDeviceSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      final available = isDeviceSupported || canCheck;
      if (mounted) setState(() => _biometricAvailable = available);
    } catch (_) {
      if (mounted) setState(() => _biometricAvailable = false);
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final result = await _auth.authenticate(
        localizedReason: 'Scan fingerprint to open Chaudhary Traders',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      if (result && mounted) _goToApp();
    } catch (e) {
      // Biometric failed silently - user can use PIN
    }
  }

  void _verifyPin() {
    if (_pinCtrl.text.trim() == _savedPin) {
      _goToApp();
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN. Please try again.';
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

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Language toggle
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton.icon(
                    onPressed: () => ref.read(languageProvider.notifier).toggleLanguage(),
                    icon: const Icon(Icons.language, size: 18),
                    label: Text(isUrdu ? 'English' : 'اردو'),
                  ),
                ),
                const SizedBox(height: 32),
                // Lock icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock_outline, size: 60,
                      color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 20),
                Text('Chaudhary Traders',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  isUrdu ? 'PIN درج کریں یا فنگر پرنٹ اسکین کریں' : 'Enter PIN or scan fingerprint',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 36),
                // PIN field
                TextField(
                  controller: _pinCtrl,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, letterSpacing: 16),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '••••',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (v) { if (v.length >= 4) _verifyPin(); },
                ),
                if (_errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(_errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 13)),
                ],
                const SizedBox(height: 20),
                // Verify + Fingerprint buttons
                Row(children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _verifyPin,
                      child: Text(isUrdu ? 'تصدیق کریں' : 'Verify',
                          style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                  // Always show fingerprint button
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.primary, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                      color: _biometricAvailable
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Colors.grey[200],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.fingerprint, size: 36,
                          color: _biometricAvailable
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey),
                      onPressed: _authenticateWithBiometrics,
                      tooltip: _biometricAvailable
                          ? 'Fingerprint Login'
                          : 'Fingerprint not available on this device',
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                // Change PIN button - always visible
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _showChangePinDialog(),
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(isUrdu ? 'PIN تبدیل کریں' : 'Change PIN'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChangePinDialog() {
    final lang = ref.read(languageProvider);
    final isUrdu = lang == AppLanguage.urdu;
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String dialogError = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text(isUrdu ? 'PIN تبدیل کریں' : 'Change PIN'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: oldCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: isUrdu ? 'پرانا PIN' : 'Current PIN',
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
                labelText: isUrdu ? 'نیا PIN' : 'New PIN (4-6 digits)',
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
                labelText: isUrdu ? 'نئے PIN کی تصدیق' : 'Confirm New PIN',
                border: const OutlineInputBorder(),
                counterText: '',
              ),
            ),
            if (dialogError.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(dialogError,
                  style: const TextStyle(color: Colors.red, fontSize: 12)),
            ],
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isUrdu ? 'کینسل' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (oldCtrl.text.trim() != _savedPin) {
                  setDlgState(() => dialogError =
                      isUrdu ? 'غلط پرانا PIN' : 'Current PIN is incorrect');
                  return;
                }
                if (newCtrl.text.trim().length < 4) {
                  setDlgState(() => dialogError = isUrdu
                      ? 'PIN کم از کم 4 ہندسے'
                      : 'PIN must be at least 4 digits');
                  return;
                }
                if (newCtrl.text.trim() != confirmCtrl.text.trim()) {
                  setDlgState(() => dialogError =
                      isUrdu ? 'PIN match نہیں کی' : 'PINs do not match');
                  return;
                }
                final db = await DatabaseHelper.instance.database;
                final rows = await db.query('users', limit: 1);
                if (rows.isEmpty) {
                  await db.insert('users',
                      {'pin': newCtrl.text.trim(), 'use_fingerprint': 0});
                } else {
                  await db.update('users', {'pin': newCtrl.text.trim()});
                }
                if (mounted) setState(() => _savedPin = newCtrl.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(isUrdu
                        ? 'PIN کامیابی سے تبدیل ہو گئی'
                        : 'PIN changed successfully'),
                    backgroundColor: Colors.green,
                  ));
                }
              },
              child: Text(isUrdu ? 'محفوظ کریں' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
