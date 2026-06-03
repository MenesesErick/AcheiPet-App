class Notificacao {
  final String id;
  final String usuarioId;
  final String? petId;
  final String mensagem;
  final bool lida;
  final DateTime createdAt;

  Notificacao({
    required this.id,
    required this.usuarioId,
    this.petId,
    required this.mensagem,
    required this.lida,
    required this.createdAt,
  });

  factory Notificacao.fromJson(Map<String, dynamic> json) {
    return Notificacao(
      id: json['id'] as String,
      usuarioId: json['usuario_id'] as String,
      petId: json['pet_id'] as String?,
      mensagem: json['mensagem'] as String,
      lida: json['lida'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'pet_id': petId,
      'mensagem': mensagem,
      'lida': lida,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
