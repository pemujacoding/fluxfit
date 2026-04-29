import 'package:flutter/material.dart';
import 'package:fluxfit/pages/level_page.dart';

class CalisPage extends StatelessWidget {
  const CalisPage({super.key});

  // Fungsi helper untuk menampilkan dialog konfirmasi
  void _showConfirmation(BuildContext context, String level) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text("Siap untuk Level $level?"),
          content: const Text(
            "Pastikan kamu sudah melakukan pemanasan sebelum memulai sesi ini.",
            style: TextStyle(color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Nanti deh",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LevelPage(level: level),
                  ),
                );
              },
              child: const Text("Mulai!"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Tingkat Kesulitan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          const Text(
            "Pilih level yang sesuai dengan kemampuan fisikmu saat ini.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 25),

          _buildDifficultyButton(
            title: "Pemula",
            subtitle: "Fokus pada teknik dasar",
            colors: [Colors.tealAccent.shade700, Colors.greenAccent.shade400],
            icon: Icons.fitness_center_outlined, // Icon lebih relevan
            onTap: () => _showConfirmation(context, "Pemula"),
          ),

          _buildDifficultyButton(
            title: "Menengah",
            subtitle: "Meningkatkan daya tahan",
            colors: [Colors.orangeAccent, Colors.deepOrange],
            icon: Icons.bolt,
            onTap: () => _showConfirmation(context, "Menengah"),
          ),

          _buildDifficultyButton(
            title: "Advanced",
            subtitle: "Latihan intensitas tinggi",
            colors: [Colors.purpleAccent, Colors.indigo],
            icon: Icons.whatshot,
            onTap: () => _showConfirmation(context, "Advanced"),
          ),

          const SizedBox(height: 20),

          // Tips Card yang lebih menonjol
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.blueAccent),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    "Tips: Jangan memaksakan diri. Konsistensi lebih penting daripada intensitas sesaat.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blueAccent.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton({
    required String title,
    required String subtitle,
    required List<Color> colors,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Efek lingkaran dekoratif (biar gak sepi-sepi amat)
          Positioned(
            top: -20,
            right: -20,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),

          // Icon Transparan Background
          Positioned(
            left: -15,
            bottom: -20,
            child: Icon(icon, size: 140, color: Colors.white.withOpacity(0.15)),
          ),

          // Konten Utama
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ],
            ),
          ),

          // InkWell area
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: onTap,
                splashColor: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
