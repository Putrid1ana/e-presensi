import 'package:flutter/material.dart';
import 'app_drawer.dart';

class RiwayatAbsensiPage extends StatelessWidget {
  final String username; // ✅ Tambahkan ini

  const RiwayatAbsensiPage({Key? key, this.username = "Username"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(username: username), // ✅ Tidak error lagi
      appBar: AppBar(
        backgroundColor: Colors.pink[200],
        elevation: 0,
        title: const Text(
          'Riwayat Absensi',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.pink[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Riwayat absensi:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              color: Colors.grey[100],
              child: Row(
                children: const [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Hari, Tanggal/Bulan/Tahun",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Status",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: const [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Senin, 05/05/2025"),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Hadir"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
