import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/providers/language_provider.dart';
import 'features/auth/presentation/screens/security_lock_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: ChaudharyTradersApp()));
}

class ChaudharyTradersApp extends ConsumerWidget {
  const ChaudharyTradersApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final isUrdu = language == AppLanguage.urdu;
    final locale = isUrdu ? const Locale('ur', 'PK') : const Locale('en', 'US');

    return MaterialApp(
      title: 'Chaudhary Traders',
      debugShowCheckedModeBanner: false,
      locale: locale,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.light),
        textTheme: isUrdu ? GoogleFonts.notoNastaliqUrduTextTheme() : GoogleFonts.poppinsTextTheme(),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US'), Locale('ur', 'PK')],
      home: SecurityLockScreen(nextScreen: const DashboardScreen()),
    );
  }
}
