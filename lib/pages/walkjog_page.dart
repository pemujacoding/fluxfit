import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluxfit/controllers/jogging_riwayat_controller.dart';
import 'package:fluxfit/models/jogging_riwayat.dart';
import 'package:fluxfit/session/session_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

class WalkjogPage extends StatefulWidget {
  const WalkjogPage({super.key});

  @override
  State<WalkjogPage> createState() => _WalkjogPageState();
}

class _WalkjogPageState extends State<WalkjogPage> {
  JoggingRiwayatController joggingController = JoggingRiwayatController();
  GoogleMapController? mapController;

  // Perubahan: Gunakan Set Polyline untuk menampung segmen warna berbeda
  Set<Polyline> _polylines = {};
  LatLng? _lastPoint;

  StreamSubscription<Position>? positionStream;
  StreamSubscription<AccelerometerEvent>? accelerometerStream;

  bool isTracking = false;
  double totalDistance = 0;
  int stepCount = 0;
  DateTime? startTime;
  DateTime? endTime;
  LatLng? initialPosition;
  bool isMapLoaded = false;

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

  Future<void> _setInitialLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      initialPosition = LatLng(position.latitude, position.longitude);
      isMapLoaded = true;
    });
  }

  double _lastMagnitude = 0;
  void _startStepCounting() {
    accelerometerStream = accelerometerEvents.listen((
      AccelerometerEvent event,
    ) {
      double magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );
      if ((magnitude - _lastMagnitude).abs() > 2.0) {
        setState(() => stepCount++);
      }
      _lastMagnitude = magnitude;
    });
  }

  void startTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    setState(() {
      startTime = DateTime.now();
      stepCount = 0;
      totalDistance = 0;
      _polylines.clear();
      _lastPoint = null;
    });

    _startStepCounting();

    positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 3, // Update lebih sering agar warna lebih akurat
          ),
        ).listen((Position position) {
          LatLng newPoint = LatLng(position.latitude, position.longitude);

          // Deteksi Kecepatan (m/s). 2.22 m/s kira-kira 8 km/jam
          bool isRunning = position.speed > 1.5;
          Color segmentColor = isRunning ? Colors.orange : Colors.blueAccent;

          setState(() {
            if (_lastPoint != null) {
              // Tambahkan jarak
              totalDistance += Geolocator.distanceBetween(
                _lastPoint!.latitude,
                _lastPoint!.longitude,
                newPoint.latitude,
                newPoint.longitude,
              );

              // Buat segmen garis baru setiap ada pergerakan
              _polylines.add(
                Polyline(
                  polylineId: PolylineId(position.timestamp.toString()),
                  points: [_lastPoint!, newPoint],
                  color: segmentColor,
                  width: 6,
                  jointType: JointType.round,
                  startCap: Cap.roundCap,
                  endCap: Cap.roundCap,
                ),
              );
            }
            _lastPoint = newPoint;
          });

          mapController?.animateCamera(CameraUpdate.newLatLng(newPoint));
        });
  }

  Future<void> stopTracking() async {
    final userId = await SessionHelper.getUserId();

    // 1. Simpan waktu selesai
    DateTime sekarang = DateTime.now();

    setState(() {
      endTime = sekarang;
      isTracking = false;
    });

    // 2. Hentikan semua stream
    positionStream?.cancel();
    accelerometerStream?.cancel();

    // 3. Simpan ke database dengan data yang benar
    if (userId != null && startTime != null) {
      await joggingController.insertJogging(
        JoggingRiwayat(
          userId: userId,
          // Gunakan ISO String agar konsisten di database
          datetimeStart: startTime!.toIso8601String(),
          datetimeEnd: sekarang.toIso8601String(),
          jarak: totalDistance / 1000,
          langkah: stepCount,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "FluxFit Tracker",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
      ),
      body: !isMapLoaded
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: initialPosition!,
                    zoom: 18,
                  ),
                  onMapCreated: (controller) => mapController = controller,
                  polylines: _polylines, // Menggunakan Set Polyline kita
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                ),

                // Panel Info
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 110,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoColumn(
                            "JARAK",
                            "${(totalDistance / 1000).toStringAsFixed(2)} KM",
                          ),
                          _buildInfoColumn("LANGKAH", "$stepCount"),
                          // Tambahan indikator status
                          Icon(
                            Icons.directions_run,
                            color:
                                (_lastPoint != null &&
                                    _polylines.isNotEmpty &&
                                    _polylines.last.color == Colors.orange)
                                ? Colors.orange
                                : Colors.blueAccent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Button Start/Stop
                Positioned(
                  bottom: 40,
                  left: 50,
                  right: 50,
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isTracking = !isTracking;
                          isTracking ? startTracking() : stopTracking();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isTracking
                            ? Colors.redAccent
                            : Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        isTracking ? "SELESAI" : "MULAI",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
      ],
    );
  }
}
