import 'package:flutter/material.dart';

class AichatPage extends StatefulWidget {
  const AichatPage({super.key});

  @override
  State<AichatPage> createState() => _AichatPageState();
}

class _AichatPageState extends State<AichatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("AI Chat", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
