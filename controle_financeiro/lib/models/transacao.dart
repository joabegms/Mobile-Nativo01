class Transacao {
  int? id;
  int usuarioId;
  String titulo;
  double valor;
  String tipo; // 'receita' ou 'despesa'
  String? categoria;
  DateTime data;
  String? descricao;

  Transacao({
    this.id,
    required this.usuarioId,
    required this.titulo,
    required this.valor,
    required this.tipo,
    this.categoria,
    DateTime? data,
    this.descricao,
  }) : data = data ?? DateTime.now();

  // Converter Transacao para Map (para salvar no BD)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'titulo': titulo,
      'valor': valor,
      'tipo': tipo,
      'categoria': categoria,
      'data': data.toIso8601String(),
      'descricao': descricao,
    };
  }

  // Criar Transacao a partir de Map (quando vem do BD)
  factory Transacao.fromMap(Map<String, dynamic> map) {
    return Transacao(
      id: map['id'],
      usuarioId: map['usuario_id'] ?? 0,
      titulo: map['titulo'] ?? '',
      valor: (map['valor'] ?? 0.0).toDouble(),
      tipo: map['tipo'] ?? 'despesa',
      categoria: map['categoria'],
      data: map['data'] != null ? DateTime.parse(map['data']) : DateTime.now(),
      descricao: map['descricao'],
    );
  }

  // Copiar com mudanças (útil para edição)
  Transacao copyWith({
    int? id,
    int? usuarioId,
    String? titulo,
    double? valor,
    String? tipo,
    String? categoria,
    DateTime? data,
    String? descricao,
  }) {
    return Transacao(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      titulo: titulo ?? this.titulo,
      valor: valor ?? this.valor,
      tipo: tipo ?? this.tipo,
      categoria: categoria ?? this.categoria,
      data: data ?? this.data,
      descricao: descricao ?? this.descricao,
    );
  }

  @override
  String toString() => 'Transacao(id: $id, titulo: $titulo, valor: $valor, tipo: $tipo)';
}
