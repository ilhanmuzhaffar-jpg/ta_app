<<<<<<< HEAD
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class Riwayat extends StatefulWidget {
  const Riwayat({super.key});

  @override
  State<Riwayat> createState() => _RiwayatState();
}

class _RiwayatState extends State<Riwayat> {
  // Pastikan URL Ngrok ini selalu update atau gunakan domain statis
  final String ngrokUrl = "https://override-sprang-playmaker.ngrok-free.dev";

  List<dynamic> archiveFiles = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchArchiveList();
  }

  // PERBAIKAN: Endpoint disesuaikan dengan Flask (/list_archives)
  Future<void> _fetchArchiveList() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("$ngrokUrl/list_archives"), // Sesuai dengan route di Flask
        headers: {
          'ngrok-skip-browser-warning': 'true',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          archiveFiles = jsonDecode(response.body);
        });
      } else {
        _showSnackBar(
          "Gagal memuat arsip: Server merespon ${response.statusCode}",
        );
      }
    } catch (e) {
      _showSnackBar("Koneksi Error: Pastikan Ngrok aktif");
      debugPrint("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Mengunduh Log Hari Ini
  Future<void> _downloadCurrentLog() async {
    final Uri url = Uri.parse("$ngrokUrl/download_csv");
    _launchURL(url);
  }

  // Mengunduh File Arsip Spesifik
  Future<void> _downloadArchiveFile(String fileName) async {
    final Uri url = Uri.parse("$ngrokUrl/download_archive/$fileName");
    _launchURL(url);
  }

  // Helper fungsi untuk membuka browser/download
  Future<void> _launchURL(Uri url) async {
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        _showSnackBar("Tidak dapat membuka link download");
      }
    } catch (e) {
      _showSnackBar("Terjadi kesalahan saat mengunduh");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Laporan Kandang"),
        elevation: 0,
        backgroundColor: Colors.blueGrey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchArchiveList,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchArchiveList,
        child: Column(
          children: [
            // Header: Download Log Aktif
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueGrey[900],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.description,
                        size: 40,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Log Aktif",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "log_kandang.csv",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _downloadCurrentLog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: const StadiumBorder(),
                        ),
                        child: const Text("UNDUH"),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Arsip Sebelumnya",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Daftar Archive
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : archiveFiles.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: archiveFiles.length,
                      itemBuilder: (context, index) {
                        String fileName = archiveFiles[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.orangeAccent,
                              child: Icon(Icons.history, color: Colors.white),
                            ),
                            title: Text(
                              fileName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: const Text("Laporan CSV Lampau"),
                            trailing: const Icon(
                              Icons.download,
                              color: Colors.blue,
                            ),
                            onTap: () => _downloadArchiveFile(fileName),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 10),
          Text(
            "Belum ada arsip tersimpan",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
=======
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class Riwayat extends StatefulWidget {
  const Riwayat({super.key});

  @override
  State<Riwayat> createState() => _RiwayatState();
}

class _RiwayatState extends State<Riwayat> {
  // Pastikan URL Ngrok ini selalu update atau gunakan domain statis
  final String ngrokUrl = "https://override-sprang-playmaker.ngrok-free.dev";

  List<dynamic> archiveFiles = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchArchiveList();
  }

  // PERBAIKAN: Endpoint disesuaikan dengan Flask (/list_archives)
  Future<void> _fetchArchiveList() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("$ngrokUrl/list_archives"), // Sesuai dengan route di Flask
        headers: {
          'ngrok-skip-browser-warning': 'true',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          archiveFiles = jsonDecode(response.body);
        });
      } else {
        _showSnackBar(
          "Gagal memuat arsip: Server merespon ${response.statusCode}",
        );
      }
    } catch (e) {
      _showSnackBar("Koneksi Error: Pastikan Ngrok aktif");
      debugPrint("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Mengunduh Log Hari Ini
  Future<void> _downloadCurrentLog() async {
    final Uri url = Uri.parse("$ngrokUrl/download_csv");
    _launchURL(url);
  }

  // Mengunduh File Arsip Spesifik
  Future<void> _downloadArchiveFile(String fileName) async {
    final Uri url = Uri.parse("$ngrokUrl/download_archive/$fileName");
    _launchURL(url);
  }

  // Helper fungsi untuk membuka browser/download
  Future<void> _launchURL(Uri url) async {
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        _showSnackBar("Tidak dapat membuka link download");
      }
    } catch (e) {
      _showSnackBar("Terjadi kesalahan saat mengunduh");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Laporan Kandang"),
        elevation: 0,
        backgroundColor: Colors.blueGrey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchArchiveList,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchArchiveList,
        child: Column(
          children: [
            // Header: Download Log Aktif
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueGrey[900],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.description,
                        size: 40,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Log Aktif",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "log_kandang.csv",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _downloadCurrentLog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: const StadiumBorder(),
                        ),
                        child: const Text("UNDUH"),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(15.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Arsip Sebelumnya",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Daftar Archive
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : archiveFiles.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: archiveFiles.length,
                      itemBuilder: (context, index) {
                        String fileName = archiveFiles[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.orangeAccent,
                              child: Icon(Icons.history, color: Colors.white),
                            ),
                            title: Text(
                              fileName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: const Text("Laporan CSV Lampau"),
                            trailing: const Icon(
                              Icons.download,
                              color: Colors.blue,
                            ),
                            onTap: () => _downloadArchiveFile(fileName),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 10),
          Text(
            "Belum ada arsip tersimpan",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
>>>>>>> 4503d69f29e08b68907cde9805b9476d084604a7
