import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/telegram_service.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final TelegramService service = TelegramService();
  List<Map<String, dynamic>> logs = [];

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 5), (timer) async {
      final data = await service.getUpdates();

      if (data.isNotEmpty) {
        setState(() {
          logs.insertAll(0, data); // masuk ke atas
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Monitoring Kandang")),
      body: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final item = logs[index];

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(item["nama"]),
              subtitle: Text("${item["status"]}\n${item["waktu"]}"),
              trailing: item["image"] != null
                  ? Image.network(item["image"], width: 60)
                  : const Icon(Icons.person),
            ),
          );
        },
      ),
    );
  }
}
