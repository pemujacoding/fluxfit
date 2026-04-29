import 'package:flutter/material.dart';
import 'package:fluxfit/database/db_helper.dart';
import 'package:fluxfit/controllers/init_controller.dart';
import 'package:fluxfit/pages/login_page.dart';

class InitPage extends StatefulWidget {
  const InitPage({super.key});

  @override
  State<InitPage> createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<void> initApp() async {
    try {
      print("INIT START");

      await DBHelper().database;
      print("DB DONE");

      await InitController().initDataKalistenik();
      print("KALISTENIK DONE");

      await InitController().initDataLevel();
      print("LEVEL DONE");

      await InitController().initDataKalistenikList();
      print("LIST DONE");

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e, s) {
      print("INIT ERROR: $e");
      print(s);

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text("INIT ERROR:\n$_error", textAlign: TextAlign.center),
        ),
      );
    }

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
