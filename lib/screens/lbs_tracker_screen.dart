import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

class LBSTrackerScreen extends StatefulWidget {
  const LBSTrackerScreen({super.key});

  @override
  State<LBSTrackerScreen> createState() => _LBSTrackerScreenState();
}

class _LBSTrackerScreenState extends State<LBSTrackerScreen> {
  Location location = Location();
  GoogleMapController? mapController;
  LatLng? currentLocation;
  Set<Marker> markers = {};
  bool isLoadingLocation = true;
  String locationMessage = "Mencari lokasi...";
  MapType currentMapType = MapType.normal;
  bool _shouldFollowUser = true;

  // Daftar toko emas Antam
  final List<Map<String, dynamic>> antamStores = [
    {
      'name': 'Butik Emas LM - Gedung Antam',
      'address': 'Jl. Letjen. TB. Simatupang No.1, Tanjung Barat, Jakarta Selatan',
      'latitude': -6.2890725,
      'longitude': 106.8251993,
      'website': 'https://www.logammulia.com/id/contact',
    },
    {
      'name': 'Butik Emas LM - Kebon Sirih',
      'address': 'Jl. Kebon Sirih No.1, Kebon Sirih, Jakarta Pusat',
      'latitude': -6.1831,
      'longitude': 106.8305,
      'website': 'https://www.logammulia.com/id/contact',
    },
    {
      'name': 'Galeri 24 - Mall Grand Indonesia',
      'address': 'Grand Indonesia Mall, East Mall Lt. 3, Jl. M.H. Thamrin No.1',
      'latitude': -6.1952,
      'longitude': 106.8214,
      'website': 'https://www.logammulia.com/id/contact',
    },
    {
      'name': 'Galeri 24 - Plaza Semanggi',
      'address': 'Plaza Semanggi Lt. 2, Jl. Jend. Sudirman Kav. 50',
      'latitude': -6.2219,
      'longitude': 106.8136,
      'website': 'https://www.logammulia.com/id/contact',
    },
  ];

  @override
  void initState() {
    super.initState();
    getLocation();
    _addStoreMarkers();
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  Future<void> getLocation() async {
    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          setState(() {
            locationMessage = "Layanan lokasi tidak aktif";
            isLoadingLocation = false;
          });
          return;
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          setState(() {
            locationMessage = "Izin lokasi ditolak";
            isLoadingLocation = false;
          });
          return;
        }
      }

      final locData = await location.getLocation();
      updateLocation(locData);

      // Listen to location changes
      location.onLocationChanged.listen((LocationData currentLoc) {
        updateLocation(currentLoc);
      });
    } catch (e) {
      setState(() {
        locationMessage = "Error: $e";
        isLoadingLocation = false;
      });
    }
  }

  void updateLocation(LocationData locData) {
    if (locData.latitude == null || locData.longitude == null) return;

    setState(() {
      currentLocation = LatLng(locData.latitude!, locData.longitude!);
      locationMessage = "Latitude: "+(locData.latitude?.toStringAsFixed(6)??"")+"\nLongitude: "+(locData.longitude?.toStringAsFixed(6)??"");
      isLoadingLocation = false;
      
      markers.removeWhere((marker) => marker.markerId.value == 'currentLocation');
      markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: currentLocation!,
          infoWindow: const InfoWindow(title: 'Lokasi Saat Ini'),
        ),
      );
    });

    if (mapController != null && currentLocation != null && _shouldFollowUser) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLocation!,
            zoom: 15,
          ),
        ),
      );
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (currentLocation != null) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLocation!,
            zoom: 15,
          ),
        ),
      );
    }
  }

  void _addStoreMarkers() {
    for (var store in antamStores) {
      markers.add(
        Marker(
          markerId: MarkerId(store['name']),
          position: LatLng(store['latitude'], store['longitude']),
          infoWindow: InfoWindow(
            title: store['name'],
            snippet: store['address'],
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        ),
      );
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchMaps(double lat, double lng, String name) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$name';
    await _launchURL(url);
  }

  Future<void> _launchPhone(String phone) async {
    final url = 'tel:$phone';
    await _launchURL(url);
  }

  Widget _buildStoreList() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8DC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.store,
                  color: Colors.amber[800],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Daftar Toko Emas Antam',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: antamStores.length,
            itemBuilder: (context, index) {
              final store = antamStores[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                color: const Color(0xFFFFF8DC),
                child: ExpansionTile(
                  iconColor: Colors.amber[800],
                  collapsedIconColor: Colors.amber[800],
                  title: Text(
                    store['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[800],
                    ),
                  ),
                  subtitle: Text(
                    store['address'],
                    style: const TextStyle(
                      color: Color(0xFF8B4513),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.map),
                            label: const Text('Buka Maps'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[800],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _shouldFollowUser = false;
                              });
                              
                              Scrollable.ensureVisible(
                                context,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                              
                              if (mapController != null) {
                                mapController!.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: LatLng(store['latitude'], store['longitude']),
                                      zoom: 16,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.web),
                            label: const Text('Kunjungi Website'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.amber[800],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.amber[800]!),
                              ),
                            ),
                            onPressed: () => _launchURL(store['website']),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lokasi Toko',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.amber[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              currentMapType == MapType.normal ? Icons.map : Icons.satellite,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                currentMapType = currentMapType == MapType.normal
                    ? MapType.satellite
                    : MapType.normal;
              });
            },
          ),
          IconButton(
            icon: Icon(
              _shouldFollowUser ? Icons.gps_fixed : Icons.gps_not_fixed,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _shouldFollowUser = !_shouldFollowUser;
                if (_shouldFollowUser && currentLocation != null) {
                  mapController?.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: currentLocation!,
                        zoom: 15,
                      ),
                    ),
                  );
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: onMapCreated,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(-6.2000, 106.8166), // Jakarta
                    zoom: 11,
                  ),
                  markers: markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  mapType: currentMapType,
                  onTap: (_) {
                    setState(() {
                      _shouldFollowUser = false;
                    });
                  },
                ),
                if (isLoadingLocation)
                  Container(
                    color: Colors.black45,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.amber[800],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              locationMessage,
                              style: TextStyle(
                                color: Colors.amber[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildStoreList(),
            ),
          ),
        ],
      ),
    );
  }
}