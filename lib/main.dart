import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'services/shop_service.dart';
import 'screens/auth_screen.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with graceful error catching
  try {
    // Use the same Firebase config for both Web and Android
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDmRVjAENQOfCq-8oWJdans0ijwI3QJnpI",
        authDomain: "computer-shop-app-68ec9.firebaseapp.com",
        projectId: "computer-shop-app-68ec9",
        storageBucket: "computer-shop-app-68ec9.firebasestorage.app",
        messagingSenderId: "964873187877",
        appId: "1:964873187877:web:73c5cfe744298e47d585cc",
        measurementId: "G-5HRW3CELBN",
      ),
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ShopService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gaming Equipment Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF08080E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FF88), // Neon Green
          secondary: Color(0xFF00C3FF), // Neon Blue
          surface: Color(0xFF12121E), // Dark Glass Surface
          onPrimary: Colors.black,
          onSecondary: Colors.black,
        ),
        textTheme: GoogleFonts.rajdhaniTextTheme(
          ThemeData.dark().textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
        ),
      ),
      home: Consumer<ShopService>(
        builder: (context, service, _) {
          if (service.currentUser != null) {
            return const MainNavigationScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
