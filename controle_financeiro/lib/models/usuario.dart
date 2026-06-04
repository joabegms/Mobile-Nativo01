class Usuario {
  int? id;
  String nome;
  String email;
  String senha;
  DateTime dataCadastro;

  Usuario({
    this.id,
    required this.nome,
    required this.email,
    required this.senha,
    DateTime? dataCadastro,
  }) : dataCadastro = dataCadastro ?? DateTime.now();

  // Converter Usuario para Map (para salvar no BD)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'data_cadastro': dataCadastro.toIso8601String(),
    };
  }

  // Criar Usuario a partir de Map (quando vem do BD)
  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      senha: map['senha'] ?? '',
      dataCadastro: map['data_cadastro'] != null 
          ? DateTime.parse(map['data_cadastro']) 
          : DateTime.now(),
    );
  }

  @override
  String toString() => 'Usuario(id: $id, nome: $nome, email: $email)';
}
