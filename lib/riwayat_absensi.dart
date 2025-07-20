import 'package:flutter/material.dart';
import 'app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class RiwayatAbsensiPage extends StatefulWidget {
  final String username;

  const RiwayatAbsensiPage({Key? key, this.username = "Username"})
      : super(key: key);

  @override
  State<RiwayatAbsensiPage> createState() => _RiwayatAbsensiPageState();
}

class _RiwayatAbsensiPageState extends State<RiwayatAbsensiPage> {
  String _selectedStatus = 'Semua';
  List<Map<String, dynamic>> _riwayat = [];
  String? _nisn;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchNisnAndRiwayat();
  }

  Future<void> _fetchNisnAndRiwayat() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final profilRef = FirebaseDatabase.instance.ref('profil/$uid/nisn');
    final profilSnap = await profilRef.get();
    if (!profilSnap.exists) return;
    _nisn = profilSnap.value as String?;
    if (_nisn == null) return;
    final presensiRef = FirebaseDatabase.instance.ref('presensi');
    final presensiSnap = await presensiRef.get();
    List<Map<String, dynamic>> temp = [];
    if (presensiSnap.exists) {
      for (final child in presensiSnap.children) {
        final data = child.value as Map<dynamic, dynamic>;
        if (data['nis'] == _nisn) {
          temp.add({
            'nis': data['nis'],
            'tanggal': data['tanggal'],
            'waktu': data['waktu'],
            'status': data['status'],
          });
        }
      }
    }
    setState(() {
      _riwayat = temp;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredData = _selectedStatus == 'Semua'
        ? _riwayat
        : _riwayat.where((item) => item['status'] == _selectedStatus).toList();
    return Scaffold(
      drawer: AppDrawer(username: widget.username),
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
          children: [
            Row(
              children: [
                const Text(
                  "Filter Status: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedStatus,
                  items: ['Semua', 'Terlambat', 'Hadir', 'Tidak Hadir']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.grey[300],
              child: Row(
                children: const [
                  _TableCellFlex(text: 'No', flex: 1),
                  _TableCellFlex(text: 'NISN', flex: 2),
                  _TableCellFlex(text: 'Waktu', flex: 2),
                  _TableCellFlex(text: 'Tanggal', flex: 2),
                  _TableCellFlex(text: 'Status', flex: 2),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator())
                  : filteredData.isEmpty
                      ? Center(child: Text('Belum ada data presensi.'))
                      : ListView.builder(
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) {
                            final item = filteredData[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              color: index % 2 == 0
                                  ? Colors.white
                                  : Colors.grey[100],
                              child: Row(
                                children: [
                                  _TableCellFlex(text: '${index + 1}', flex: 1),
                                  _TableCellFlex(
                                      text: item['nis'] ?? '', flex: 2),
                                  _TableCellFlex(
                                      text: item['waktu'] ?? '', flex: 2),
                                  _TableCellFlex(
                                      text: item['tanggal'] ?? '', flex: 2),
                                  _TableCellFlex(
                                      text: item['status'] ?? '', flex: 2),
                                ],
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
}

// Widget bantu untuk cell kolom tabel
class _TableCellFlex extends StatelessWidget {
  final String text;
  final int flex;

  const _TableCellFlex({required this.text, this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          text,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}
