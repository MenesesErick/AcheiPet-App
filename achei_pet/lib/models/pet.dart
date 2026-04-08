enum StatusPet { PERDIDO, ENCONTRADO }

class Pet {
  final String id;
  final String usuarioId; // FK (Foreign Key) - Quem postou o anúncio
  final String nome;
  final String? raca; 
  final String descricao;
  final String localizacao;
  final String imagemUrl;
  final StatusPet status;
  
  // Contato de quem perdeu (Pode ser o próprio usuário ou um amigo)
  final String nomeDono;
  final String telefoneContato; 

  const Pet({
    required this.id,
    required this.usuarioId, // Agora o Pet sabe a qual conta ele pertence
    required this.nome,
    this.raca, // Raça pode ser nula se a pessoa não souber
    required this.descricao,
    required this.localizacao,
    required this.imagemUrl,
    required this.status,
    required this.nomeDono,
    required this.telefoneContato,
  });
}