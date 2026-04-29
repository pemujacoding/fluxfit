import 'package:flutter/material.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Budget dan Jadwal",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          Column(
            children: [
              Text("Budget alat fitness"),
              ElevatedButton(onPressed: () {}, child: Text("+ tambah")),
              SizedBox(
                child: Column(
                  children: [
                    TextButton(onPressed: () {}, child: Text("Alat pemula")),
                    TextButton(onPressed: () {}, child: Text("Alat lanjutan")),
                  ],
                ),
              ),
              Text("Jadwal olahraga"),
              ElevatedButton(onPressed: () {}, child: Text("+ tambah")),
              SizedBox(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text("Olahraga pagi : 09.00 - 10.00,"),
                    ),
                    TextButton(onPressed: () {}, child: Text("M T W T")),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
