import 'package:achei_pet/models/pet.dart';
import 'package:achei_pet/servicos/pet_service.dart';
import 'package:achei_pet/servicos/usuario_service.dart';
import 'package:uuid/uuid.dart';

class PetController {
  /// Lista todos os pets, com filtro opcional de status e busca textual.
  static Future<List<Pet>> listarPets({
    StatusPet? status,
    String termoBusca = '',
  }) async {
    final todos = await PetService.getTodos();

    final petsPorStatus = status == null
        ? todos
        : todos.where((pet) => pet.status == status).toList();

    final busca = termoBusca.trim().toLowerCase();

    if (busca.isEmpty) return petsPorStatus;

    return petsPorStatus.where((pet) {
      return pet.nome.toLowerCase().contains(busca) ||
          pet.localizacao.toLowerCase().contains(busca) ||
          (pet.raca?.toLowerCase().contains(busca) ?? false);
    }).toList();
  }

  /// Lista apenas os pets do usuário atualmente logado.
  static Future<List<Pet>> listarPetsDoUsuarioLogado() async {
    return PetService.getPorUsuario(UsuarioService.usuarioLogadoId);
  }

  /// Cria ou atualiza um pet e o persiste no Supabase.
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

    await PetService.salvar(pet);
    return pet;
  }

  /// Remove um pet do Supabase pelo seu UUID.
  static Future<void> deletarPet(Pet pet) async {
    await PetService.deletar(pet.id);
  }

  /// Atualiza o status de um pet no Supabase.
  static Future<void> atualizarStatus(Pet pet, StatusPet novoStatus) async {
    await PetService.atualizarStatus(pet, novoStatus);
  }
}