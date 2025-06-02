import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();

  // Calculator state
  String priceType = 'buy';
  double? selectedPrice;
  final TextEditingController quantityController = TextEditingController();
  final List<int> quantities = [1, 2, 3, 5, 10, 25, 50, 100];
  int? selectedQuantity;
  double? totalPrice;

  // Currency conversion
  String targetCurrency = 'IDR';
  final List<String> currencies = ['IDR', 'USD', 'EUR', 'SGD', 'MYR'];
  double exchangeRate = 1.0;
  double? convertedTotalPrice;

  @override
  void initState() {
    super.initState();
    quantityController.addListener(calculateTotal);
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  void calculateTotal() {
    if (selectedPrice == null) return;

    double? quantity;
    if (selectedQuantity != null) {
      quantity = selectedQuantity!.toDouble();
    } else {
      quantity = double.tryParse(quantityController.text);
    }

    setState(() {
      if (quantity != null && quantity > 0) {
        totalPrice = selectedPrice! * quantity;
        calculateConvertedPrice();
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
          exchangeRate = data['rates'][targetCurrency];
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
  Map<String, double?> calculateStats(List<dynamic> prices) {
    List<double> buyPrices = [];
    List<double> sellPrices = [];

    for (var item in prices) {
      if (item['buy'] != null) buyPrices.add(double.tryParse(item['buy'].toString()) ?? 0);
      if (item['sell'] != null) sellPrices.add(double.tryParse(item['sell'].toString()) ?? 0);
    }

    double? minBuy = buyPrices.isNotEmpty ? buyPrices.reduce((a, b) => a < b ? a : b) : null;
    double? maxBuy = buyPrices.isNotEmpty ? buyPrices.reduce((a, b) => a > b ? a : b) : null;
    double? minSell = sellPrices.isNotEmpty ? sellPrices.reduce((a, b) => a < b ? a : b) : null;
    double? maxSell = sellPrices.isNotEmpty ? sellPrices.reduce((a, b) => a > b ? a : b) : null;

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

  Widget buildStatsCard(String title, double? value) {
    return Expanded(
      child: Card(
        color: Color(0xFFFFF8DC),
        elevation: 4,
        margin: const EdgeInsets.all(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4513), // Saddle brown
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
                  color: Color(0xFFD4AF37), // Gold
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kalkulator Emas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B4513),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Harga Beli'),
                    value: 'buy',
                    groupValue: priceType,
                    onChanged: (val) {
                      onPriceTypeChanged(val);
                      selectedPrice = double.tryParse(goldPrice['buy'].toString());
                      calculateTotal();
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Harga Jual'),
                    value: 'sell',
                    groupValue: priceType,
                    onChanged: (val) {
                      onPriceTypeChanged(val);
                      selectedPrice = double.tryParse(goldPrice['sell'].toString());
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
                  label: Text('$qty gram'),
                  selected: selectedQuantity == qty,
                  selectedColor: Colors.amber.shade300,
                  onSelected: (_) => onChipSelected(qty),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Atau masukkan kuantitas gram',
                border: OutlineInputBorder(),
                hintText: 'Masukkan kuantitas',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: targetCurrency,
              decoration: const InputDecoration(
                labelText: 'Pilih mata uang',
                border: OutlineInputBorder(),
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
    );
  }

  Widget _buildToolButton(BuildContext context, String label, IconData icon, String route) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, route),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFFD4AF37),
        elevation: 2,
        side: BorderSide(color: Color(0xFFD4AF37)),
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
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
          'Toko Emas Mulia',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: apiService.fetchAnekaLogamPrices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(
              color: Color(0xFFD4AF37),
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text(
              'Gagal memuat data: ${snapshot.error}',
              style: TextStyle(color: Colors.red[700]),
            ));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Data tidak tersedia'));
          }

          final prices = snapshot.data!;
          final stats = calculateStats(prices);
          
          if (selectedPrice == null && prices.isNotEmpty) {
            selectedPrice = double.tryParse(prices[0][priceType].toString());
          }

          return RefreshIndicator(
            color: Color(0xFFD4AF37),
            onRefresh: () async {
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // Header section with icon
                Center(
                  child: Icon(
                    Icons.diamond,
                    size: 48,
                    color: Color(0xFFD4AF37),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Harga Logam Mulia Hari Ini',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B4513),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Stats cards
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  final color = getCardColor(item['name'] ?? '');
                  return Card(
                    color: color,
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.diamond,
                                color: Color(0xFFD4AF37),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item['name'] ?? 'EMAS ANTAM',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8B4513),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                            ],
                          ),
                          if (item['date'] != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Update: ${item['date']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 24),

                // Calculator section
                if (prices.isNotEmpty) buildCalculator(prices[0]),

                const SizedBox(height: 24),

                // Tools section
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alat Bantu',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.1,
                          children: [
                            _buildToolButton(
                              context,
                              'Konversi\nMata Uang',
                              Icons.currency_exchange,
                              '/currency',
                            ),
                            _buildToolButton(
                              context,
                              'Konversi\nWaktu',
                              Icons.access_time,
                              '/time',
                            ),
                            _buildToolButton(
                              context,
                              'LBS\nTracker',
                              Icons.location_on,
                              '/lbs',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
