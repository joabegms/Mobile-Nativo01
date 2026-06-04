class Validators {
  // Validar email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-mail obrigatório';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'E-mail inválido';
    }
    return null;
  }

  // Validar senha
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha obrigatória';
    }
    if (value.length < 6) {
      return 'Senha deve ter no mínimo 6 caracteres';
    }
    return null;
  }

  // Validar campo obrigatório
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  // Validar valor numérico
  static String? validateNumericValue(String? value) {
    if (value == null || value.isEmpty) {
      return 'Valor obrigatório';
    }
    final parsed = double.tryParse(value);
    if (parsed == null || parsed <= 0) {
      return 'Insira um valor numérico válido e maior que zero';
    }
    return null;
  }

  // Validar nome
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome obrigatório';
    }
    if (value.length < 3) {
      return 'Nome deve ter no mínimo 3 caracteres';
    }
    return null;
  }
}
