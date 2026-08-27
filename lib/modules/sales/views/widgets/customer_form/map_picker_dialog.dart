import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class MapLocationResult {
  final double lat;
  final double lng;
  final String address;
  final String? province;
  final String? regency;
  final String? district;
  final String? village;

  MapLocationResult({
    required this.lat,
    required this.lng,
    required this.address,
    this.province,
    this.regency,
    this.district,
    this.village,
  });
}

class MapPickerDialog extends StatefulWidget {
  const MapPickerDialog({super.key});

  @override
  State<MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final Dio _dio = Dio();
  latlong.LatLng _currentCenter = const latlong.LatLng(-8.409518, 115.188919);
  List<dynamic> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _dio.options.headers['User-Agent'] = 'id.nohama.sales';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  Future<void> _searchLocation(String query) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {'q': query, 'format': 'json', 'addressdetails': 1},
      );
      setState(() {
        _searchResults = response.data ?? [];
      });
    } catch (e) {
      debugPrint('Search error: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        _currentCenter = latlong.LatLng(position.latitude, position.longitude);
        _mapController.move(_currentCenter, 15);
      });
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  Future<void> _selectLocation() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': _currentCenter.latitude,
          'lon': _currentCenter.longitude,
          'format': 'json',
          'addressdetails': 1,
        },
      );
      final data = response.data;
      if (data == null) return;
      final address = data['address'] as Map<String, dynamic>? ?? {};

      final result = MapLocationResult(
        lat: _currentCenter.latitude,
        lng: _currentCenter.longitude,
        address: data['display_name'] as String? ?? '',
        province: address['state'] as String?,
        regency:
            (address['city'] ?? address['county'] ?? address['town'])
                as String?,
        district: (address['suburb'] ?? address['district']) as String?,
        village: (address['village'] ?? address['neighbourhood']) as String?,
      );

      if (mounted) Navigator.of(context).pop(result);
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withAlpha(230),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            hintText: 'Cari lokasi...',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            isDense: true,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, size: 20),
              onPressed: () => _searchLocation(_searchController.text),
            ),
          ),
          onSubmitted: _searchLocation,
        ),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (_searchResults.isNotEmpty) {
                setState(() => _searchResults.clear());
              }
            },
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentCenter,
                initialZoom: 13,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onPositionChanged: (position, hasGesture) {
                  _currentCenter = position.center;
                  if (_searchResults.isNotEmpty) {
                    setState(() => _searchResults.clear());
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'id.nohama.sales',
                ),
              ],
            ),
          ),
          const IgnorePointer(
            child: Center(child: Icon(Icons.add, color: Colors.red, size: 40)),
          ),
          if (_searchResults.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
              left: 16,
              right: 16,
              child: Card(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final item =
                          _searchResults[index] as Map<String, dynamic>;
                      return ListTile(
                        title: Text(item['display_name'] as String),
                        onTap: () {
                          final lat = double.parse(item['lat'] as String);
                          final lon = double.parse(item['lon'] as String);
                          setState(() {
                            _currentCenter = latlong.LatLng(lat, lon);
                            _mapController.move(_currentCenter, 15);
                            _searchResults.clear();
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.my_location),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _selectLocation,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Pilih Lokasi Ini', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
