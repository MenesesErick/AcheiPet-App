import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:achei_pet/models/pet.dart';

class PetService {
  static final _client = Supabase.instance.client;

  /// Retorna todos os pets da tabela, independente de usuário.
  static Future<List<Pet>> getTodos() async {
    final response = await _client.from('pets').select();
    return (response as List).map((json) => Pet.fromJson(json)).toList();
  }

  /// Retorna apenas os pets vinculados ao [usuarioId] informado.
  static Future<List<Pet>> getPorUsuario(String usuarioId) async {
    final response = await _client
        .from('pets')
        .select()
        .eq('usuario_id', usuarioId);
    return (response as List).map((json) => Pet.fromJson(json)).toList();
  }

  /// Insere ou atualiza um pet (upsert por chave primária `id`).
  static Future<void> salvar(Pet pet) async {
    await _client.from('pets').upsert(pet.toJson());
  }

  /// Remove o pet com o [id] fornecido.
  static Future<void> deletar(String id) async {
    await _client.from('pets').delete().eq('id', id);
  }

  /// Atualiza apenas o campo `status` do pet informado.
  static Future<void> atualizarStatus(Pet pet, StatusPet novoStatus) async {
    pet.status = novoStatus;
    await _client
        .from('pets')
        .update({'status': novoStatus.name})
        .eq('id', pet.id);
  }
}
