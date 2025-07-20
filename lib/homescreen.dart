import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'app_drawer.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/date_symbol_data_local.dart';

class homescreen extends StatefulWidget {
  final String username;
  const homescreen({Key? key, this.username = "Username"}) : super(key: key);

  @override
  State<homescreen> createState() => _homescreenState();
}

class _homescreenState extends State<homescreen> {
  LatLng? _currentLatLng;
  String? _error;
  late final MapController _mapController;
  Stream<Position>? _positionStream;
  bool _mapMoved = false;
  double? _accuracy;
  bool _userMovedMap = false;
  String? _provider;
  DateTime? _timestamp;
  static const LatLng _mainLocation = LatLng(-8.157596, 113.722835);
  static const double _maxRadius = 50.0; // meter
  bool _inZone = false;
  double? _distanceToMain;
  String? _currentTime;
  String? _currentDate;
  Timer? _timer;
  String? _namaLengkap;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initLocation();
    _loadNamaLengkap();
    initializeDateFormatting('id_ID', null).then((_) {
      _updateDateTime();
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        _updateDateTime();
      });
    });
  }

  void _updateDateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('HH:mm').format(now);
      _currentDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(now);
    });
  }

  Future<void> _loadNamaLengkap() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final ref = FirebaseDatabase.instance.ref('profil/$uid/namaLengkap');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      setState(() {
        _namaLengkap = snapshot.value as String?;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<String?> _getNisn() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final ref = FirebaseDatabase.instance.ref('profil/$uid/nisn');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      return snapshot.value as String?;
    }
    return null;
  }

  Future<void> _absen() async {
    final nisn = await _getNisn();
    if (nisn == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil NISN.')),
      );
      return;
    }
    final now = DateTime.now();
    final tanggal = DateFormat('yyyy-MM-dd').format(now);
    final waktu = DateFormat('HH:mm').format(now);
    String status = '';
    final jam = now.hour;
    final menit = now.minute;
    final totalMenit = jam * 60 + menit;
    if (totalMenit >= 300 && totalMenit <= 420) {
      status = 'Hadir'; // 05:00 - 07:00
    } else if (totalMenit >= 421 && totalMenit <= 900) {
      status = 'Terlambat'; // 07:01 - 15:00
    } else {
      status = 'Tidak Hadir'; // Di luar jam absen
    }
    final presensiRef = FirebaseDatabase.instance.ref('presensi').push();
    await presensiRef.set({
      'nis': nisn,
      'tanggal': tanggal,
      'waktu': waktu,
      'status': status,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Absen berhasil! Status: $status')),
    );
  }

  void _fitMapToBounds() {
    if (_currentLatLng != null) {
      final sw = LatLng(
        _currentLatLng!.latitude < _mainLocation.latitude
            ? _currentLatLng!.latitude
            : _mainLocation.latitude,
        _currentLatLng!.longitude < _mainLocation.longitude
            ? _currentLatLng!.longitude
            : _mainLocation.longitude,
      );
      final ne = LatLng(
        _currentLatLng!.latitude > _mainLocation.latitude
            ? _currentLatLng!.latitude
            : _mainLocation.latitude,
        _currentLatLng!.longitude > _mainLocation.longitude
            ? _currentLatLng!.longitude
            : _mainLocation.longitude,
      );
      final bounds = LatLngBounds(sw, ne);
      _mapController.fitBounds(
        bounds,
        options: const FitBoundsOptions(padding: EdgeInsets.all(60)),
      );
    }
  }

  Future<void> _initLocation() async {
    LocationPermission permission;
    bool serviceEnabled;
    setState(() {
      _error = null;
    });
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _error = 'Layanan lokasi tidak aktif. Aktifkan GPS.';
      });
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _error = 'Izin lokasi ditolak.';
        });
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _error = 'Izin lokasi ditolak permanen. Buka pengaturan aplikasi.';
      });
      return;
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );
      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
        _accuracy = position.accuracy;
        _provider = position.isMocked ? 'Mock' : 'GPS';
        _timestamp = position.timestamp;
        _distanceToMain = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          _mainLocation.latitude,
          _mainLocation.longitude,
        );
        _inZone = _distanceToMain! <= _maxRadius;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitMapToBounds();
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal mendapatkan lokasi: '
            '${e.toString()}';
      });
    }
    // Pastikan stream tidak null
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
      ),
    );
    _positionStream!.listen((position) {
      final latLng = LatLng(position.latitude, position.longitude);
      if (position.accuracy < 50) {
        setState(() {
          _currentLatLng = latLng;
          _accuracy = position.accuracy;
          _provider = position.isMocked ? 'Mock' : 'GPS';
          _timestamp = position.timestamp;
          _distanceToMain = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            _mainLocation.latitude,
            _mainLocation.longitude,
          );
          _inZone = _distanceToMain! <= _maxRadius;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _fitMapToBounds();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(username: widget.username),
      appBar: AppBar(
        backgroundColor: Colors.pink[200],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          'Absensi',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: Colors.pink[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header dengan avatar dan nama
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.pink[100],
                    child:
                        Icon(Icons.person, size: 32, color: Colors.pink[700]),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _namaLengkap ?? widget.username,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (_currentDate != null)
                          Text(
                            _currentDate!,
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                      ],
                    ),
                  ),
                  if (_currentTime != null)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.pink[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 18, color: Colors.pink[700]),
                          SizedBox(width: 4),
                          Text(_currentTime!,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: 18),
              // Card Map dan Info Lokasi
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Container(
                        height: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[300],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _error != null
                              ? Center(
                                  child: Text(_error!,
                                      style: TextStyle(color: Colors.red)))
                              : FlutterMap(
                                  mapController: _mapController,
                                  options: MapOptions(
                                    center: _currentLatLng ?? _mainLocation,
                                    zoom: 17,
                                    maxZoom: 19,
                                    onPositionChanged: (pos, hasGesture) {
                                      if (hasGesture) {
                                        setState(() {
                                          _userMovedMap = true;
                                        });
                                      }
                                    },
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                      subdomains: ['a', 'b', 'c'],
                                      userAgentPackageName:
                                          'com.example.absensi_gps',
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        if (_currentLatLng != null)
                                          Marker(
                                            width: 60,
                                            height: 60,
                                            point: _currentLatLng!,
                                            child: const Icon(
                                              Icons.my_location,
                                              color: Colors.blue,
                                              size: 40,
                                            ),
                                          ),
                                        Marker(
                                          width: 60,
                                          height: 60,
                                          point: _mainLocation,
                                          child: const Icon(
                                            Icons.location_on,
                                            color: Colors.red,
                                            size: 40,
                                          ),
                                        ),
                                      ],
                                    ),
                                    CircleLayer(
                                      circles: [
                                        CircleMarker(
                                          point: _mainLocation,
                                          color: Colors.red.withOpacity(0.2),
                                          borderStrokeWidth: 2,
                                          borderColor: Colors.red,
                                          radius: _maxRadius, // meter
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      SizedBox(height: 10),
                      if (_accuracy != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.gps_fixed,
                                size: 18, color: Colors.blueGrey),
                            SizedBox(width: 6),
                            Text('Akurasi: ${_accuracy!.toStringAsFixed(1)} m',
                                style: TextStyle(fontSize: 13)),
                            if (_provider != null) ...[
                              SizedBox(width: 10),
                              Icon(Icons.satellite_alt,
                                  size: 16, color: Colors.blueGrey),
                              SizedBox(width: 2),
                              Text('$_provider',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black45)),
                            ],
                          ],
                        ),
                      if (_distanceToMain != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.social_distance,
                                  size: 18, color: Colors.pink[400]),
                              SizedBox(width: 6),
                              Text(
                                  'Jarak ke titik utama: ${_distanceToMain!.toStringAsFixed(1)} m',
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.black54)),
                            ],
                          ),
                        ),
                      if (_distanceToMain != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _inZone ? Icons.check_circle : Icons.error,
                                color: _inZone ? Colors.green : Colors.red,
                                size: 20,
                              ),
                              SizedBox(width: 6),
                              Text(
                                _inZone
                                    ? 'Anda berada di dalam zona absensi.'
                                    : 'Anda di luar zona absensi.',
                                style: TextStyle(
                                  color: _inZone ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 18),
              // Card untuk tombol aksi
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _inZone ? Colors.pink[400] : Colors.grey[300],
                            foregroundColor:
                                _inZone ? Colors.white : Colors.black38,
                            elevation: 2,
                            minimumSize: Size(100, 44),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _inZone ? _absen : null,
                          icon: Icon(Icons.fingerprint),
                          label: Text('Absen',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),                      
                      SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.pink[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.my_location, color: Colors.blue),
                          tooltip: 'Kembali ke lokasi saya',
                          onPressed: () {
                            if (_currentLatLng != null) {
                              setState(() {
                                _userMovedMap = false;
                              });
                              _mapController.move(_currentLatLng!, 17);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
