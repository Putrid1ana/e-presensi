import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '';

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

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initLocation();
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
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentLatLng != null) {
          _mapController.move(_currentLatLng!, 17);
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal mendapatkan lokasi: '
            '${e.toString()}';
      });
    }
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );
    _positionStream!.listen((position) {
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLatLng = latLng;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(latLng, 17);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(username: widget.username),
      appBar: AppBar(
        backgroundColor: Colors.pink[200],
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _error != null
                    ? Center(
                        child: Text(_error!,
                            style: const TextStyle(color: Colors.red)))
                    : _currentLatLng == null
                        ? const Center(child: CircularProgressIndicator())
                        : FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              center: _currentLatLng,
                              zoom: 17,
                              maxZoom: 19,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                subdomains: ['a', 'b', 'c'],
                                userAgentPackageName: 'com.example.absensi_gps',
                              ),
                              MarkerLayer(
                                markers: [
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
                                ],
                              ),
                            ],
                          ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    elevation: 4,
                    minimumSize: Size(100, 40),
                  ),
                  onPressed: () {
                    // Logika absen
                  },
                  child: Text('Absen'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    elevation: 4,
                    minimumSize: Size(100, 40),
                  ),
                  onPressed: () {
                    // Logika izin
                  },
                  child: Text('Izin'),
                ),
              ],
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  final String username;
  const AppDrawer({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(username),
            accountEmail: Text(''),
          ),
          // Tambahkan menu lain di sini
        ],
      ),
    );
  }
}
