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
            leading: Icon(Icons.home),
            title: Text('Absensi'),
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
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Riwayat Absensi'),
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
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profil Siswa'),
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
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Keluar'),
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
        color: Theme.of(context).primaryColor,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              namaLengkap ?? widget.username,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
