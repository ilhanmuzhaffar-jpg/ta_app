import 'dart:async';
import 'package:flutter/material.dart';
import 'telegram_service.dart';

class Notifikasi extends StatefulWidget {
  const Notifikasi({super.key});

  @override
  State<Notifikasi> createState() => _NotifikasiState();
}

class _NotifikasiState extends State<Notifikasi> {
  final TelegramService service = TelegramService();

  List<Map<String, dynamic>> logs = [];
  bool isLoading = false;
  Timer? timer;

  // Gunakan static agar variabel ini bertahan meskipun pindah tab
  static String? lastLoggedTime;

  @override
  void initState() {
    super.initState();
    _refreshData();
    // Refresh otomatis setiap 10 detik
    timer = Timer.periodic(const Duration(seconds: 10), (t) => _refreshData());
  }

  Future<void> _refreshData() async {
    // Mencegah penumpukan request jika request sebelumnya belum selesai
    if (isLoading) return;
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      final csvData = await service.getCsvLogs();
      final telegramData = await service.getUpdates();

      if (csvData.isNotEmpty) {
        // --- LOGIKA EFEK BUNYI ---
        var latestData = csvData.first;
        String currentStatus = latestData["status"].toString().toUpperCase();
        String currentWaktu = latestData["waktu"].toString();

        bool isDanger =
            currentStatus.contains("ASING") || currentStatus.contains("BAHAYA");

        // Cek apakah ini data baru (berdasarkan waktu)
        if (isDanger && currentWaktu != lastLoggedTime) {
          // Update waktu terakhir SEBELUM play agar tidak looping
          lastLoggedTime = currentWaktu;

          print("🚨 ALARM BUNYI: Terdeteksi $currentStatus pada $currentWaktu");
        }

        if (mounted) {
          setState(() {
            logs = csvData.map((log) {
              var match = telegramData.firstWhere(
                (t) => t['waktu'] == log['waktu'],
                orElse: () => {},
              );
              if (match.isNotEmpty) log['image'] = match['image'];
              return log;
            }).toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Error Refresh Notifikasi: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifikasi Aktivitas"),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.green[700],
        child: logs.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final item = logs[index];
                  final bool isDanger =
                      item["status"].toString().toUpperCase().contains(
                        "ASING",
                      ) ||
                      item["status"].toString().toUpperCase().contains(
                        "BAHAYA",
                      );

                  return _buildNotificationCard(item, isDanger);
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "Tidak ada aktivitas terdeteksi",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item, bool isDanger) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: isDanger
              ? Colors.red.withOpacity(0.5)
              : Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: _buildLeading(item, isDanger),
        title: Text(
          item["nama"] ?? "Objek Tidak Dikenal",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              item["status"] ?? "-",
              style: TextStyle(
                color: isDanger ? Colors.red : Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  item["waktu"] ?? "-",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: isDanger
            ? const Icon(Icons.warning_amber_rounded, color: Colors.red)
            : const Icon(Icons.check_circle_outline, color: Colors.green),
      ),
    );
  }

  Widget _buildLeading(Map<String, dynamic> item, bool isDanger) {
    if (item["image"] != null && item["image"].toString().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          item["image"],
          width: 55,
          height: 55,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => _buildFallbackIcon(isDanger),
        ),
      );
    }
    return _buildFallbackIcon(isDanger);
  }

  Widget _buildFallbackIcon(bool isDanger) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        color: isDanger ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        isDanger ? Icons.gpp_maybe : Icons.person_outline,
        color: isDanger ? Colors.red : Colors.green,
      ),
    );
  }
}
