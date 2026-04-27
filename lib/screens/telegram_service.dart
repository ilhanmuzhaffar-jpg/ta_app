import 'dart:convert';
import 'package:http/http.dart' as http;

class TelegramService {
  final String token = "8274199588:AAEpsq42aNClXBLmyppuDw1gJ1VKmoDr31c";

  // GANTI dengan URL Ngrok kamu yang sedang aktif
  final String ngrokUrl = "https://override-sprang-playmaker.ngrok-free.dev";

  /// FUNGSI BARU: Mengambil data langsung dari log_kandang.csv di Orange Pi
  Future<List<Map<String, dynamic>>> getCsvLogs() async {
    try {
      final response = await http
          .get(
            Uri.parse("$ngrokUrl/get_csv_logs"),
            headers: {
              'ngrok-skip-browser-warning': 'true',
            }, // Bypass peringatan Ngrok
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        return data.map((item) {
          // Cek apakah status mengandung kata berbahaya
          String status = item["Status"] ?? "Unknown";
          bool isDanger = status.contains("ASING") || status.contains("BAHAYA");

          return {
            "waktu": item["Waktu"],
            "status": status,
            "nama": item["Nama"],
            "image":
                null, // CSV hanya simpan path lokal, foto tetap dari Telegram
            "isDanger": isDanger,
          };
        }).toList();
      }
    } catch (e) {
      print("Gagal mengambil CSV dari OPi: $e");
    }
    return [];
  }

  /// FUNGSI EXISTING: Mengambil pesan terbaru dari Telegram (untuk dapet URL Foto)
  Future<List<Map<String, dynamic>>> getUpdates() async {
    try {
      // Kita set offset -5 agar selalu ambil 5 pesan terakhir saja untuk sinkronisasi foto
      final url = Uri.parse(
        "https://api.telegram.org/bot$token/getUpdates?offset=-5",
      );
      final response = await http.get(url);

      List<Map<String, dynamic>> results = [];

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        for (var item in data["result"]) {
          if (item["message"] != null) {
            final msg = item["message"];
            String? textContent = msg["text"] ?? msg["caption"];

            if (textContent != null && textContent.contains("APP_OPI")) {
              final parts = textContent.split("|");
              if (parts.length >= 4) {
                String rawStatus = parts[1].trim();

                String? imageUrl;
                if (msg["photo"] != null) {
                  String fileId = msg["photo"].last["file_id"];
                  imageUrl = await getFileUrl(fileId);
                }

                results.add({
                  "status": rawStatus,
                  "nama": parts[2].trim(),
                  "waktu": parts[3].trim(),
                  "image": imageUrl,
                  "isDanger":
                      rawStatus.contains("ASING") ||
                      rawStatus.contains("BAHAYA"),
                });
              }
            }
          }
        }
      }
      return results;
    } catch (e) {
      print("Telegram Service Error: $e");
      return [];
    }
  }

  Future<String> getFileUrl(String fileId) async {
    try {
      final url = Uri.parse(
        "https://api.telegram.org/bot$token/getFile?file_id=$fileId",
      );
      final res = await http.get(url);
      final data = jsonDecode(res.body);
      final filePath = data["result"]["file_path"];
      return "https://api.telegram.org/file/bot$token/$filePath";
    } catch (e) {
      return "";
    }
  }
}
