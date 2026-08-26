import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/webview_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set status bar and navigation bar styles matching KitchenOS light theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFFFDFBF7),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize notification service hook
  await NotificationService().initialize();

  runApp(const KitchenOSApp());
}

class KitchenOSApp extends StatelessWidget {
  const KitchenOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KitchenOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFDFBF7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF292524),
          primary: const Color(0xFF292524),
          onPrimary: const Color(0xFFF5F5F4),
          surface: const Color(0xFFFDFBF7),
          onSurface: const Color(0xFF1C1917),
          error: const Color(0xFFEF4444),
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFFFFFFFF),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      home: const WebViewScreen(),
    );
  }
}
