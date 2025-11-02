import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ControlCamera {
  static String robotId = dotenv.env['ID_ROBOT'] ?? "1";

  static Future<void> callCameraAPI({required String action, required String IDDeliveryRecord}) async {
    final String apiUrl =
        'https://hricameratest.onrender.com/controlCamera/?IDRobot=$robotId&action=$action&IDDeliveryRecord=$IDDeliveryRecord';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        print('✅ API call successful: ${response.body}');
      } else {
        print(
            '⚠️ API call failed with status: ${response.statusCode}, body: ${response.body}');
      }
    } catch (e) {
      print('❌ API call error: $e');
    }
  }
}
