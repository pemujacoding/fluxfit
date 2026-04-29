import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class WalkjogPage extends StatefulWidget {
  const WalkjogPage({super.key});

  @override
  State<WalkjogPage> createState() => _WalkjogPageState();
}

class _WalkjogPageState extends State<WalkjogPage> {
  GoogleMapController? mapController;
  List<LatLng> points = [];
  StreamSubscription<Position>? positionStream;
  bool isTracking = false;
  double totalDistance = 0;
  LatLng? currentPosition;

  // FUNGSI BARU: Cek Izin Lokasi sebelum mulai
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi mati. Silakan aktifkan GPS anda.'),
        ),
      );
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  void startTracking() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5, // Update setiap 5 meter
          ),
        ).listen((Position position) {
          LatLng newPoint = LatLng(position.latitude, position.longitude);

          setState(() {
            currentPosition = newPoint;
            points.add(newPoint);

            if (points.length > 1) {
              totalDistance += Geolocator.distanceBetween(
                points[points.length - 2].latitude,
                points[points.length - 2].longitude,
                newPoint.latitude,
                newPoint.longitude,
              );
              mapController?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: newPoint,
                    zoom: 18, // zoom dekat (17–19 enak buat tracking)
                  ),
                ),
              );
            } else {
              mapController?.animateCamera(CameraUpdate.newLatLng(newPoint));
            }
          });

          // Peta otomatis mengikuti user
          mapController?.animateCamera(CameraUpdate.newLatLng(newPoint));
        });
  }

  void stopTracking() {
    positionStream?.cancel();
    positionStream = null;
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
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
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(-7.566, 110.824), // Contoh koordinat Solo
              zoom: 17,
            ),
            onMapCreated: (controller) => mapController = controller,
            polylines: {
              Polyline(
                polylineId: const PolylineId("track"),
                color: Colors.blueAccent,
                width: 6,
                points: points,
                jointType: JointType.round,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),

          // Card Info Jarak yang lebih cantik
          Positioned(
            left: 20,
            right: 20,
            bottom: 110,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "JARAK TEMPUH",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        Text(
                          "${(totalDistance / 1000).toStringAsFixed(2)} KM",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.directions_run,
                      color: Colors.blueAccent.withOpacity(0.5),
                      size: 36,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tombol Mulai/Selesai
          Positioned(
            bottom: 40,
            left: 50,
            right: 50,
            child: SizedBox(
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isTracking
                      ? Colors.redAccent
                      : Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                ),
                onPressed: () {
                  setState(() {
                    isTracking = !isTracking;
                    if (isTracking) {
                      points.clear(); // Reset jalur lama
                      totalDistance = 0;
                      startTracking();
                    } else {
                      stopTracking();
                    }
                  });
                },
                child: Text(
                  isTracking ? "SELESAI" : "MULAI",
                  style: const TextStyle(
                    fontSize: 18,
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
}
