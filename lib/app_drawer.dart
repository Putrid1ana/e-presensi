// File: app_drawer.dart
import 'package:flutter/material.dart';
import 'riwayat_absensi.dart';
import 'homescreen.dart';
import 'package:absensi_gps/auth/login_screen.dart';
import 'profil_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AppDrawer extends StatelessWidget {
  final String username;
  const AppDrawer({Key? key, this.username = "Username"}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _UserHeader(username: username),
          ListTile(
            leading: Icon(Icons.home, size: 28, color: Colors.pink[300]),
            title: Text('Absensi',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => homescreen(username: username),
                ),
              );
            },
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.history, size: 28, color: Colors.pink[300]),
            title: Text('Riwayat Absensi',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RiwayatAbsensiPage(username: username),
                ),
              );
            },
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.person, size: 28, color: Colors.pink[300]),
            title: Text('Profil Siswa',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilPage(username: username),
                ),
              );
            },
          ),
          Spacer(),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.logout, size: 28, color: Colors.red[300]),
            title: Text('Keluar',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.red[300])),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _UserHeader extends StatefulWidget {
  final String username;
  const _UserHeader({Key? key, required this.username}) : super(key: key);

  @override
  State<_UserHeader> createState() => _UserHeaderState();
}

class _UserHeaderState extends State<_UserHeader> {
  String? namaLengkap;

  @override
  void initState() {
    super.initState();
    _loadNamaLengkap();
  }

  Future<void> _loadNamaLengkap() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final ref = FirebaseDatabase.instance.ref('profil/$uid/namaLengkap');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      setState(() {
        namaLengkap = snapshot.value as String?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: Colors.pink[300],
      ),
      child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 38, color: Colors.pink[300]),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaLengkap ?? widget.username,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Siswa",
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
