import 'package:flutter/material.dart';
import 'package:fluxfit/controllers/init_controller.dart';
import 'package:fluxfit/database/db_helper.dart';
import 'package:fluxfit/pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    // Tambahkan MaterialApp di sini
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // Opsional: menghilangkan banner debug
      home: LoginPage(),
    );
  }
}
