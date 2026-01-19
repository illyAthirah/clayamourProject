import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/landing_page.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:clayamour/pages/main_nav_page.dart';
import 'package:clayamour/services/firebase_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Stripe.publishableKey = 'pk_test_51SrHwuQd2brvuXIB2fbsC19WBzac7FJ9njPiGkC8CvXSWTl6REP5MbcvBr5wuILq8hbpOPXAUSjVFufsMJeTj7CW00rdTPqXbF';
  Stripe.merchantIdentifier = 'merchant.com.clayamour';
  Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();
  runApp(const ClayAmourApp());
}

class ClayAmourApp extends StatelessWidget {
  const ClayAmourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ClayAmour',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: StreamBuilder(
        stream: FirebaseService.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.data != null) {
            return const MainNavPage();
          }
          return const LandingPage();
        },
      ),
    );
  }
}
