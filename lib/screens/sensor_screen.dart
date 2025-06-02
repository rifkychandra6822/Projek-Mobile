import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});
  @override
  _SensorScreenState createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  String sensorData = 'Menunggu data sensor...';

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((event) {
      setState(() {
        sensorData = "X: ${event.x.toStringAsFixed(2)} Y: ${event.y.toStringAsFixed(2)} Z: ${event.z.toStringAsFixed(2)}";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sensor')),
      body: Center(
        child: Text(sensorData, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}
