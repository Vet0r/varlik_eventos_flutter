import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:varlik_eventos/utils/consts.dart';

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}

Future<bool> validateToken(String token) async {
  final url = Uri.parse('$baseUrl/api/v1/validate-token');

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Erro no login: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Erro ao conectar à API: $e');
    return false;
  }
}
