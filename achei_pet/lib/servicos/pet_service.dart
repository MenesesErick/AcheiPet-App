import 'dart:math' as math;
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

    try {
      // Pega a lat/lon do pet recém cadastrado. Se for nulo, ignora a notificação.
      if (pet.latitude != null && pet.longitude != null) {
        // 1. Busca todos os usuários
        final usuarios = await Supabase.instance.client.from('usuarios').select();
        
        for (var u in usuarios) {
          // 2. Ignora o próprio dono do anúncio
          if (u['id'] == pet.usuarioId) continue;
          
          // 3. Pega a lat/lon do usuário ou usa o centro de Palmas (Praça dos Girassóis) como fallback do protótipo
          final double userLat = u['latitude'] != null ? (u['latitude'] as num).toDouble() : -10.1843;
          final double userLon = u['longitude'] != null ? (u['longitude'] as num).toDouble() : -48.3336;
          
          // 4. Calcula a distância
          final distancia = _calcularDistancia(pet.latitude!, pet.longitude!, userLat, userLon);
          
          // 5. Se estiver no raio de 10km, dispara a notificação no banco
          if (distancia <= 10.0) {
            await Supabase.instance.client.from('notificacoes').insert({
              'usuario_id': u['id'],
              'mensagem': 'Alerta de Proximidade: Um pet foi perdido a ${distancia.toStringAsFixed(1)} km de você. Verifique no app!',
              'lida': false,
            });
          }
        }
      }
    } catch (e) {
      print('Erro ao gerar notificações de proximidade: $e');
    }
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

  static double _calcularDistancia(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // Raio da Terra em KM
    final dLat = (lat2 - lat1) * math.pi / 180.0;
    final dLon = (lon2 - lon1) * math.pi / 180.0;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180.0) * math.cos(lat2 * math.pi / 180.0) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }
}
