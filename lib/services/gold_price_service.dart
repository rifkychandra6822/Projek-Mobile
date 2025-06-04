import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gold_price.dart';

class GoldPriceService {
  static const String baseUrl = 'https://logam-mulia-api.vercel.app/prices/hargaemas-org';

  Future<List<GoldPrice>> getGoldPrices() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((item) => GoldPrice.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load gold prices');
      }
    } catch (e) {
      throw Exception('Error fetching gold prices: $e');
    }
  }
} 