import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class TimeScreen extends StatefulWidget {
  const TimeScreen({super.key});
  @override
  _TimeScreenState createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> {
  String selectedZone = 'WIB';
  String convertedTime = '';
  Timer? timer;

  void convertTime() {
    // Get current UTC time
    DateTime utc = DateTime.now().toUtc();
    DateTime result;
    
    // Convert to selected timezone
    switch (selectedZone) {
      case 'WIB':
        result = utc.add(const Duration(hours: 7)); // UTC+7
        break;
      case 'WITA':
        result = utc.add(const Duration(hours: 8)); // UTC+8
        break;
      case 'WIT':
        result = utc.add(const Duration(hours: 9)); // UTC+9
        break;
      case 'London':
        result = utc.add(const Duration(hours: 1)); // UTC+1 (BST) or UTC+0 (GMT)
        break;
      default:
        result = utc.add(const Duration(hours: 7)); // Default to WIB
    }
    
    setState(() {
      convertedTime = DateFormat('HH:mm:ss').format(result);
    });
  }

  @override
  void initState() {
    super.initState();
    convertTime();
    // Update time every second
    timer = Timer.periodic(const Duration(seconds: 1), (_) => convertTime());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konversi Waktu')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedZone,
              items: ['WIB', 'WITA', 'WIT', 'London']
                  .map((zone) => DropdownMenuItem(value: zone, child: Text(zone)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedZone = val!;
                  convertTime();
                });
              },
            ),
            const SizedBox(height: 20),
            Text('Waktu: $convertedTime', 
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold
              )
            ),
          ],
        ),
      ),
    );
  }
}
