import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'screens/live_camera.dart';
import 'screens/notifikasi.dart';
import 'screens/riwayat.dart';
import 'screens/telegram_service.dart'; // Pastikan path ini benar

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitoring Kandang',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3:
            false, // Gunakan false agar style tetap konsisten dengan kodingan sebelumnya
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  // Instance Global untuk Alarm
  final TelegramService _telegramService = TelegramService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _bgTimer;
  static String? _lastAlertTime; // Menyimpan waktu terakhir alarm bunyi

  final List<Widget> pages = [
    LiveCamera(),
    const Riwayat(),
    const Notifikasi(),
  ];

  @override
  void initState() {
    super.initState();
    // JALANKAN MONITORING GLOBAL (Setiap 5 detik)
    _startGlobalMonitoring();
  }

  void _startGlobalMonitoring() {
    _bgTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final logs = await _telegramService.getCsvLogs();
        if (logs.isNotEmpty) {
          var latest = logs.first;
          String status = latest["status"].toString().toUpperCase();
          String waktu = latest["waktu"].toString();

          bool isDanger = status.contains("ASING") || status.contains("BAHAYA");

          // CEK APAKAH ADA BAHAYA BARU?
          if (isDanger && waktu != _lastAlertTime) {
            _lastAlertTime = waktu; // Kunci waktu agar tidak bunyi berulang

            // 1. MAIN KAN SUARA ALARM (Bisa bunyi di tab mana saja)
            await _audioPlayer.stop();
            await _audioPlayer.play(AssetSource('alarm.mp3'));

            // 2. TAMPILKAN POP-UP NOTIFIKASI DI DALAM APLIKASI
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "🚨 TERDETEKSI $status: ${latest['nama']}!",
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: "LIHAT",
                    textColor: Colors.white,
                    onPressed: () {
                      setState(
                        () => selectedIndex = 2,
                      ); // Pindah ke tab Notifikasi
                    },
                  ),
                ),
              );
            }
          }
        }
      } catch (e) {
        debugPrint("Monitoring Error: $e");
      }
    });
  }

  @override
  void dispose() {
    _bgTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Safe Cage"),
        backgroundColor: Colors.green[700],
      ),
      body: IndexedStack(
        // Menggunakan IndexedStack agar state halaman tidak hilang saat pindah tab
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        selectedItemColor: Colors.green[700],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.videocam), label: 'Live'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifikasi',
          ),
        ],
      ),
    );
  }
}
