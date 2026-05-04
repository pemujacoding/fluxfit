import 'package:flutter/material.dart';
import 'package:fluxfit/controllers/checkin_controller.dart';
import 'package:fluxfit/controllers/jogging_riwayat_controller.dart';
import 'package:fluxfit/controllers/kalistenik_riwayat_controller.dart';
import 'package:fluxfit/session/session_helper.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final CheckinController checkinController = CheckinController();
  final kalistenikController = KalisteniRiwayatController();
  final JoggingRiwayatController joggingController = JoggingRiwayatController();

  List<Map<String, dynamic>> checkins = [];
  List<Map<String, dynamic>> kalistenik = [];
  List<Map<String, dynamic>> jogging = [];

  List<String> datesWithCheckin = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    _loadCheckinDates(); // 🔥 ini penting
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = await SessionHelper.getUserId();
    if (userId == null) return;

    final date = _selectedDay!.toIso8601String().substring(0, 10);

    final c = await checkinController.getCheckinByDate(userId, date);
    final k = await kalistenikController.getKalistenikByDate(userId, date);
    final j = await joggingController.getJoggingByDate(userId, date);

    setState(() {
      checkins = c;
      kalistenik = k;
      jogging = j;
    });
  }

  Future<void> _loadCheckinDates() async {
    final userId = await SessionHelper.getUserId();
    if (userId == null) return;

    final dates = await checkinController.getAllCheckinDates(userId);

    setState(() {
      datesWithCheckin = dates;
    });
  }

  String _formatTime(String datetime) {
    final dt = DateTime.parse(datetime);
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Riwayat Latihan"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Widget Kalender Bawaan Flutter yang bisa pilih Bulan & Tahun
          Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.blueAccent, // Warna tanggal terpilih
                onPrimary: Colors.white, // Warna teks di atas primary
                onSurface: Colors.black87, // Warna teks tanggal biasa
              ),
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020),
              lastDay: DateTime.utc(2030),
              focusedDay: _focusedDay,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });

                _loadData(); // 🔥 load data dari DB
              },

              // 🔥 MARKER CHECKIN
              eventLoader: (day) {
                final date = day.toIso8601String().substring(0, 10);

                if (datesWithCheckin.contains(date)) {
                  return [1]; // dummy event
                }
                return [];
              },

              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          const Divider(),

          // Panel Info Detail di bawah kalender
          Expanded(
            child: ListView(
              children: [
                ...checkins.map(
                  (c) => _buildActivityItem(
                    icon: Icons.check_circle,
                    color: Colors.green,
                    title: "Check-in",
                    time: _formatTime(c['datetime']),
                  ),
                ),

                ...kalistenik.map(
                  (k) => _buildActivityItem(
                    icon: Icons.fitness_center,
                    color: Colors.blueAccent,
                    title:
                        "Kalistenik ${k['level_nama']} ${(k['progress'] * 100).round()}%",
                    time: _formatTime(k['datetime']),
                    onDelete: () async {
                      final confirm = await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Hapus Riwayat?"),
                          content: const Text(
                            "Data ini tidak bisa dikembalikan.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text(
                                "Batal",
                                style: TextStyle(color: Colors.blueAccent),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Hapus"),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await kalistenikController.delete(k['riwayat_id']);
                        _loadData();
                      }
                    },
                  ),
                ),

                ...jogging.map(
                  (j) => _buildActivityItem(
                    icon: Icons.directions_run,
                    color: Colors.blueAccent,
                    title:
                        "Jogging ${(j['jarak']).toStringAsFixed(2)} km (${j['langkah']} langkah)",
                    time:
                        "${_formatTime(j['datetime_start'])} - ${_formatTime(j['datetime_end'])}",
                    onDelete: () async {
                      final confirm = await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Hapus Riwayat?"),
                          content: const Text(
                            "Data ini tidak bisa dikembalikan.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text(
                                "Batal",
                                style: TextStyle(color: Colors.blueAccent),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Hapus"),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await joggingController.deleteJogging(j['jogging_id']);
                        _loadData();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color color,
    required String title,
    required String time,
    VoidCallback? onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 15),

          // 🔥 TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),

          // 🔥 BUTTON DELETE
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.redAccent),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
