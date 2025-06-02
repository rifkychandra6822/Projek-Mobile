import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class ApiService {
  Future<List<dynamic>> fetchAnekaLogamPrices() async {
    final response = await http.get(Uri.parse(anekaLogamApiUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      print('RESP API DATA: $json'); 
      return json['data'] ?? [];
    } else {
      throw Exception('Gagal mengambil data harga logam');
    }
  }
}
