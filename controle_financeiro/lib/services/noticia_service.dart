import 'package:http/http.dart' as http;
import 'dart:convert';

class Noticia {
  final String titulo;
  final String descricao;
  final String? imagem;
  final String url;
  final DateTime dataPublicacao;
  final String fonte;

  Noticia({
    required this.titulo,
    required this.descricao,
    this.imagem,
    required this.url,
    required this.dataPublicacao,
    required this.fonte,
  });

  factory Noticia.fromJson(Map<String, dynamic> json) {
    return Noticia(
      titulo: json['title'] ?? 'Sem título',
      descricao: json['description'] ?? 'Sem descrição',
      imagem: json['urlToImage'],
      url: json['url'] ?? '',
      dataPublicacao: DateTime.parse(json['publishedAt'] ?? DateTime.now().toIso8601String()),
      fonte: json['source']['name'] ?? 'Desconhecida',
    );
  }
}

class NoticiaService {
  // Usar uma API pública para notícias financeiras
  // Você pode usar: NewsAPI, Alpha Vantage, IEX Cloud, etc.
  static const String baseUrl = 'https://newsapi.org/v2';
  static const String apiKey = 'sua_chave_api_aqui'; // Substitua pela sua chave

  // Buscar notícias sobre finanças
  static Future<List<Noticia>> fetchNoticiasFinanceiras() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/everything?q=finanças+investimento&sortBy=publishedAt&language=pt&apiKey=$apiKey',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> articles = data['articles'] ?? [];
        return articles
            .map((article) => Noticia.fromJson(article))
            .take(10)
            .toList();
      } else {
        throw Exception('Erro ao carregar notícias: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar notícias financeiras: $e');
      return [];
    }
  }

  // Buscar dicas de investimento
  static Future<List<Noticia>> fetchDicasInvestimento() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/everything?q=dicas+investimento+mercado&sortBy=publishedAt&language=pt&apiKey=$apiKey',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> articles = data['articles'] ?? [];
        return articles
            .map((article) => Noticia.fromJson(article))
            .take(10)
            .toList();
      } else {
        throw Exception('Erro ao carregar dicas: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar dicas de investimento: $e');
      return [];
    }
  }

  // Buscar notícias por tema específico
  static Future<List<Noticia>> fetchNoticiasPorTema(String tema) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/everything?q=$tema&sortBy=publishedAt&language=pt&apiKey=$apiKey',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> articles = data['articles'] ?? [];
        return articles
            .map((article) => Noticia.fromJson(article))
            .take(10)
            .toList();
      } else {
        throw Exception('Erro ao carregar notícias: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar notícias por tema: $e');
      return [];
    }
  }
}
