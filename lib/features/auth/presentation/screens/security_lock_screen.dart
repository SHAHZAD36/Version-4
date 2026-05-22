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
  ConsumerState createState() => _SecurityLockScreenState();
}

class _SecurityLockScreenState extends ConsumerState<SecurityLockScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  final TextEditingController _pinCtrl = TextEditingController();
  String _errorMessage = '';
  String _savedPin = '1234';
  bool _loading = true;
  bool _biometricAvailable = false;
  bool _biometricEnabled = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future _init() async {
    await _loadPin();
    await _checkBiometric();
    setState(() => _loading = false);
    // Auto-trigger fingerprint after 500ms
    if (_biometricAvailable && _biometricEnabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) _authenticateWithBiometrics();
    }
  }

  Future _loadPin() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query('users', limit: 1);
      if (result.isNotEmpty) {
        setState(() {
          _savedPin = result.first['pin'] as String? ?? '1234';
          _biometricEnabled = (result.first['biometric_enabled'] as int? ?? 1) == 1;
        });
      } else {
        // Insert default user if not exists
        await db.insert('users', {'pin': '1234', 'biometric_enabled': 1});
      }
    } catch (e) {
      _savedPin = '1234';
    }
  }

  Future _checkBiometric() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      final availableBiometrics = await _auth.getAvailableBiometrics();
      
      setState(() => _biometricAvailable = (canCheck || isSupported) && availableBiometrics.isNotEmpty);
    } catch (_) {
      setState(() => _biometricAvailable = false);
    }
  }

  Future _authenticateWithBiometrics() async {
    final lang = ref.read(languageProvider);
    try {
      final result = await _auth.authenticate(
        localizedReason: AppStrings.getText(lang, 'biometric_reason'),
        options: const AuthenticationOptions(
          biometricOnly: false, 
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      if (result && mounted) _goToApp();
    } catch (e) {
      debugPrint('Biometric error: $e');
    }
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
              onChangedimport 'package:flutter/material.dart';
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
  ConsumerState createState() => _SecurityLockScreenState();
}

class _SecurityLockScreenState extends ConsumerState<SecurityLockScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  final TextEditingController _pinCtrl = TextEditingController();
  String _errorMessage = '';
  String _savedPin = '1234';
  bool _loading = true;
  bool _biometricAvailable = false;
  bool _biometricEnabled = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future _init() async {
    await _loadPin();
    await _checkBiometric();
    setState(() => _loading = false);
    // Auto-trigger fingerprint after 500ms
    if (_biometricAvailable && _biometricEnabled) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) _authenticateWithBiometrics();
    }
  }

  Future _loadPin() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query('users', limit: 1);
      if (result.isNotEmpty) {
        setState(() {
          _savedPin = result.first['pin'] as String? ?? '1234';
          _biometricEnabled = (result.first['biometric_enabled'] as int? ?? 1) == 1;
        });
      } else {
        // Insert default user if not exists
        await db.insert('users', {'pin': '1234', 'biometric_enabled': 1});
      }
    } catch (e) {
      _savedPin = '1234';
    }
  }

  Future _checkBiometric() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      final availableBiometrics = await _auth.getAvailableBiometrics();
      
      setState(() => _biometricAvailable = (canCheck || isSupported) && availableBiometrics.isNotEmpty);
    } catch (_) {
      setState(() => _biometricAvailable = false);
    }
  }

  Future _authenticateWithBiometrics() async {
    final lang = ref.read(languageProvider);
    try {
      final result = await _auth.authenticate(
        localizedReason: AppStrings.getText(lang, 'biometric_reason'),
        options: const AuthenticationOptions(
          biometricOnly: false, 
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      if (result && mounted) _goToApp();
    } catch (e) {
      debugPrint('Biometric error: $e');
    }
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
              onChanged
