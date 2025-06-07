import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeScreen extends StatefulWidget {
  const TimeScreen({super.key});

  @override
  State<TimeScreen> createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> {
  DateTime _selectedTime = DateTime.now();
  final List<Map<String, dynamic>> _timeZones = [
    {'name': 'WIB (Jakarta)', 'offset': 7},
    {'name': 'WITA (Makassar)', 'offset': 8},
    {'name': 'WIT (Jayapura)', 'offset': 9},
    {'name': 'London (GMT)', 'offset': 0},
    {'name': 'New York (EST)', 'offset': -5},
    {'name': 'Los Angeles (PST)', 'offset': -8},
    {'name': 'Tokyo (JST)', 'offset': 9},
    {'name': 'Seoul (KST)', 'offset': 9},
  ];

  String _formatTime(DateTime time, int offset) {
    final utc = time.toUtc();
    final targetTime = utc.add(Duration(hours: offset));
    return DateFormat('HH:mm:ss').format(targetTime);
  }

  String _formatDate(DateTime time, int offset) {
    final utc = time.toUtc();
    final targetTime = utc.add(Duration(hours: offset));
    return DateFormat('dd MMMM yyyy').format(targetTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi Waktu'),
        backgroundColor: Colors.amber[800],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Current Time Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: const Color(0xFFFFF8DC),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Waktu Saat Ini (WIB)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B4513),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(_selectedTime, 7),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                      Text(
                        _formatDate(_selectedTime, 7),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Time Zones Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _timeZones.length,
                itemBuilder: (context, index) {
                  final zone = _timeZones[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: const Color(0xFFFFF8DC),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            zone['name'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B4513),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatTime(_selectedTime, zone['offset']),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                          Text(
                            _formatDate(_selectedTime, zone['offset']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _selectedTime = DateTime.now();
          });
        },
        backgroundColor: Colors.amber[800],
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
