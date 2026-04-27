<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'live_camera.dart';
import 'riwayat.dart';
import 'notifikasi.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kandang Ayam Monitor"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            menuCard(context, "Live Camera", Icons.camera_alt, LiveCamera()),
            menuCard(
              context,
              "Notifikasi",
              Icons.notifications,
              Notifikasi(),
              badge: "3",
            ),
            menuCard(context, "Riwayat", Icons.history, Riwayat()),

            Spacer(),

            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.settings),
              label: Text("Pengaturan"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget menuCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget page, {
    String? badge,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),

            if (badge != null)
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                child: Text(
                  badge,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
=======
import 'package:flutter/material.dart';
import 'live_camera.dart';
import 'riwayat.dart';
import 'notifikasi.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kandang Ayam Monitor"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            menuCard(context, "Live Camera", Icons.camera_alt, LiveCamera()),
            menuCard(
              context,
              "Notifikasi",
              Icons.notifications,
              Notifikasi(),
              badge: "3",
            ),
            menuCard(context, "Riwayat", Icons.history, Riwayat()),

            Spacer(),

            ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.settings),
              label: Text("Pengaturan"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget menuCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget page, {
    String? badge,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),

            if (badge != null)
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                child: Text(
                  badge,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
>>>>>>> 4503d69f29e08b68907cde9805b9476d084604a7
