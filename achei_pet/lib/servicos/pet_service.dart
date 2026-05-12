import 'package:isar/isar.dart';
import 'package:achei_pet/models/pet.dart';
import 'package:achei_pet/servicos/isar_service.dart';

class PetService {
  static Future<List<Pet>> getTodos() {
    return IsarService.db.pets.where().findAll();
  }

  static Future<List<Pet>> getPorUsuario(String usuarioId) {
    return IsarService.db.pets.filter().usuarioIdEqualTo(usuarioId).findAll();
  }

  static Future<void> salvar(Pet pet) async {
    await IsarService.db.writeTxn(() async {
      await IsarService.db.pets.put(pet);
    });
  }

  static Future<bool> deletar(Id isarId) {
    return IsarService.db.writeTxn(() {
      return IsarService.db.pets.delete(isarId);
    });
  }

  static Future<void> atualizarStatus(Pet pet, StatusPet novoStatus) {
    pet.status = novoStatus;
    return salvar(pet);
  }
}
