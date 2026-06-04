import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://api.example.com';

  // Exemplo de consumo de API para notícias financeiras
  Future<List<dynamic>> fetchFinancialNews() async {
    try {
      // Substituir por uma API real como NewsAPI ou similar
      final response = await http.get(
        Uri.parse('$baseUrl/news/financial'),
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['articles'] ?? [];
      } else {
        throw Exception('Erro ao carregar notícias');
      }
    } catch (e) {
      print('Erro ao buscar notícias: $e');
      return [];
    }
  }

  // Método para validar conexão com internet
  Future<bool> checkInternetConnection() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.google.com'),
      ).timeout(
        const Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
