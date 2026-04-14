import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:achei_pet/models/pet.dart';
import 'package:achei_pet/models/usuario.dart';

class IsarService {
  static late Isar _db;

  static Isar get db => _db;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _db = await Isar.open(
      [PetSchema, UsuarioSchema],
      directory: dir.path,
      inspector: kDebugMode,
    );
    await _seedSeVazio();
    await _logStatus();
  }

  static Future<void> _logStatus() async {
    final totalPets = await _db.pets.count();
    final usuarios = await _db.usuarios.where().findAll();
    print('[IsarService] Banco iniciado — Pets: $totalPets | Usuários: ${usuarios.length}');
    print('[IsarService] Arquivo em: ${_db.directory}');
    for (final u in usuarios) {
      print('  → id: ${u.id} | nome: ${u.nome} | email: ${u.email}');
    }
  }

  static Future<void> _seedSeVazio() async {
    final totalUsuarios = await _db.usuarios.count();
    if (totalUsuarios > 0) return;

    await _db.writeTxn(() async {
      await _db.usuarios.putAll([
        Usuario(
          id: 'user_demo_1',
          nome: 'Erick Meneses',
          email: 'erick@unitins.br',
          telefonePessoal: '(63) 98888-7777',
          fotoUrl: 'assets/imagens/gatoro.jpg',
        ),
        Usuario(
          id: 'user_demo_2',
          nome: 'Hugo Valuar',
          email: 'hugo@unitins.br',
          telefonePessoal: '(63) 99999-5555',
        ),
      ]);

      await _db.pets.putAll([
        Pet(
          id: '1',
          usuarioId: 'user_demo_1',
          nome: 'Mugiwara No Dog',
          descricao: 'Está sempre com um chapéu de palha e quer ser rei',
          localizacao: 'Próx. à Praça dos Girassóis',
          imagemUrl: 'assets/imagens/mugiwara_no_dog.jpg',
          status: StatusPet.ENCONTRADO,
          raca: 'King of Pirates',
          nomeDono: 'Monkey D. Dragon',
          telefoneContato: '(63) 99999-1111',
        ),
        Pet(
          id: '2',
          usuarioId: 'user_demo_2',
          nome: 'Gatoro',
          descricao: 'Tem pelo verde e carrega 3 palitos de dente',
          localizacao: 'Taquaralto, Palmas - TO',
          imagemUrl: 'assets/imagens/gatoro.jpg',
          status: StatusPet.PERDIDO,
          raca: 'Musgo',
          nomeDono: 'Tony Tony Chopper',
          telefoneContato: '(63) 98888-2222',
        ),
      ]);
    });
  }
}
