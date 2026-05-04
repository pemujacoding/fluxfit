import 'package:flutter/material.dart';
import 'package:fluxfit/controllers/budget_controller.dart';
import 'package:fluxfit/controllers/jadwal_controller.dart';
import 'package:fluxfit/models/budget.dart';
import 'package:fluxfit/models/jadwal.dart';
import 'package:fluxfit/pages/alat_page.dart';
import 'package:fluxfit/pages/detailbudget_page.dart';
import 'package:fluxfit/session/session_helper.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  final BudgetController budgetController = BudgetController();
  final JadwalController jadwalController = JadwalController();

  String? selectedZone;
  String? selectedCurrency;
  int? hourOffset;
  List<Jadwal> jadwalList = [];
  List<Budget> budgets = [];
  Map<int, int> budgetTotals = {};
  bool isLoadingRates = false;

  final Map<String, int> dayMapper = {
    'Senin': 1,
    'Selasa': 2,
    'Rabu': 3,
    'Kamis': 4,
    'Jumat': 5,
    'Sabtu': 6,
    'Minggu': 7,
  };

  @override
  void initState() {
    selectedZone = "WIB";
    selectedCurrency = "IDR";
    hourOffset = 0;
    super.initState();
    _loadBudget();
    _loadJadwal();
    fetchRates();
  }

  Future<void> _loadBudget() async {
    final userId = await SessionHelper.getUserId();
    if (userId == null) return;
    final data = await budgetController.getBudgetUser(userId);
    Map<int, int> totals = {};
    for (var b in data) {
      final total = await budgetController.getTotalBudget(b.budgetId!);
      totals[b.budgetId!] = total;
    }
    setState(() {
      budgets = data;
      budgetTotals = totals;
    });
  }

  Future<void> _loadJadwal() async {
    final userId = await SessionHelper.getUserId();
    if (userId == null) return;
    final data = await jadwalController.getAllbyUser(userId);
    setState(() => jadwalList = data);
  }

  String formatCurrency(int valueInIDR, String code) {
    // Ambil rate dari hasil API, jika belum ada/loading pakai 1.0 (fallback)
    double rate = exchangeRates[code] ?? 1.0;

    // Jika kode bukan IDR, lakukan perkalian
    double converted = (code == 'IDR')
        ? valueInIDR.toDouble()
        : valueInIDR * rate;

    // Format tampilan berdasarkan simbol mata uang
    switch (code) {
      case 'USD':
        return NumberFormat.currency(
          symbol: r'$ ',
          decimalDigits: 2,
        ).format(converted);
      case 'JPY':
        return NumberFormat.currency(
          symbol: '¥ ',
          decimalDigits: 0,
        ).format(converted);
      case 'EUR':
        return NumberFormat.currency(
          symbol: '€ ',
          decimalDigits: 2,
        ).format(converted);
      case 'SGD':
        return NumberFormat.currency(
          symbol: 'S\$ ',
          decimalDigits: 2,
        ).format(converted);
      case 'SAR':
        return NumberFormat.currency(
          symbol: 'SR ',
          decimalDigits: 2,
        ).format(converted);
      default:
        // Default ke Rupiah jika IDR atau kode tidak dikenal
        return NumberFormat.currency(
          locale: 'id',
          symbol: 'Rp ',
          decimalDigits: 0,
        ).format(valueInIDR);
    }
  }

  String formatTimeWithZone(String timeWIB, int offset) {
    final parts = timeWIB.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    int newHour = (hour + offset) % 24;

    return "${newHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  }

  Map<String, double> exchangeRates = {
    'IDR': 1.0,
    'USD': 0.000062,
    'JPY': 0.0094,
  };

  Future<void> fetchRates() async {
    setState(() => isLoadingRates = true);
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.frankfurter.app/latest?from=IDR&to=USD,JPY,EUR,SGD,SAR',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          exchangeRates = Map<String, double>.from(data['rates']);
          exchangeRates['IDR'] = 1.0;
          isLoadingRates = false;
        });
      }
    } catch (e) {
      setState(() => isLoadingRates = false);
      print("Koneksi gagal, menggunakan data lokal.");
    }
  }

  void _updateJadwal(String nama, int id) {
    final _editController = TextEditingController(text: nama);

    // Set the current name as the initial text (Optional but better UX)
    // _editController.text = currentBudgetName;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Edit Nama Budget Plan",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: TextField(controller: _editController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              // READ THE TEXT HERE - Right when the button is clicked!
              String newName = _editController.text;

              if (newName.isNotEmpty) {
                await jadwalController.updateJadwaltName(newName, id);

                // If this is a StatefulWidget, you might want to call _loadData() here
                // before closing the dialog.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    content: Text("Nama jadwal berhasil diupdate"),
                  ),
                );
                _loadJadwal();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text("Edit"),
          ),
        ],
      ),
    );
  }
  // --- WIDGET COMPONENTS ---

  Widget _buildSectionHeader(String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text("Tambah"),
          style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF8FAFF,
      ), // Warna background soft blue-grey
      appBar: AppBar(
        title: const Text(
          "Plan & Budget",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.blueAccent,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadBudget();
          await _loadJadwal();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader("Jadwal Olahraga", _showAddJadwalDialog),
            Center(
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(10),
                constraints: const BoxConstraints(minHeight: 35, minWidth: 70),
                isSelected: [
                  selectedZone == "WIB",
                  selectedZone == "WITA",
                  selectedZone == "WIT",
                ],
                onPressed: (index) {
                  setState(() {
                    if (index == 0) {
                      selectedZone = "WIB";
                      hourOffset = 0;
                    } else if (index == 1) {
                      selectedZone = "WITA";
                      hourOffset = 1;
                    } else {
                      selectedZone = "WIT";
                      hourOffset = 2;
                    }
                  });
                },
                children: const [Text("WIB"), Text("WITA"), Text("WIT")],
              ),
            ),
            const SizedBox(height: 10),
            jadwalList.isEmpty
                ? _buildEmptyState("Belum ada jadwal latihan")
                : Column(
                    children: jadwalList
                        .map((j) => _buildJadwalCard(j))
                        .toList(),
                  ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 10),

            _buildSectionHeader("Budget Alat Fitness", () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlatPage()),
              );
              if (result == true) _loadBudget();
            }),
            // Letakkan di bawah teks "Budget alat fitness"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Lihat dalam kurs:",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                DropdownButton<String>(
                  value: selectedCurrency,
                  underline: const SizedBox(),
                  items: exchangeRates.keys.map((String code) {
                    return DropdownMenuItem(
                      value: code,
                      child: Text(code, style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => selectedCurrency = val!),
                ),
              ],
            ),
            const SizedBox(height: 10),
            budgets.isEmpty
                ? _buildEmptyState("Belum ada rencana budget")
                : Column(
                    children: budgets.map((b) => _buildBudgetCard(b)).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildJadwalCard(Jadwal j) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.timer_outlined, color: Colors.blueAccent),
        ),
        title: Text(
          j.nama,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${j.hari}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${formatTimeWithZone(j.startTime!, hourOffset!)} - ${formatTimeWithZone(j.endTime!, hourOffset!)} $selectedZone",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        // FIX: Use MainAxisSize.min here!
        trailing: SizedBox(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Colors.blueAccent,
                  size: 20,
                ),
                onPressed: () => _updateJadwal(j.nama, j.jadwalId!),
              ),
              IconButton(
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.delete_sweep_outlined,
                  color: Colors.redAccent,
                  size: 20,
                ),
                onPressed: () async {
                  await jadwalController.delete(j.jadwalId!);
                  _loadJadwal();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetCard(Budget b) {
    final total = budgetTotals[b.budgetId] ?? 0;
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                DetailbudgetPage(budgetId: b.budgetId!, nama: b.nama),
          ),
        );
        if (result == true) _loadBudget();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50.withOpacity(0.3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    b.datetime != null
                        ? DateFormat(
                            'dd MMM yyyy, HH:mm',
                          ).format(DateTime.parse(b.datetime!))
                        : '',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Text(
              formatCurrency(
                total,
                selectedCurrency!,
              ), // Menggunakan fungsi baru
              style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Dialog tetap sama secara fungsional, namun disarankan menggunakan TimePicker bawaan Flutter
  // agar user experience lebih baik daripada Dropdown angka manual.
  Future<void> _showAddJadwalDialog() async {
    final namaController = TextEditingController();

    int startHour = 7;
    int startMinute = 0;
    int endHour = 8;
    int endMinute = 0;

    String hari = "Senin";

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text("Tambah Jadwal"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: namaController,
                      decoration: const InputDecoration(
                        labelText: "Nama Jadwal",
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: hari,
                      isExpanded: true,
                      items: dayMapper.keys.map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      onChanged: (val) => setStateDialog(() => hari = val!),
                    ),
                    const SizedBox(height: 10),
                    const Text("Start Time"),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<int>(
                            value: startHour,
                            items: List.generate(
                              24,
                              (i) => DropdownMenuItem(
                                value: i,
                                child: Text(i.toString().padLeft(2, '0')),
                              ),
                            ),
                            onChanged: (val) =>
                                setStateDialog(() => startHour = val!),
                          ),
                        ),
                        const Text(":"),
                        Expanded(
                          child: DropdownButton<int>(
                            value: startMinute,
                            items: List.generate(
                              60,
                              (i) => DropdownMenuItem(
                                value: i,
                                child: Text(i.toString().padLeft(2, '0')),
                              ),
                            ),
                            onChanged: (val) =>
                                setStateDialog(() => startMinute = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text("End Time"),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<int>(
                            value: endHour,
                            items: List.generate(
                              24,
                              (i) => DropdownMenuItem(
                                value: i,
                                child: Text(i.toString().padLeft(2, '0')),
                              ),
                            ),
                            onChanged: (val) =>
                                setStateDialog(() => endHour = val!),
                          ),
                        ),
                        const Text(":"),
                        Expanded(
                          child: DropdownButton<int>(
                            value: endMinute,
                            items: List.generate(
                              60,
                              (i) => DropdownMenuItem(
                                value: i,
                                child: Text(i.toString().padLeft(2, '0')),
                              ),
                            ),
                            onChanged: (val) =>
                                setStateDialog(() => endMinute = val!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.grey[600],
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final userId = await SessionHelper.getUserId();
                    if (userId == null) return;
                    final start =
                        "${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}";
                    final end =
                        "${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}";

                    // Use a unique ID for the notification
                    await jadwalController.insert(
                      Jadwal(
                        userId: userId,
                        nama: namaController.text,
                        startTime: start,
                        endTime: end,
                        hari: hari,
                      ),
                    );
                    Navigator.pop(context);
                    _loadJadwal();
                  },
                  child: const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
