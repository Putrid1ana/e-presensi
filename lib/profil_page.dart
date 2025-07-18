import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilPage extends StatefulWidget {
  final String username;
  const ProfilPage({super.key, required this.username});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String nama = "";
  String nis = "";
  String kelas = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    ambilDataSiswa();
  }

  void ambilDataSiswa() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nama = prefs.getString('namaUser') ?? "";
      nis = prefs.getString('nis') ?? "";
      kelas = prefs.getString('kelas') ?? "";
      email = prefs.getString('email') ?? "";
    });
  }

  void simpanDataSiswa() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('namaUser', nama);
    await prefs.setString('nis', nis);
    await prefs.setString('kelas', kelas);
    await prefs.setString('email', email);
    ambilDataSiswa();
  }

  void tampilkanEditDialog() {
    final namaController = TextEditingController(text: nama);
    final nisController = TextEditingController(text: nis);
    final kelasController = TextEditingController(text: kelas);
    final emailController = TextEditingController(text: email);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Akun"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: namaController, decoration: const InputDecoration(labelText: "Nama")),
              TextField(controller: nisController, decoration: const InputDecoration(labelText: "NIS")),
              TextField(controller: kelasController, decoration: const InputDecoration(labelText: "Kelas")),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
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
                nis = nisController.text;
                kelas = kelasController.text;
                email = emailController.text;
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
      appBar: AppBar(
        title: const Text("Profil Siswa"),
        backgroundColor: Colors.pink[300],
        foregroundColor: Colors.white,
        elevation: 0,
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
                  child: Icon(Icons.person, size: 60, color: Color.fromARGB(153, 15, 79, 103)),
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
                Text(
                  widget.username,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Detail siswa
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                itemProfil("NIS", nis),
                const Divider(),
                itemProfil("Kelas", kelas),
                const Divider(),
                itemProfil("Email", email),
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
          )
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
