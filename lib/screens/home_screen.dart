import 'package:flutter/material.dart';
import '../services/gold_price_api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GoldPriceApiService apiService = GoldPriceApiService();
  Timer? _debounceTimer;

  // Calculator state
  String priceType = 'buy';
  num? selectedPrice;
  final TextEditingController quantityController = TextEditingController();
  final List<int> quantities = [1, 2, 3, 5, 10, 25, 50, 100];
  int? selectedQuantity;
  num? totalPrice;

  // Currency conversion
  String targetCurrency = 'IDR';
  final List<String> currencies = ['IDR', 'USD', 'EUR', 'SGD', 'MYR'];
  num exchangeRate = 1.0;
  num? convertedTotalPrice;

  @override
  void initState() {
    super.initState();
    quantityController.addListener(_onQuantityChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    quantityController.dispose();
    super.dispose();
  }

  void _onQuantityChanged() {
    if (quantityController.text.isEmpty) {
      setState(() {
        totalPrice = null;
        convertedTotalPrice = null;
      });
      return;
    }

    // Cancel previous timer if it exists
    _debounceTimer?.cancel();
    // Start a new timer
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return; // Check if widget is still mounted
      calculateTotal();
    });
  }

  void calculateTotal() {
    if (selectedPrice == null) return;

    num? quantity;
    if (selectedQuantity != null) {
      quantity = selectedQuantity!.toDouble();
    } else {
      quantity = num.tryParse(quantityController.text);
    }

    setState(() {
      if (quantity != null && quantity > 0) {
        totalPrice = selectedPrice! * quantity;
        if (targetCurrency != 'IDR') {
          fetchExchangeRate();
        } else {
          calculateConvertedPrice();
        }
      } else {
        totalPrice = null;
        convertedTotalPrice = null;
      }
    });
  }

  void onPriceTypeChanged(String? val) {
    if (val == null) return;
    setState(() {
      priceType = val;
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
          exchangeRate = data['rates'][targetCurrency] ?? 1.0;
          calculateConvertedPrice();
        });
      }
    } catch (e) {
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

  void onCurrencyChanged(String? newCurrency) {
    if (newCurrency == null) return;
    setState(() {
      targetCurrency = newCurrency;
      fetchExchangeRate();
    });
  }

  // Helper function to calculate price statistics
  Map<String, num?> calculateStats(List<dynamic> prices) {
    List<num> buyPrices = [];
    List<num> sellPrices = [];

    for (var item in prices) {
      if (item['buy'] != null) buyPrices.add(num.tryParse(item['buy'].toString()) ?? 0);
      if (item['sell'] != null) sellPrices.add(num.tryParse(item['sell'].toString()) ?? 0);
    }

    num? minBuy = buyPrices.isNotEmpty ? buyPrices.reduce((a, b) => a < b ? a : b) : null;
    num? maxBuy = buyPrices.isNotEmpty ? buyPrices.reduce((a, b) => a > b ? a : b) : null;
    num? minSell = sellPrices.isNotEmpty ? sellPrices.reduce((a, b) => a < b ? a : b) : null;
    num? maxSell = sellPrices.isNotEmpty ? sellPrices.reduce((a, b) => a > b ? a : b) : null;

    return {
      'minBuy': minBuy,
      'maxBuy': maxBuy,
      'minSell': minSell,
      'maxSell': maxSell,
    };
  }

  Color getCardColor(String name) {
    if (name.toLowerCase().contains('emas')) return Color(0xFFFFF8DC);  // Cornsilk
    if (name.toLowerCase().contains('perak')) return Color(0xFFF5F5F5); // White smoke
    if (name.toLowerCase().contains('platina')) return Color(0xFFE8E8E8); // Light gray
    return Colors.white;
  }

  Widget buildStatsCard(String title, num? value) {
    return Expanded(
      child: Card(
        color: const Color(0xFFFFF8DC),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4513),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                value != null 
                  ? 'Rp ${value.toStringAsFixed(0)}'
                  : '-',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCalculator(Map<String, dynamic> goldPrice) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFFFFF8DC),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: Colors.amber[800], size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Kalkulator Emas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B4513),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Harga Beli'),
                    value: 'buy',
                    groupValue: priceType,
                    activeColor: Colors.amber[800],
                    onChanged: (val) {
                      onPriceTypeChanged(val);
                      selectedPrice = num.tryParse(goldPrice['buy'].toString());
                      calculateTotal();
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Harga Jual'),
                    value: 'sell',
                    groupValue: priceType,
                    activeColor: Colors.amber[800],
                    onChanged: (val) {
                      onPriceTypeChanged(val);
                      selectedPrice = num.tryParse(goldPrice['sell'].toString());
                      calculateTotal();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Pilih kuantitas gram:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8B4513),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: quantities.map((qty) {
                return ChoiceChip(
                  label: Text(
                    '$qty gram',
                    style: TextStyle(
                      color: selectedQuantity == qty ? Colors.white : Colors.amber[800],
                    ),
                  ),
                  selected: selectedQuantity == qty,
                  selectedColor: Colors.amber[800],
                  backgroundColor: const Color(0xFFFFF8DC),
                  onSelected: (_) => onChipSelected(qty),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Atau masukkan kuantitas gram',
                labelStyle: TextStyle(color: Colors.amber[800]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.amber[800]!),
                ),
                prefixIcon: Icon(Icons.scale, color: Colors.amber[800]),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: targetCurrency,
              decoration: InputDecoration(
                labelText: 'Pilih mata uang',
                labelStyle: TextStyle(color: Colors.amber[800]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.amber[800]!),
                ),
                prefixIcon: Icon(Icons.currency_exchange, color: Colors.amber[800]),
              ),
              items: currencies.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: onCurrencyChanged,
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD4AF37)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Total Harga (IDR)',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.amber[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${totalPrice?.toStringAsFixed(0) ?? '-'}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                    if (targetCurrency != 'IDR' && convertedTotalPrice != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Total Harga ($targetCurrency)',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.amber[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${convertedTotalPrice!.toStringAsFixed(2)} $targetCurrency',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(BuildContext context, String label, IconData icon, String route) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, route),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.amber[800],
        elevation: 4,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(color: Colors.amber[800]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'LogamKu',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.amber[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: apiService.fetchGoldPrices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.amber[800],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[700]),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat data: ${snapshot.error}',
                    style: TextStyle(color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Data tidak tersedia',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final prices = snapshot.data!;
          final stats = calculateStats(prices);
          
          if (selectedPrice == null && prices.isNotEmpty) {
            selectedPrice = num.tryParse(prices[0][priceType].toString());
          }

          return RefreshIndicator(
            color: Colors.amber[800],
            onRefresh: () async {
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header section with icon
                Icon(
                  Icons.diamond,
                  size: 64,
                  color: Colors.amber[800],
                ),
                const SizedBox(height: 8),
                Text(
                  'Harga Logam Mulia Hari Ini',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Stats cards
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        buildStatsCard('Harga Beli\nTerendah', stats['minBuy']),
                        buildStatsCard('Harga Jual\nTerendah', stats['minSell']),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Price list cards
                ...prices.map((item) {
                  return Card(
                    color: const Color(0xFFFFF8DC),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.diamond,
                                color: Colors.amber[800],
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item['name'] ?? 'EMAS ANTAM',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Harga Beli',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF8B4513),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['buy'] != null
                                          ? 'Rp ${item['buy'].toString()}'
                                          : '-',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFFD4AF37),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 40,
                                width: 1,
                                color: Colors.amber[100],
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Harga Jual',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF8B4513),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['sell'] != null
                                          ? 'Rp ${item['sell'].toString()}'
                                          : '-',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFFD4AF37),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 24),

                // Calculator
                buildCalculator(prices[0]),

                const SizedBox(height: 24),

                // Tools section
                Text(
                  'Tools',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildToolButton(
                        context,
                        'Konversi\nMata Uang',
                        Icons.currency_exchange,
                        '/currency',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildToolButton(
                        context,
                        'Konversi\nWaktu',
                        Icons.access_time,
                        '/time',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildToolButton(
                        context,
                        'Lokasi\nToko',
                        Icons.location_on,
                        '/lbs',
                      ),
                    ),
                  ],
                ),

                // Footer section
                const SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.amber[100]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    'Mobile Programming Project by Rifky Chandra Nugraha\nUPN "Veteran" Yogyakarta.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
