import 'package:flutter/material.dart';
import '../services/noticia_service.dart';

class NoticiaViewModel extends ChangeNotifier {
  List<Noticia> noticias = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> carregarNoticiasFinanceiras() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      noticias = await NoticiaService.fetchNoticiasFinanceiras();
      if (noticias.isEmpty) {
        errorMessage = 'Nenhuma notícia encontrada';
      }
    } catch (e) {
      errorMessage = 'Erro ao carregar notícias: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> carregarDicasInvestimento() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      noticias = await NoticiaService.fetchDicasInvestimento();
      if (noticias.isEmpty) {
        errorMessage = 'Nenhuma dica encontrada';
      }
    } catch (e) {
      errorMessage = 'Erro ao carregar dicas: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> carregarNoticiasPorTema(String tema) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      noticias = await NoticiaService.fetchNoticiasPorTema(tema);
      if (noticias.isEmpty) {
        errorMessage = 'Nenhuma notícia encontrada para: $tema';
      }
    } catch (e) {
      errorMessage = 'Erro ao carregar notícias: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
