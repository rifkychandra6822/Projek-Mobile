import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String locationMessage = "Mencari lokasi...";

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  void getLocation() async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() {
          locationMessage = "Layanan lokasi tidak aktif";
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
        });
        return;
      }
    }

    final locData = await location.getLocation();
    setState(() {
      locationMessage = "Latitude: ${locData.latitude}, Longitude: ${locData.longitude}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LBS Tracker')),
      body: Center(
        child: Text(locationMessage, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
