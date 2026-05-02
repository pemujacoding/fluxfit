import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluxfit/controllers/init_controller.dart';
import 'package:fluxfit/database/db_helper.dart';
import 'package:fluxfit/pages/login_page.dart';
import 'package:fluxfit/pages/main_screen.dart'; // Pastikan import wrapper navigasi kamu

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await DBHelper().database; // init DB
  await InitController().initDataKalistenik();
  await InitController().initDataLevel();
  await InitController().initDataKalistenikList();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Halaman pertama yang muncul tetap Login
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        // MainScreen adalah wrapper yang isinya 4 tab (Home, Game, Kesan, Profile)
        '/main': (context) => const MainScreen(username: AutofillHints.username),
      },
    );
  }
}
