enum StatusPet { PERDIDO, ENCONTRADO }

class Pet {
  String id;
  String usuarioId;
  String nome;
  String? raca;
  String descricao;
  String localizacao;
  String imagemUrl;
  StatusPet status;
  String nomeDono;
  String telefoneContato;

  Pet({
    required this.id,
    required this.usuarioId,
    required this.nome,
    this.raca,
    required this.descricao,
    required this.localizacao,
    required this.imagemUrl,
    required this.status,
    required this.nomeDono,
    required this.telefoneContato,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      usuarioId: json['usuario_id'] as String,
      nome: json['nome'] as String,
      raca: json['raca'] as String?,
      descricao: json['descricao'] as String,
      localizacao: json['localizacao'] as String,
      imagemUrl: json['imagem_url'] as String,
      status: (json['status'] as String) == 'ENCONTRADO'
          ? StatusPet.ENCONTRADO
          : StatusPet.PERDIDO,
      nomeDono: json['nome_dono'] as String,
      telefoneContato: json['telefone_contato'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'nome': nome,
      'raca': raca,
      'descricao': descricao,
      'localizacao': localizacao,
      'imagem_url': imagemUrl,
      'status': status.name, // 'PERDIDO' ou 'ENCONTRADO'
      'nome_dono': nomeDono,
      'telefone_contato': telefoneContato,
    };
  }
}
