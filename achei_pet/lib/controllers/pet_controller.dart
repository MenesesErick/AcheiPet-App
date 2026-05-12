import 'package:achei_pet/models/pet.dart';
import 'package:achei_pet/servicos/pet_service.dart';
import 'package:achei_pet/servicos/usuario_service.dart';
import 'package:achei_pet/widgets/filtro_pet.dart';
import 'package:uuid/uuid.dart';

class PetController {
  /// Retorna todos os pets do sistema.
  List<Pet> listarTodosPets() {
    return PetService.getTodos();
  }

  /// Retorna apenas os pets do usuário logado atual.
  List<Pet> listarMeusPets() {
    return PetService.getPorUsuario(UsuarioService.usuarioLogadoId);
  }

  /// Salva um novo pet ou atualiza um existente
  Pet salvarPet({
    Pet? petParaEditar,
    required String nome,
    String? raca,
    required String descricao,
    required String localizacao,
    required String imagemUrl,
    required StatusPet status,
    required String nomeDono,
    required String telefoneContato,
  }) {
    final petAtualizado = Pet(
      id: petParaEditar?.id ?? const Uuid().v4(),
      usuarioId: petParaEditar?.usuarioId ?? UsuarioService.usuarioLogadoId,
      nome: nome.isEmpty ? 'Pet sem nome' : nome,
      raca: (raca == null || raca.isEmpty) ? null : raca,
      descricao: descricao,
      localizacao: localizacao,
      imagemUrl: imagemUrl,
      status: status,
      nomeDono: nomeDono,
      telefoneContato: telefoneContato,
    );

    if (petParaEditar != null) {
      petAtualizado.isarId = petParaEditar.isarId;
    }

    PetService.salvar(petAtualizado);
    return petAtualizado;
  }

  /// Deleta um pet do sistema baseado no ID interno
  void deletarPet(int isarId) {
    PetService.deletar(isarId);
  }

  /// Atualiza apenas o status de um pet específico
  void alterarStatus(Pet pet, StatusPet novoStatus) {
    PetService.atualizarStatus(pet, novoStatus);
    pet.status = novoStatus; // Atualiza a referência local
  }

  /// Filtra a lista de pets com base no status e texto de busca
  List<Pet> filtrarPets(FiltroPet filtroAtual, String textoBusca) {
    final todos = listarTodosPets();
    List<Pet> petsPorStatus = switch (filtroAtual) {
      FiltroPet.TODOS => todos,
      FiltroPet.ENCONTRADOS => todos.where((p) => p.status == StatusPet.ENCONTRADO).toList(),
      FiltroPet.PERDIDOS => todos.where((p) => p.status == StatusPet.PERDIDO).toList(),
    };

    if (textoBusca.isEmpty) return petsPorStatus;

    final buscaMinuscula = textoBusca.toLowerCase();

    return petsPorStatus.where((pet) {
      if (pet.nome.toLowerCase().contains(buscaMinuscula)) return true;
      if (pet.localizacao.toLowerCase().contains(buscaMinuscula)) return true;
      if (pet.raca != null && pet.raca!.toLowerCase().contains(buscaMinuscula)) return true;
      return false;
    }).toList();
  }
}
