enum StatusPet { PERDIDO, ENCONTRADO }

class Pet {
  final String id;
  final String nome;
  final String descricao;
  final String localizacao;
  final String imagemUrl;
  final StatusPet status;

  const Pet({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.localizacao,
    required this.imagemUrl,
    required this.status,
  });
}
