class Usuario {
  final String id;
  final String nome;
  final String email;
  final String telefonePessoal;
  final String? fotoUrl;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefonePessoal,
    this.fotoUrl,
  });
}