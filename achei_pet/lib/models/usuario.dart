import 'package:isar/isar.dart';

part 'usuario.g.dart';

@collection
class Usuario {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  String id;
  String nome;

  @Index(unique: true)
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
}