import 'package:achei_pet/models/pet.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  static Future<Pet?> getPorId(String id) async {
    final response = await _client
        .from('pets')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;

    return Pet.fromJson(response);
  }

  static Future<Pet?> getPetPerdidoMaisProximoDoUsuario(
    String usuarioId, {
    double raioKm = 2.0,
    double userLat = -10.1843,
    double userLon = -48.3336,
    double? distanciaAlvoKm,
  }) async {
    if (!_coordenadaValida(userLat, userLon)) return null;

    final pets = await getTodos();
    Pet? petMaisProximo;
    double? menorDistancia;
    final petsComDistanciaAlvo = <Pet>[];

    for (final pet in pets) {
      if (pet.status != StatusPet.PERDIDO ||
          !_coordenadaValida(pet.latitude, pet.longitude) ||
          pet.usuarioId == usuarioId) {
        continue;
      }

      final distancia = _calcularDistancia(
        pet.latitude!,
        pet.longitude!,
        userLat,
        userLon,
      );

      if (distancia > raioKm) continue;

      if (distanciaAlvoKm != null) {
        final diferenca = (distancia - distanciaAlvoKm).abs();
        if (diferenca <= 0.05) {
          petsComDistanciaAlvo.add(pet);
        }
      }

      if (menorDistancia == null || distancia < menorDistancia) {
        menorDistancia = distancia;
        petMaisProximo = pet;
      }
    }

    if (distanciaAlvoKm != null) {
      return petsComDistanciaAlvo.length == 1
          ? petsComDistanciaAlvo.first
          : null;
    }

    return petMaisProximo;
  }

  /// Insere ou atualiza um pet (upsert por chave primária `id`).
  static Future<void> salvar(Pet pet, {bool gerarNotificacoes = true}) async {
    await _client.from('pets').upsert(pet.toJson());

    if (!gerarNotificacoes) return;

    try {
      final usuarios = await Supabase.instance.client.from('usuarios').select();
      final notificacoes = <Map<String, dynamic>>[];

      for (final usuario in usuarios) {
        final usuarioId = usuario['id'] as String?;
        if (usuarioId == null || usuarioId == pet.usuarioId) continue;

        notificacoes.add({
          'usuario_id': usuarioId,
          'pet_id': pet.id,
          'mensagem': _montarMensagemNotificacao(pet, usuario),
          'lida': false,
        });
      }

      if (notificacoes.isNotEmpty) {
        await Supabase.instance.client
            .from('notificacoes')
            .insert(notificacoes);
      }
    } catch (e) {
      debugPrint('Erro ao gerar notificações de novo cadastro: $e');
    }
  }

  static String _montarMensagemNotificacao(
    Pet pet,
    Map<String, dynamic> usuario,
  ) {
    final userLat = (usuario['latitude'] as num?)?.toDouble();
    final userLon = (usuario['longitude'] as num?)?.toDouble();

    if (pet.status == StatusPet.PERDIDO &&
        _coordenadaValida(pet.latitude, pet.longitude) &&
        _coordenadaValida(userLat, userLon)) {
      final distancia = _calcularDistancia(
        pet.latitude!,
        pet.longitude!,
        userLat!,
        userLon!,
      );

      if (distancia <= 2.0) {
        return 'Alerta de Proximidade: ${pet.nome} foi perdido a ${distancia.toStringAsFixed(1)} km de você. Verifique no app!';
      }
    }

    final statusTexto = pet.status == StatusPet.PERDIDO
        ? 'perdido'
        : 'encontrado';

    return 'Novo anúncio: ${pet.nome} foi cadastrado como $statusTexto. Verifique no app!';
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

  static double _calcularDistancia(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  static bool _coordenadaValida(double? latitude, double? longitude) {
    return latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }
}
