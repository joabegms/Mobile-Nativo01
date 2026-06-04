import 'package:intl/intl.dart';

class Formatters {
  // Formatar moeda
  static String formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatter.format(value);
  }

  // Formatar data
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy', 'pt_BR');
    return formatter.format(date);
  }

  // Formatar data e hora
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
    return formatter.format(dateTime);
  }

  // Formatar apenas hora
  static String formatTime(DateTime time) {
    final formatter = DateFormat('HH:mm', 'pt_BR');
    return formatter.format(time);
  }

  // Formatar apenas mês e ano
  static String formatMonthYear(DateTime date) {
    final formatter = DateFormat('MMMM yyyy', 'pt_BR');
    return formatter.format(date);
  }
}
