import 'package:flutter/material.dart';
import '../models/gold_price.dart';
import '../services/gold_price_service.dart';

class GoldPriceScreen extends StatefulWidget {
  const GoldPriceScreen({Key? key}) : super(key: key);

  @override
  State<GoldPriceScreen> createState() => _GoldPriceScreenState();
}

class _GoldPriceScreenState extends State<GoldPriceScreen> {
  final GoldPriceService _service = GoldPriceService();
  List<GoldPrice> _goldPrices = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGoldPrices();
  }

  Future<void> _loadGoldPrices() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final prices = await _service.getGoldPrices();
      setState(() {
        _goldPrices = prices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harga Emas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGoldPrices,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      ElevatedButton(
                        onPressed: _loadGoldPrices,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _goldPrices.length,
                  itemBuilder: (context, index) {
                    final price = _goldPrices[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tipe: ${price.type.toUpperCase()}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Harga Beli: Rp ${price.buy.toStringAsFixed(0)}/${price.unit}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Harga Jual: Rp ${price.sell.toStringAsFixed(0)}/${price.unit}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 