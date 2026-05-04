import 'package:flutter/material.dart';
import 'package:fluxfit/controllers/kalistenik_list_controller.dart';
import 'package:fluxfit/controllers/kalistenik_riwayat_controller.dart';
import 'package:fluxfit/models/kalistenik_riwayat.dart';
import 'package:fluxfit/session/session_helper.dart';

class LevelPage extends StatefulWidget {
  const LevelPage({super.key, required this.level});
  final String level;

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  final KalistenikListController listController = KalistenikListController();
  final KalisteniRiwayatController riwayatController =
      KalisteniRiwayatController();

  int currentStep = 0;

  late Future<List<Map<String, dynamic>>> futureSteps;

  int getLevelId() {
    switch (widget.level) {
      case "Pemula":
        return 1;
      case "Menengah":
        return 2;
      case "Advanced":
        return 3;
      default:
        return 1;
    }
  }

  @override
  void initState() {
    super.initState();

    // 🔥 3. INIT DATA SEKALI
    futureSteps = listController.getKalistenikByLevel(getLevelId());
  }

  void nextStep(int totalSteps) {
    if (currentStep < totalSteps - 1) {
      setState(() => currentStep++);
    } else {
      _showFinishedDialog();
    }
  }

  void prevStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
    }
  }

  Future<void> _saveRiwayat(double progress) async {
    final userId = await SessionHelper.getUserId();

    if (userId == null) return;
    final now = DateTime.now().toIso8601String();

    int levelId;
    switch (widget.level) {
      case "Pemula":
        levelId = 1;
        break;
      case "Menengah":
        levelId = 2;
        break;
      case "Advanced":
        levelId = 3;
        break;
      default:
        levelId = 1;
    }

    final riwayat = KalistenikRiwayat(
      userId: userId,
      levelId: levelId,
      datetime: now,
      progress: progress.toDouble(), // kalau di model REAL
    );

    await riwayatController.insertRiwayat(riwayat);
  }

  // Fungsi untuk memunculkan dialog saat user ingin keluar sebelum selesai
  Future<bool> _showExitConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Akhiri Sesi?"),
        content: const Text(
          "Progres latihanmu di sesi ini akan hilang. Yakin ingin keluar?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Tidak jadi keluar
            child: const Text(
              "Lanjut Latihan",
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              // 🔥 hitung progress (0.0 - 1.0)
              final steps = await futureSteps;
              final progress = (currentStep + 1) / steps.length;
              await _saveRiwayat(progress);

              Navigator.pop(context, true);
            }, // Ya, akhiri
            child: const Text("Ya, Akhiri"),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showFinishedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Latihan Selesai! 🎉"),
        content: const Text(
          "Luar biasa! Kamu telah menyelesaikan semua sesi latihan hari ini.",
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              _saveRiwayat(1);
              Navigator.pop(context); // Tutup dialog
              Navigator.pop(context); // Kembali ke list level
            },
            child: const Text("Mantap"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Kita kunci agar tidak langsung keluar
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // Jika sudah pop, abaikan

        // Panggil dialog konfirmasi
        final shouldPop = await _showExitConfirmation(context);
        if (shouldPop && context.mounted) {
          Navigator.pop(context); // Jika user pilih "Ya", baru kita keluarkan
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Kalistenik ${widget.level}",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.blueAccent,
          elevation: 0,
          centerTitle: true,
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: futureSteps,
          builder: (context, snapshot) {
            // 🔹 Loading
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final steps = snapshot.data!;

            // 🔹 Safety (kalau kosong)
            if (steps.isEmpty) {
              return const Center(child: Text("Belum ada data"));
            }

            final step = steps[currentStep];
            double progress = (currentStep + 1) / steps.length;

            return Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  color: Colors.blueAccent,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text("GERAKAN ${currentStep + 1} DARI ${steps.length}"),

                        const SizedBox(height: 10),

                        // 🔥 5. DATA DARI DB
                        Text(
                          step["nama"],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          "${step["set_count"]}x",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.orange,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Expanded(
                          child: Image.asset(
                            step["gambar"],
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(step["deskripsi"], textAlign: TextAlign.center),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            currentStep == 0
                                ? const SizedBox(width: 60)
                                : _buildNavButton(
                                    icon: Icons.chevron_left,
                                    onTap: prevStep,
                                    isPrimary: false,
                                  ),

                            _buildNavButton(
                              icon: currentStep == steps.length - 1
                                  ? Icons.check
                                  : Icons.chevron_right,
                              onTap: () => nextStep(steps.length),
                              isPrimary: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Widget custom untuk tombol navigasi yang lebih modern
  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
    String? label,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 24),
      label: Text(label ?? ""),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.blueAccent : Colors.white,
        foregroundColor: isPrimary ? Colors.white : Colors.blueAccent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: isPrimary
              ? BorderSide.none
              : const BorderSide(color: Colors.blueAccent),
        ),
        elevation: isPrimary ? 4 : 0,
      ),
    );
  }
}
