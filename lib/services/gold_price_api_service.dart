import 'package:http/http.dart' as http;
import 'dart:convert';

class GoldPriceApiService {
  final String goldPriceApiUrl = 'https://logam-mulia-api.vercel.app/prices/anekalogam';

  Future<List<dynamic>> fetchGoldPrices() async {
    final response = await http.get(Uri.parse(goldPriceApiUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      print('RESP GOLD API DATA: $json');
      return json['data'] ?? [];
    } else {
      throw Exception('Gagal mengambil data harga emas');
    }
  }
}
