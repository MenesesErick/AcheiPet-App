import 'package:achei_pet/models/pet.dart';
import 'package:achei_pet/servicos/pet_service.dart';
import 'package:achei_pet/servicos/usuario_service.dart';
import 'package:uuid/uuid.dart';

class PetController {
  static List<Pet> listarPets({
    StatusPet? status,
    String termoBusca = '',
  }) {
    final todos = PetService.getTodos();

    final petsPorStatus = status == null
        ? todos
        : todos.where((pet) => pet.status == status).toList();

    final busca = termoBusca.trim().toLowerCase();

    if (busca.isEmpty) {
      return petsPorStatus;
    }

    return petsPorStatus.where((pet) {
      return pet.nome.toLowerCase().contains(busca) ||
          pet.localizacao.toLowerCase().contains(busca) ||
          (pet.raca?.toLowerCase().contains(busca) ?? false);
    }).toList();
  }

  static List<Pet> listarPetsDoUsuarioLogado() {
    return PetService.getPorUsuario(
      UsuarioService.usuarioLogadoId,
    );
  }

  static Pet salvarPet({
    Pet? petOriginal,
    required String nome,
    String? raca,
    required String descricao,
    required String localizacao,
    required String imagemUrl,
    required StatusPet status,
    required String nomeDono,
    required String telefoneContato,
  }) {
    final pet = Pet(
      id: petOriginal?.id ?? const Uuid().v4(),
      usuarioId: petOriginal?.usuarioId ?? UsuarioService.usuarioLogadoId,
      nome: nome.trim().isEmpty ? 'Pet sem nome' : nome.trim(),
      raca: raca == null || raca.trim().isEmpty ? null : raca.trim(),
      descricao: descricao.trim(),
      localizacao: localizacao.trim(),
      imagemUrl: imagemUrl,
      status: status,
      nomeDono: nomeDono.trim(),
      telefoneContato: telefoneContato.trim(),
    );

    if (petOriginal != null) {
      pet.isarId = petOriginal.isarId;
    }

    PetService.salvar(pet);

    return pet;
  }

  static void deletarPet(Pet pet) {
    PetService.deletar(pet.isarId);
  }

  static void atualizarStatus(Pet pet, StatusPet novoStatus) {
    PetService.atualizarStatus(pet, novoStatus);
  }
}