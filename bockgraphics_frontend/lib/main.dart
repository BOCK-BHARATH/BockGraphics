import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/company_selection_screen.dart';
import 'screens/ offer_form_screen.dart';
import 'screens/joining_form_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/completion_letter_form.dart';
import 'screens/completion_certificate_form.dart';



Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Prevent app from crashing in production
    debugPrint("ENV load failed: $e");
  }
  runApp(const InternLetterApp());
}

class InternLetterApp extends StatelessWidget {
  const InternLetterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Intern Letters',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/companies': (context) => const CompanySelectionScreen(),
        '/offer_form': (context) => const OfferFormScreen(),
        '/joining_form': (context) => const JoiningFormScreen(),
  '/completion_letter_form': (context) => const CompletionLetterFormScreen(),
  '/completion_certificate_form': (context) =>
      const CompletionCertificateForm(),
      },
    );
  }
}
