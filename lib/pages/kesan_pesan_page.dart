import 'package:flutter/material.dart';

class KesanPesanPage extends StatelessWidget {
  const KesanPesanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kesan dan Pesan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[50], // Background halus
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // _buildSectionHeader("Kesan Selama Perkuliahan"),
            _buildKesanCard(
              "Materi & Praktikum",
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
              Icons.book_rounded,
            ),
            _buildKesanCard(
              "Pengalaman Coding",
              "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident.",
              Icons.code_rounded,
            ),

            const SizedBox(height: 20),

            // _buildSectionHeader("Pesan untuk Kedepannya"),
            // _buildPesanCard(
            //   "Untuk Dosen & Asisten",
            //   "Sunt in culpa qui officia deserunt mollit anim id est laborum. Section 1.10.32 of 'de Finibus Bonorum et Malorum', written by Cicero in 45 BC.",
            // ),
            // _buildPesanCard(
            //   "Harapan Matkul",
            //   "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore.",
            // ),

            // const SizedBox(height: 30),
            // const Center(
            //   child: Text(
            //     "Fluxfit Project - 2026",
            //     style: TextStyle(color: Colors.grey, fontSize: 12),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // Widget untuk Judul Section
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  // Widget Card untuk Kesan
  Widget _buildKesanCard(String title, String content, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blueAccent, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Divider(),
            Text(
              content,
              style: const TextStyle(height: 1.5, color: Colors.black87),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  // Widget Card untuk Pesan (Style beda dikit)
  Widget _buildPesanCard(String target, String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            target,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
