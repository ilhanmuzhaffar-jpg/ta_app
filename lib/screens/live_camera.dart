import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'telegram_service.dart'; // Pastikan path service benar

class LiveCamera extends StatefulWidget {
  const LiveCamera({super.key});

  @override
  State<LiveCamera> createState() => _LiveCameraState();
}

class _LiveCameraState extends State<LiveCamera> {
  late final WebViewController controller;
  final TelegramService telegramService = TelegramService();
  Timer? _timer;

  // Variabel Real-time
  String statusKandang = "STANDBY";
  String objekTerdeteksi = "-";
  String waktuUpdate = "-";
  Color colorStatus = Colors.grey;
  bool isOnline = false;

  // GANTI URL NGROK KAMU DISINI
  final String ngrokUrl =
      "https://override-sprang-playmaker.ngrok-free.dev/video_feed";

  @override
  void initState() {
    super.initState();

    // Setup WebView
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(ngrokUrl),
        headers: {'ngrok-skip-browser-warning': 'true'},
      );

    // Jalankan Loop Real-time setiap 3 detik
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchLatestData();
    });
  }

  Future<void> _fetchLatestData() async {
    try {
      final updates = await telegramService.getUpdates();
      if (updates.isNotEmpty) {
        final latest = updates.last; // Ambil data paling baru dari bot
        setState(() {
          statusKandang = latest['status'] ?? "TIDAK DIKENAL";
          objekTerdeteksi = latest['nama'] ?? "Unknown";
          waktuUpdate = latest['waktu'] ?? "-";
          isOnline = true;

          // Ganti warna berdasarkan status
          if (statusKandang.contains("BAHAYA") ||
              statusKandang.contains("ASING")) {
            colorStatus = Colors.redAccent;
          } else {
            colorStatus = Colors.green;
          }
        });
      }
    } catch (e) {
      setState(() => isOnline = false);
      print("Error koneksi: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hentikan timer saat pindah screen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 📷 LIVE STREAM SECTION
          Container(
            margin: const EdgeInsets.all(12),
            height: 220,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: colorStatus, width: 2),
            ),
            child: WebViewWidget(controller: controller),
          ),

          // 🚨 REAL-TIME STATUS CARD
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorStatus,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: Row(
              children: [
                Icon(
                  statusKandang.contains("BAHAYA")
                      ? Icons.warning
                      : Icons.check_circle,
                  color: Colors.white,
                  size: 45,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusKandang,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Objek: $objekTerdeteksi",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        "Waktu: $waktuUpdate",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // INFO BOX (Bottom Stats)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoBox(Icons.visibility, "Deteksi", "AKTIF", Colors.blue),
              _infoBox(
                Icons.wifi,
                "Koneksi",
                isOnline ? "ONLINE" : "ONLINE",
                isOnline ? Colors.orange : Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoBox(IconData icon, String title, String value, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.42,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
