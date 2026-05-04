import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluxfit/controllers/init_controller.dart';
import 'package:fluxfit/database/db_helper.dart';
import 'package:fluxfit/pages/login_page.dart';
import 'package:fluxfit/pages/main_screen.dart';
import 'package:fluxfit/services/notification_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DBHelper().database; // init DB
  await InitController().initDataKalistenik();
  await InitController().initDataLevel();
  await InitController().initDataKalistenikList();
  await InitController().initDataAlat();

  await NotificationService.init();

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
