import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'app_drawer.dart';

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

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initLocation();
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
                            userAgentPackageName: 'com.example.absensi_gps',
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
                              // Marker lokasi utama
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
                          // Lingkaran zona absensi
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
              Column(
                children: [
                  Text('Akurasi GPS: ${_accuracy!.toStringAsFixed(1)} meter',
                      style: TextStyle(fontSize: 14, color: Colors.black54)),
                  if (_provider != null)
                    Text('Provider: $_provider',
                        style: TextStyle(fontSize: 12, color: Colors.black45)),
                  if (_timestamp != null)
                    Text('Waktu: ${_timestamp.toString()}',
                        style: TextStyle(fontSize: 12, color: Colors.black45)),
                ],
              ),
            if (_distanceToMain != null)
              Column(
                children: [
                  Text(
                    _inZone
                        ? 'Anda berada di dalam zona absensi.'
                        : 'Anda di luar zona absensi.',
                    style: TextStyle(
                      color: _inZone ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                      'Jarak ke titik utama: ${_distanceToMain!.toStringAsFixed(1)} meter',
                      style: TextStyle(fontSize: 13, color: Colors.black54)),
                ],
              ),
            SizedBox(height: 10),
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
                  onPressed: _inZone
                      ? () {
                          // Logika absen
                        }
                      : null,
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
                IconButton(
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
              ],
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
