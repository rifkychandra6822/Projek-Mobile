import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});
  @override
  _CurrencyScreenState createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final TextEditingController amountController = TextEditingController();
  String fromCurrency = 'USD';
  String toCurrency = 'IDR';
  double convertedResult = 0.0;

  void convertCurrency() async {
    final response = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/$fromCurrency'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      double rate = data['rates'][toCurrency];
      setState(() {
        double amount = double.tryParse(amountController.text) ?? 0;
        convertedResult = amount * rate;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengambil data kurs')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Konversi Mata Uang')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jumlah'),
            ),
            DropdownButton<String>(
              value: fromCurrency,
              items: ['USD', 'IDR', 'EUR'].map((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
              onChanged: (val) {
                setState(() {
                  fromCurrency = val!;
                });
              },
            ),
            DropdownButton<String>(
              value: toCurrency,
              items: ['USD', 'IDR', 'EUR'].map((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
              onChanged: (val) {
                setState(() {
                  toCurrency = val!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: convertCurrency, child: const Text('Konversi')),
            const SizedBox(height: 20),
            Text('Hasil: $convertedResult', style: const TextStyle(fontSize: 24)),
          ]),
        ));
  }
}
