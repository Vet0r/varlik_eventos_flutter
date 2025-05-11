import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:varlik_eventos/models/usuario.dart';
import 'package:varlik_eventos/utils/auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:varlik_eventos/utils/consts.dart';

class UsuarioProvider with ChangeNotifier {
  Usuario? _usuario;
  Usuario? get usuario => _usuario;
  bool get isLoggedIn => _usuario != null;

  Future<void> loadUsuario() async {
    try {
      final token = await getToken();
      if (token != null) {
        final usuario = await fetchUsuario(token);
        if (usuario != null) {
          _usuario = usuario;
          //final prefs = await SharedPreferences.getInstance();
          //await prefs.setString('usuario', jsonEncode(_usuario!.toJson()));
          notifyListeners();
        } else {
          print('Token inválido ou usuário não encontrado.');
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _usuario = null;
    await prefs.remove('usuario');
    await saveToken('');
    notifyListeners();
  }

  Future<Usuario?> fetchUsuario(String token) async {
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
        final data = jsonDecode(response.body);
        _usuario = Usuario.fromJson(data['user']);
        return Usuario.fromJson(data['user']);
      } else {
        print('Erro ao validar token: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro ao conectar à API: $e');
      return null;
    }
  }
}
