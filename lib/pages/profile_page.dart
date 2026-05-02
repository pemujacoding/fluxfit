import 'package:flutter/material.dart';
import 'package:fluxfit/controllers/user_controller.dart';
import 'package:fluxfit/database/db_helper.dart';
import 'package:fluxfit/session/session_helper.dart';
import 'package:sqflite/sqflite.dart';

class ProfilePage extends StatefulWidget {
  final String username;

  const ProfilePage({super.key, required this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DBHelper _dbHelper = DBHelper();

  int _totalCheckin = 0;
  double _totalJarak = 0;
  int _totalKalistenik = 0;
  int _highestScore = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      // 1. Ambil UserID dari session (pastikan ini sama dengan cara di CalendarPage)
      final userId = await SessionHelper.getUserId();

      // Debugging (bisa dihapus nanti)
      debugPrint("Loading Profile for UserID: $userId");

      if (userId == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final db = await _dbHelper.database;

      // 2. Gunakan rawQuery dengan Sqflite.firstIntValue untuk hasil yang lebih stabil
      // Menghitung hari unik saat user melakukan checkin
      final checkinData = await db.rawQuery(
        'SELECT COUNT(*) FROM checkin WHERE user_id = ?',
        [userId],
      );

      // Menghitung total jarak dari riwayat jogging
      final jarakData = await db.rawQuery(
        'SELECT SUM(jarak) FROM jogging_riwayat WHERE user_id = ?',
        [userId],
      );

      // Menghitung total sesi kalistenik yang sudah selesai
      final kalistenikData = await db.rawQuery(
        'SELECT COUNT(*) FROM kalistenik_riwayat WHERE user_id = ?',
        [userId],
      );

      // Mengambil skor tertinggi dari tabel game
      final gameData = await db.query(
        'game',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      // 3. Update State dengan casting yang aman
      if (mounted) {
        setState(() {
          _totalCheckin = Sqflite.firstIntValue(checkinData) ?? 0;

          // Menggunakan num agar aman saat konversi ke double
          final totalJarakRaw = jarakData.first.values.first as num?;
          _totalJarak = totalJarakRaw?.toDouble() ?? 0.0;

          _totalKalistenik = Sqflite.firstIntValue(kalistenikData) ?? 0;

          _highestScore = gameData.isNotEmpty
              ? (gameData.first['highest_skor'] as int? ?? 0)
              : 0;

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading stats: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController passController = TextEditingController();
    final TextEditingController confirmPassController =
        TextEditingController(); // Controller baru
    bool obscurePass = true;
    bool obscureConfirm = true;
    final UserController userController = UserController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Ganti Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Agar dialog tidak kepanjangan
            children: [
              // Form Password Baru
              TextField(
                controller: passController,
                obscureText: obscurePass,
                decoration: InputDecoration(
                  labelText: "Password Baru",
                  hintText: "Masukkan password baru",
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePass ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setDialogState(() => obscurePass = !obscurePass),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Form Konfirmasi Password
              TextField(
                controller: confirmPassController,
                obscureText: obscureConfirm,
                decoration: InputDecoration(
                  labelText: "Konfirmasi Password",
                  hintText: "Ulangi password baru",
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setDialogState(() => obscureConfirm = !obscureConfirm),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                String newPass = passController.text;
                String confirmPass = confirmPassController.text;

                // Validasi 1: Tidak boleh kosong
                if (newPass.isEmpty || confirmPass.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Field tidak boleh kosong!")),
                  );
                  return;
                }

                // Validasi 2: Harus sama
                if (newPass != confirmPass) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password tidak cocok!")),
                  );
                  return;
                }

                // Jika lolos validasi, baru update
                await userController.updatePasswordSafe(
                  widget.username,
                  newPass,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Password berhasil diperbarui!"),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Aplikasi'),
        content: const Text('Apakah kamu yakin ingin logout dari Fluxfit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                children: [
                  // Avatar & username
                  Center(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.blueAccent,
                          child: Icon(
                            Icons.person,
                            size: 70,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.username,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Statistik ringkas
                  const Text(
                    'Statistik',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _buildStatCard(
                        icon: Icons.check_circle_outline,
                        label: 'Hari Aktif',
                        value: '$_totalCheckin hari',
                        color: Colors.blueAccent,
                      ),
                      _buildStatCard(
                        icon: Icons.directions_run,
                        label: 'Total Jarak',
                        value: '${_totalJarak.toStringAsFixed(2)} km',
                        color: Colors.teal,
                      ),
                      _buildStatCard(
                        icon: Icons.fitness_center,
                        label: 'Sesi Kalistenik',
                        value: '$_totalKalistenik sesi',
                        color: Colors.purple,
                      ),
                      _buildStatCard(
                        icon: Icons.videogame_asset,
                        label: 'Rekor Game',
                        value: '${_highestScore}m',
                        color: Colors.orangeAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Ganti password
                  const Text(
                    'Pengaturan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.lock_reset_outlined,
                        color: Colors.orange,
                      ),
                      title: const Text('Ganti Password'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showChangePasswordDialog(context),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Logout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Log Out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _confirmLogout(context),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
