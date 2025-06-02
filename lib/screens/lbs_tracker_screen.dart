import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

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

  @override
  void initState() {
    super.initState();
    getLocation();
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
      locationMessage = "Latitude: ${locData.latitude?.toStringAsFixed(6)}\nLongitude: ${locData.longitude?.toStringAsFixed(6)}";
      isLoadingLocation = false;
      
      markers = {
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: currentLocation!,
          infoWindow: const InfoWindow(title: 'Lokasi Saat Ini'),
        ),
      };

      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLocation!,
            zoom: 15,
          ),
        ),
      );
    });
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

  void toggleMapType() {
    setState(() {
      currentMapType = currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LBS Tracker'),
        actions: [
          IconButton(
            icon: Icon(
              currentMapType == MapType.normal
                  ? Icons.satellite_alt
                  : Icons.map,
              color: Colors.white,
            ),
            onPressed: toggleMapType,
          ),
        ],
      ),
      body: Column(
        children: [
          // Info Card
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Theme.of(context).primaryColor, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Koordinat Lokasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          locationMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Map
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: isLoadingLocation
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(height: 16),
                            const Text('Memuat peta...'),
                          ],
                        ),
                      )
                    : currentLocation == null
                        ? const Center(child: Text('Lokasi tidak tersedia'))
                        : Stack(
                            children: [
                              GoogleMap(
                                onMapCreated: onMapCreated,
                                initialCameraPosition: CameraPosition(
                                  target: currentLocation!,
                                  zoom: 15,
                                ),
                                markers: markers,
                                myLocationEnabled: true,
                                myLocationButtonEnabled: false,
                                zoomControlsEnabled: false,
                                mapType: currentMapType,
                              ),
                              // Custom controls
                              Positioned(
                                right: 16,
                                bottom: 16,
                                child: Column(
                                  children: [
                                    FloatingActionButton.small(
                                      heroTag: 'locate',
                                      onPressed: () {
                                        if (currentLocation != null) {
                                          mapController?.animateCamera(
                                            CameraUpdate.newCameraPosition(
                                              CameraPosition(
                                                target: currentLocation!,
                                                zoom: 15,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      backgroundColor: Theme.of(context).primaryColor,
                                      child: const Icon(Icons.my_location),
                                    ),
                                    const SizedBox(height: 8),
                                    FloatingActionButton.small(
                                      heroTag: 'zoomIn',
                                      onPressed: () {
                                        mapController?.animateCamera(
                                          CameraUpdate.zoomIn(),
                                        );
                                      },
                                      backgroundColor: Theme.of(context).primaryColor,
                                      child: const Icon(Icons.add),
                                    ),
                                    const SizedBox(height: 8),
                                    FloatingActionButton.small(
                                      heroTag: 'zoomOut',
                                      onPressed: () {
                                        mapController?.animateCamera(
                                          CameraUpdate.zoomOut(),
                                        );
                                      },
                                      backgroundColor: Theme.of(context).primaryColor,
                                      child: const Icon(Icons.remove),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 