import 'package:isar/isar.dart';
import 'package:achei_pet/models/pet.dart';
import 'package:achei_pet/servicos/isar_service.dart';

class PetService {
  static List<Pet> getTodos() {
    return IsarService.db.pets.where().findAllSync();
  }

  static List<Pet> getPorUsuario(String usuarioId) {
    return IsarService.db.pets
        .filter()
        .usuarioIdEqualTo(usuarioId)
        .findAllSync();
  }

  static void salvar(Pet pet) {
    IsarService.db.writeTxnSync(() {
      IsarService.db.pets.putSync(pet);
    });
  }

  static void deletar(Id isarId) {
    IsarService.db.writeTxnSync(() {
      IsarService.db.pets.deleteSync(isarId);
    });
  }
}
