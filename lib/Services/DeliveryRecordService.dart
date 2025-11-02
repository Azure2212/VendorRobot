import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:untitled3/models/DeliveryRecord.dart';
import '../models/products.dart';

class DeliveryRecordService {
  static String baseUrl = dotenv.env['BE_URL'] ?? '';
  static String idRobot = dotenv.env['ID_ROBOT'] ?? '';

  static Future<List<DeliveryRecord>> getAllRecordByRobotID() async {
    if (baseUrl.isEmpty) throw Exception('BE_URL not set');

    final response = await http.get(Uri.parse('$baseUrl/deliveryRecord/$idRobot'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => DeliveryRecord.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load DeliveryRecord');
    }
  }
}
