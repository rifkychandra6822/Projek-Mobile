import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoldCalculatorScreen extends StatefulWidget {
  const GoldCalculatorScreen({super.key});
  @override
  State<GoldCalculatorScreen> createState() => _GoldCalculatorScreenState();
}

class _GoldCalculatorScreenState extends State<GoldCalculatorScreen> {
  final ApiService apiService = ApiService();

  List<dynamic>? prices;
  bool isLoading = true;
  String error = '';

  String priceType = 'buy'; // 'buy' atau 'sell'
  double? pricePerGram;

  // Currency conversion
  String targetCurrency = 'IDR';
  final List<String> currencies = ['IDR', 'USD', 'EUR', 'SGD', 'MYR'];
  double exchangeRate = 1.0;

  // Pilihan kuantitas predefined
  final List<int> quantities = [1, 2, 3, 5, 10, 25, 50, 100];
  int? selectedQuantity; // pilihan dari chip, nullable

  // Controller untuk input manual kuantitas
  final TextEditingController quantityController = TextEditingController();

  double? totalPrice;
  double? convertedTotalPrice;

  @override
  void initState() {
    super.initState();
    fetchPrices();
    quantityController.addListener(onQuantityChanged);
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  void onQuantityChanged() {
    // Jika user input manual, hapus pilihan chip
    if (quantityController.text.isNotEmpty) {
      setState(() {
        selectedQuantity = null;
        calculateTotal();
      });
    }
  }

  Future<void> fetchExchangeRate() async {
    if (targetCurrency == 'IDR') {
      setState(() {
        exchangeRate = 1.0;
        calculateConvertedPrice();
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/IDR'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          exchangeRate = data['rates'][targetCurrency];
          calculateConvertedPrice();
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data kurs: $e')),
      );
    }
  }

  void calculateConvertedPrice() {
    if (totalPrice != null && exchangeRate != 1.0) {
      setState(() {
        convertedTotalPrice = totalPrice! * exchangeRate;
      });
    } else {
      convertedTotalPrice = totalPrice;
    }
  }

  Future<void> fetchPrices() async {
    try {
      final data = await apiService.fetchAnekaLogamPrices();

      if (data.isNotEmpty) {
        pricePerGram = double.tryParse(data[0][priceType].toString());
      } else {
        pricePerGram = null;
      }

      setState(() {
        prices = data;
        isLoading = false;
        calculateTotal();
      });
    } catch (e) {
      setState(() {
        error = 'Gagal memuat harga emas: $e';
        isLoading = false;
      });
    }
  }

  void calculateTotal() {
    double? quantity;

    if (selectedQuantity != null) {
      quantity = selectedQuantity!.toDouble();
    } else {
      quantity = double.tryParse(quantityController.text);
    }

    if (pricePerGram == null || quantity == null || quantity <= 0) {
      totalPrice = null;
      convertedTotalPrice = null;
    } else {
      totalPrice = pricePerGram! * quantity;
      calculateConvertedPrice();
    }
  }

  void onPriceTypeChanged(String? val) {
    if (val == null) return;
    setState(() {
      priceType = val;
      if (prices != null && prices!.isNotEmpty) {
        pricePerGram = double.tryParse(prices![0][priceType].toString());
      } else {
        pricePerGram = null;
      }
      calculateTotal();
    });
  }

  void onChipSelected(int qty) {
    setState(() {
      selectedQuantity = qty;
      quantityController.text = '';
      calculateTotal();
    });
  }

  void onCurrencyChanged(String? newCurrency) {
    if (newCurrency == null) return;
    setState(() {
      targetCurrency = newCurrency;
      fetchExchangeRate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulasi Kalkulator Emas')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error.isNotEmpty
                ? Center(child: Text(error))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (prices != null && prices!.isNotEmpty) ...[
                          Text(
                            'Logam: ${prices![0]['type'] ?? 'Tidak diketahui'}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            prices![0]['info'] ?? '',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Text(
                          'Pilih tipe harga:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Harga Beli'),
                                value: 'buy',
                                groupValue: priceType,
                                onChanged: onPriceTypeChanged,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Harga Jual'),
                                value: 'sell',
                                groupValue: priceType,
                                onChanged: onPriceTypeChanged,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Harga per gram: Rp ${pricePerGram?.toStringAsFixed(0) ?? '-'}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          'Pilih kuantitas gram:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),

                        Wrap(
                          spacing: 10,
                          children: quantities.map((qty) {
                            return ChoiceChip(
                              label: Text('$qty gram'),
                              selected: selectedQuantity == qty,
                              selectedColor: Colors.amber.shade300,
                              onSelected: (_) => onChipSelected(qty),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),
                        Text(
                          'Atau masukkan kuantitas gram:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),

                        TextField(
                          controller: quantityController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Kuantitas gram',
                            border: OutlineInputBorder(),
                            hintText: 'Masukkan kuantitas',
                          ),
                        ),

                        const SizedBox(height: 24),
                        Text(
                          'Pilih mata uang:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: targetCurrency,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          items: currencies.map((currency) {
                            return DropdownMenuItem(
                              value: currency,
                              child: Text(currency),
                            );
                          }).toList(),
                          onChanged: onCurrencyChanged,
                        ),

                        const SizedBox(height: 32),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Total Harga (IDR):\nRp ${totalPrice?.toStringAsFixed(0) ?? '-'}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              if (targetCurrency != 'IDR' && convertedTotalPrice != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Total Harga ($targetCurrency):\n${convertedTotalPrice!.toStringAsFixed(2)} $targetCurrency',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
