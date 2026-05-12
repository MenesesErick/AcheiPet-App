import 'package:achei_pet/models/pet.dart';
import 'package:achei_pet/servicos/pet_service.dart';
import 'package:achei_pet/servicos/sessao_service.dart';
import 'package:uuid/uuid.dart';

class PetController {
  static Future<List<Pet>> listarPets({
    StatusPet? status,
    String termoBusca = '',
  }) async {
    final todos = await PetService.getTodos();

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

  static Future<List<Pet>> listarPetsDoUsuarioLogado() {
    return PetService.getPorUsuario(SessaoService.usuarioLogadoId);
  }

  static String? validarCadastroPet({required String? imagemUrl}) {
    if (imagemUrl == null || imagemUrl.isEmpty) {
      return 'Por favor, adicione uma foto do pet do seu computador.';
    }

    return null;
  }

  static Future<Pet> salvarPet({
    Pet? petOriginal,
    required String nome,
    String? raca,
    required String descricao,
    required String localizacao,
    required String imagemUrl,
    required StatusPet status,
    required String nomeDono,
    required String telefoneContato,
  }) async {
    final erroValidacao = validarCadastroPet(imagemUrl: imagemUrl);
    if (erroValidacao != null) {
      throw ArgumentError(erroValidacao);
    }

    final pet = Pet(
      id: petOriginal?.id ?? const Uuid().v4(),
      usuarioId: petOriginal?.usuarioId ?? SessaoService.usuarioLogadoId,
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

    await PetService.salvar(pet);

    return pet;
  }

  static Future<void> deletarPet(Pet pet) async {
    await PetService.deletar(pet.isarId);
  }

  static Future<void> atualizarStatus(Pet pet, StatusPet novoStatus) {
    return PetService.atualizarStatus(pet, novoStatus);
  }
}
