import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfilPage extends StatefulWidget {
  final String username;
  const ProfilPage({super.key, required this.username});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String nama = "";
  String nisn = "";
  String kelas = "";
  String jenisKelamin = "";

  @override
  void initState() {
    super.initState();
    ambilDataSiswa();
  }

  void ambilDataSiswa() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final ref = FirebaseDatabase.instance.ref('profil/$uid');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map;
      setState(() {
        nama = data['namaLengkap'] ?? "";
        nisn = data['nisn'] ?? "";
        kelas = data['kelas'] ?? "";
        jenisKelamin = data['jenisKelamin'] ?? "";
      });
    }
  }

  void simpanDataSiswa() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseDatabase.instance.ref('profil/$uid').set({
      'namaLengkap': nama,
      'nisn': nisn,
      'kelas': kelas,
      'jenisKelamin': jenisKelamin,
    });
    ambilDataSiswa();
  }

  void tampilkanEditDialog() {
    final namaController = TextEditingController(text: nama);
    final nisnController = TextEditingController(text: nisn);
    final kelasController = TextEditingController(text: kelas);
    String? selectedGender = jenisKelamin;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Akun"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: "Nama"),
              ),
              TextField(
                controller: nisnController,
                decoration: const InputDecoration(labelText: "NISN"),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: (selectedGender != null && selectedGender!.isNotEmpty)
                    ? selectedGender
                    : null,
                decoration: const InputDecoration(labelText: "Jenis Kelamin"),
                items: const [
                  DropdownMenuItem(
                      value: 'Laki-laki', child: Text('Laki-laki')),
                  DropdownMenuItem(
                      value: 'Perempuan', child: Text('Perempuan')),
                ],
                onChanged: (value) {
                  selectedGender = value ?? "";
                },
              ),
              TextField(
                controller: kelasController,
                decoration: const InputDecoration(labelText: "Kelas"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Simpan"),
            onPressed: () {
              setState(() {
                nama = namaController.text;
                nisn = nisnController.text;
                kelas = kelasController.text;
                jenisKelamin = selectedGender ?? "";
              });
              simpanDataSiswa();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      drawer: AppDrawer(username: widget.username),
      appBar: AppBar(
        title: const Text("Profil Siswa"),
        backgroundColor: Colors.pink[300],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.pink[300],
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person,
                      size: 60, color: Color.fromARGB(153, 15, 79, 103)),
                ),
                const SizedBox(height: 12),
                Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                // Text(
                //   widget.username,
                //   style: const TextStyle(
                //     fontSize: 16,
                //     color: Colors.white70,
                //   ),
                // ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                itemProfil("NISN", nisn),
                itemProfil("Jenis Kelamin", jenisKelamin),
                itemProfil("Kelas", kelas),
              ],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink[300],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              foregroundColor: Colors.white,
            ),
            onPressed: tampilkanEditDialog,
            icon: const Icon(Icons.edit),
            label: const Text("Edit Akun"),
          ),
        ],
      ),
    );
  }

  Widget itemProfil(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text("$title:", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
