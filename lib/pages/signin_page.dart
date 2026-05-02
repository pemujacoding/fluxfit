import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluxfit/controllers/user_controller.dart';
import 'package:fluxfit/models/user.dart'; // Tambahkan package intl di pubspec.yaml jika belum ada

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  UserController userController = UserController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  bool _obscurePassword = true;

  String? _selectedGender;
  DateTime? _selectedDate;

  // Fungsi untuk memunculkan Tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 6570),
      ), // Default 18 tahun lalu
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blueAccent),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd MMMM yyyy').format(picked);
      });
    }
  }

  Future<void> _handleSignin() async {
    // 1. Trim username untuk menghindari spasi tak sengaja
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isNotEmpty &&
        password.isNotEmpty &&
        _selectedGender != null &&
        _selectedDate != null) {
      User user = User(
        username: username,
        password: password,
        gender: _selectedGender!,
        // Simpan dalam format ISO atau YYYY-MM-DD yang konsisten
        tanggalLahir: _selectedDate!.toIso8601String(),
      );

      // Tampilkan loading indicator jika perlu
      final result = await userController.insertUserSafe(user);

      // 2. WAJIB: Cek apakah widget masih aktif sebelum menggunakan context
      if (!mounted) return;

      if (result == "USERNAME_EXISTS") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Username sudah digunakan")),
        );
      } else if (result == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Akun berhasil dibuat")));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Terjadi kesalahan")));
      } // Kembali ke halaman Login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text("Mohon lengkapi semua data"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daftar Akun',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lengkapi data diri untuk memulai perjalanan FluxFit.',
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),

              // Username
              _buildLabel("Username"),
              _buildTextField(
                _usernameController,
                "Masukkan username",
                Icons.person_outline,
              ),

              const SizedBox(height: 16),

              // Password
              _buildLabel("Password"),
              _buildTextField(
                _passwordController,
                "Masukkan password",
                Icons.lock_outline,
                isPassword: true,
              ),

              const SizedBox(height: 16),

              // Gender (Dropdown)
              _buildLabel("Jenis Kelamin"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGender,
                    hint: const Text("Pilih Gender"),
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(value: 'male', child: Text('Laki-laki')),
                      DropdownMenuItem(
                        value: 'female',
                        child: Text('Perempuan'),
                      ),
                    ],
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tanggal Lahir (Date Picker)
              _buildLabel("Tanggal Lahir"),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: _buildTextField(
                    _dobController,
                    "Pilih tanggal lahir",
                    Icons.calendar_today_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Tombol Daftar
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _handleSignin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Daftar Sekarang",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk Label
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      // Jika isPassword true, gunakan state _obscurePassword. Jika tidak, false (terlihat).
      obscureText: isPassword ? _obscurePassword : false,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        // Tambahkan suffixIcon hanya untuk field password
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
