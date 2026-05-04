import 'package:flutter/material.dart';
import 'package:fluxfit/models/checkin.dart';
import 'package:fluxfit/pages/airecomendation_page.dart';
import 'package:fluxfit/pages/calendar_page.dart';
import 'package:fluxfit/pages/calis_page.dart';
import 'package:fluxfit/pages/game_page.dart';
import 'package:fluxfit/pages/plan_page.dart';
import 'package:fluxfit/pages/walkjog_page.dart';
import 'package:fluxfit/controllers/checkin_controller.dart';
import 'package:fluxfit/services/weather_service.dart';
import 'package:fluxfit/session/session_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CheckinController checkinController = CheckinController();

  bool isCheckedIn = false;
  List<bool> weeklyStatus = List.generate(7, (_) => false);
  List<String> days = ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"];
  final todayIndex = DateTime.now().weekday - 1; // Senin = 0

  String temperature = "--";
  String weatherDescription = "Memuat...";
  String weatherIconCode = "01d";
  bool isWeatherLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCheckinData();
    _getWeather();
  }

  Future<void> _loadCheckinData() async {
    final userId = await SessionHelper.getUserId();
    if (userId == null) return;

    final checked = await checkinController.isCheckedInToday(userId);
    final weekly = await checkinController.getWeeklyStatus(userId);

    setState(() {
      isCheckedIn = checked;
      weeklyStatus = weekly;
    });
  }

  Future<void> _handleCheckin() async {
    final userId = await SessionHelper.getUserId();
    if (userId == null) return;

    final now = DateTime.now().toIso8601String();

    await checkinController.insertCheckin(
      Checkin(userId: userId, datetime: now),
    );

    await _loadCheckinData(); // refresh UI
  }

  Future<void> _getWeather() async {
    try {
      final data = await WeatherService().fetchWeather();
      setState(() {
        temperature = data['main']['temp'].round().toString();
        weatherDescription = data['weather'][0]['description'];
        weatherIconCode = data['weather'][0]['icon'];
      });
    } catch (e) {
      setState(() {
        weatherDescription = "Gagal memuat cuaca";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Background aplikasi yang soft
      appBar: AppBar(
        title: const Text(
          "FluxFit",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildWeatherWidget(),
          const SizedBox(height: 20),
          // Section Check-in Harian
          _buildCheckInCard(),
          const SizedBox(height: 30),

          // Section Menu Utama
          const Text(
            "Pilih Menu Latihan",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          _buildFeatureButton(
            title: "Kalistenik",
            subtitle: "Latihan beban tubuh",
            colors: [Colors.blueAccent, Colors.cyan],
            icon: Icons.fitness_center,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalisPage()),
              );
            },
          ),
          _buildFeatureButton(
            title: "Jalan dan Jogging",
            subtitle: "Pantau langkah kakimu",
            colors: [Colors.teal, Colors.greenAccent],
            icon: Icons.directions_run,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WalkjogPage()),
              );
            },
          ),
          _buildFeatureButton(
            title: "AI Coach",
            subtitle: "Buat rekomendasi latihanmu",
            colors: [Colors.purpleAccent, Colors.deepPurple],
            icon: Icons.smart_toy,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AiRecommendationPage(),
                ),
              );
            },
          ),
          _buildFeatureButton(
            title: "Planning",
            subtitle: "Tentukan budget dan jadwal latihanmu",
            colors: [Colors.orangeAccent, Colors.redAccent],
            icon: Icons.assignment_add,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlanPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget untuk Card Check-in
  Widget _buildCheckInCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Check In Harian",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.calendar_month,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CalendarPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              GestureDetector(
                onTap: isCheckedIn ? null : _handleCheckin,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCheckedIn ? Colors.grey[300] : Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCheckedIn ? Icons.check : Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Barisan 7 Hari Terakhir
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              return Column(
                children: [
                  Text(
                    days[index],
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Icon(
                    weeklyStatus[index]
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: weeklyStatus[index]
                        ? (index == todayIndex
                              ? Colors.green
                              : Colors.blueAccent)
                        : Colors.grey[300],
                    size: 28,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // Widget untuk Button Besar dengan Gradasi dan Gambar Transparan (Icon)
  Widget _buildFeatureButton({
    required String title,
    required String subtitle,
    required List<Color> colors,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Gambar/Icon Transparan di Latar Belakang
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(icon, size: 100, color: Colors.white.withOpacity(0.2)),
          ),
          // Konten Teks
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // InkWell diletakkan paling atas agar bisa diklik
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onTap,
              ),
            ),
          ),
          // InkWell untuk klik efek
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Image.network(
            "https://openweathermap.org/img/wn/$weatherIconCode@2x.png",
            width: 50,
            height: 50,
          ),
          const SizedBox(width: 10),
          Expanded(
            // Use expanded so the text doesn't push the button off screen
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$temperature°C di Yogyakarta",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  weatherDescription.toUpperCase(),
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ],
            ),
          ),
          // THE REFRESH BUTTON
          isWeatherLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    size: 20,
                    color: Colors.blueAccent,
                  ),
                  onPressed: _getWeather, // Call the function again
                ),
        ],
      ),
    );
  }
}
