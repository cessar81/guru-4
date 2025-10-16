import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // URL base del backend Flask
  static const String baseUrl = 'https://flaskapiexample-production.up.railway.app';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Inicia sesión con el backend
  /// Retorna el token si el login fue exitoso, o null si falló.
  Future<String?> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/users/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      // Si el login fue exitoso
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];

        // Guardar token y usuario localmente
        await _storage.write(key: 'jwt', value: token);
        await _storage.write(key: 'username', value: username);

        return token;
      } else {
        print('Error ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  /// Registra un nuevo usuario
  /// Retorna true si el registro fue exitoso (HTTP 201).
  Future<bool> register(String username, String password) async {
    final url = Uri.parse('$baseUrl/users/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 201) {
        await _storage.write(key: 'username', value: username);
        return true;
      } else {
        print('Error ${response.statusCode}: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error en register: $e');
      return false;
    }
  }

  /// Obtiene el token guardado
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt');
  }

  /// Obtiene el nombre de usuario guardado
  Future<String?> getUsername() async {
    return await _storage.read(key: 'username');
  }

  /// Cierra la sesión eliminando los datos guardados
  Future<void> logout() async {
    await _storage.delete(key: 'jwt');
    await _storage.delete(key: 'username');
  }
}
