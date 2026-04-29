import 'package:flutter/material.dart';
import 'package:fluxfit/controllers/checkin_controller.dart';
import 'package:fluxfit/controllers/jogging_riwayat_controller.dart';
import 'package:fluxfit/controllers/kalistenik_riwayat_controller.dart';
import 'package:fluxfit/session/session_helper.dart';
import 'package:fluxfit/services/ai_service.dart';

class AiRecommendationPage extends StatefulWidget {
  const AiRecommendationPage({super.key});

  @override
  State<AiRecommendationPage> createState() => _AiRecommendationPageState();
}

class _AiRecommendationPageState extends State<AiRecommendationPage> {
  final CheckinController _checkinController = CheckinController();
  final JoggingRiwayatController _joggingRiwayatController =
      JoggingRiwayatController();
  final KalisteniRiwayatController _kalisthenicRiwayatController =
      KalisteniRiwayatController();
  final AiRecommendationService _aiService = AiRecommendationService();

  String? _recommendation;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  @override
  void initState() {
    super.initState();
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 60, color: Colors.blueAccent),
          const SizedBox(height: 20),

          const Text(
            "Siap dapetin rekomendasi latihan?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text(
            "AI akan menganalisis check-in, jogging, dan kalistenik kamu",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),

          const SizedBox(height: 30),

          ElevatedButton.icon(
            onPressed: _loadRecommendation, // 🔥 klik baru jalan
            icon: const Icon(Icons.auto_awesome),
            label: const Text("Generate Rekomendasi"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadRecommendation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = await SessionHelper.getUserId();
      if (userId == null) throw Exception('User tidak ditemukan');

      final checkIns = await _checkinController.getWeeklyResult(userId);
      final jogging = await _joggingRiwayatController.getLast3Sessions(userId);
      final calisthenics = await _kalisthenicRiwayatController.getLast3Sessions(
        userId,
      );

      final result = await _aiService.getRecommendation(
        checkInHistory: checkIns,
        joggingHistory: jogging,
        kalisthenicHistory: calisthenics,
      );

      setState(() => _recommendation = result);
    } catch (e) {
      setState(() => _errorMessage = 'Gagal memuat rekomendasi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'AI Recommendation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? _buildLoadingState()
            : _errorMessage != null
            ? _buildErrorState()
            : _recommendation == null
            ? _buildInitialState() // 🔥 TAMBAH INI
            : _buildRecommendationContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blueAccent),
          SizedBox(height: 16),
          Text(
            'AI sedang menganalisis data latihanmu...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadRecommendation,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationContent() {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.indigo, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Coach',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rekomendasi personal dari data latihanmu',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Container(
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
          child: Text(
            _recommendation ?? '',
            style: const TextStyle(
              fontSize: 15,
              height: 1.7,
              color: Colors.black87,
            ),
          ),
        ),

        const SizedBox(height: 20),

        OutlinedButton.icon(
          onPressed: _loadRecommendation,
          icon: const Icon(Icons.refresh, color: Colors.blueAccent),
          label: const Text(
            'Perbarui Rekomendasi',
            style: TextStyle(color: Colors.blueAccent),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: Colors.blueAccent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 8),

        const Center(
          child: Text(
            'Rekomendasi dibuat berdasarkan 3 sesi kalistenik terakhir',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
