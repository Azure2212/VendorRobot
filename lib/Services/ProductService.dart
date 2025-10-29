import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/products.dart';

class ProductService {
  final String baseUrl = dotenv.env['BE_URL'] ?? '';
  final String idRobot = dotenv.env['ID_ROBOT'] ?? '';
  Future<List<Product>> fetchProducts() async {
    if (baseUrl.isEmpty) throw Exception('BE_URL not set');

    final response = await http.get(Uri.parse('$baseUrl/products/$idRobot'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
