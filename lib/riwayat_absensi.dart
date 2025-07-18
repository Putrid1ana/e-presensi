import 'package:flutter/material.dart';
import 'app_drawer.dart';

class RiwayatAbsensiPage extends StatefulWidget {
  final String username;

  const RiwayatAbsensiPage({Key? key, this.username = "Username"})
      : super(key: key);

  @override
  State<RiwayatAbsensiPage> createState() => _RiwayatAbsensiPageState();
}

class _RiwayatAbsensiPageState extends State<RiwayatAbsensiPage> {
  String _selectedStatus = 'Semua';

  // Contoh data absensi (dummy)
  final List<Map<String, String>> absensiData = [
    {
      'nama': 'Rani',
      'kelas': 'XII RPL',
      'nis': '123456',
      'waktu': 'Senin, 05/05/2025',
      'lokasi': '.....',
      'status': 'Hadir'
    },
    {
      'nama': 'Budi',
      'kelas': 'XII RPL',
      'nis': '123457',
      'waktu': 'Senin, 05/05/2025',
      'lokasi': '....',
      'status': 'Izin'
    },
    {
      'nama': 'Siti',
      'kelas': 'XII RPL',
      'nis': '123458',
      'waktu': 'Senin, 05/05/2025',
      'lokasi': '...',
      'status': 'Tidak Hadir'
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter data berdasarkan status yang dipilih
    List<Map<String, String>> filteredData = _selectedStatus == 'Semua'
        ? absensiData
        : absensiData
            .where((item) => item['status'] == _selectedStatus)
            .toList();

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
            // Dropdown filter
            Row(
              children: [
                const Text(
                  "Filter Status: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedStatus,
                  items: ['Semua', 'Hadir', 'Tidak Hadir', 'Izin']
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
            // Header tabel
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.grey[300],
              child: Row(
                children: const [
                  _TableCellFlex(text: 'No', flex: 1),
                  _TableCellFlex(text: 'Waktu', flex: 2),
                  _TableCellFlex(text: 'Nama', flex: 2),
                  _TableCellFlex(text: 'Kelas', flex: 2),
                  _TableCellFlex(text: 'NIS', flex: 2),
                  _TableCellFlex(text: 'Lokasi', flex: 2),
                  _TableCellFlex(text: 'Status', flex: 2),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Isi data
            Expanded(
              child: ListView.builder(
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  final item = filteredData[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: index % 2 == 0 ? Colors.white : Colors.grey[100],
                    child: Row(
                      children: [
                        _TableCellFlex(text: '${index + 1}', flex: 1),
                        _TableCellFlex(text: item['waktu']!, flex: 2),
                        _TableCellFlex(text: item['nama']!, flex: 2),
                        _TableCellFlex(text: item['kelas']!, flex: 2),
                        _TableCellFlex(text: item['nis']!, flex: 2),
                        _TableCellFlex(text: item['lokasi']!, flex: 2),
                        _TableCellFlex(text: item['status']!, flex: 2),
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
