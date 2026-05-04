import 'package:flutter/material.dart';
import 'home_page.dart';
import 'game_page.dart';
import 'kesan_pesan_page.dart';
import 'profile_page.dart';

class MainScreen extends StatefulWidget {
  final String username; // Simpan di sini
  const MainScreen({
    super.key,
    required this.username,
  }); // Pakai 'this.username'

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Pindahkan _pages ke dalam build agar bisa mengakses 'widget.username'
    final List<Widget> pages = [
      const HomePage(),
      const GamePage(),
      const KesanPesanPage(),
      ProfilePage(username: widget.username), // Sekarang 'widget' bisa diakses
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports_rounded),
            label: 'Game',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Kesan'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
