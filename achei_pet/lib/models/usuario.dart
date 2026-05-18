class Usuario {
  String id;
  String nome;
  String email;
  String telefonePessoal;
  String? fotoUrl;
  String? senha;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefonePessoal,
    this.fotoUrl,
    this.senha,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      nome: json['nome'] as String,
      email: json['email'] as String,
      telefonePessoal: json['telefone_pessoal'] as String,
      fotoUrl: json['foto_url'] as String?,
      senha: json['senha'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone_pessoal': telefonePessoal,
      'foto_url': fotoUrl,
    };
  }
}