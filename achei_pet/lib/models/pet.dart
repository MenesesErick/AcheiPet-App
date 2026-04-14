import 'package:isar/isar.dart';

part 'pet.g.dart';

enum StatusPet { PERDIDO, ENCONTRADO }

@collection
class Pet {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  String id;
  String usuarioId;
  String nome;
  String? raca;
  String descricao;
  String localizacao;
  String imagemUrl;
  @Enumerated(EnumType.name)
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
}
