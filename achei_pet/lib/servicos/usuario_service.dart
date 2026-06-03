import 'package:achei_pet/models/usuario.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsuarioService {
  static final _client = Supabase.instance.client;

  /// ID do usuário atualmente logado na sessão (controle em memória).
  static String usuarioLogadoId = 'user_demo_1';

  /// Busca um usuário pelo seu UUID.
  static Future<Usuario?> buscarPorId(String id) async {
    final response = await _client
        .from('usuarios')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Usuario.fromJson(response);
  }

  /// Insere ou atualiza um usuário (upsert por chave primária `id`).
  static Future<void> salvar(Usuario usuario) async {
    await _client.from('usuarios').upsert(usuario.toJson());
  }

  static Future<void> atualizarLocalizacao({
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _client
          .from('usuarios')
          .update({'latitude': latitude, 'longitude': longitude})
          .eq('id', usuarioLogadoId);
    } catch (e) {
      debugPrint('Erro ao atualizar localização do usuário: $e');
    }
  }

  static Future<bool> temNotificacaoNaoLida() async {
    final response = await _client
        .from('notificacoes')
        .select('id')
        .eq('usuario_id', usuarioLogadoId)
        .eq('lida', false)
        .limit(1);

    return (response as List).isNotEmpty;
  }

  /// Lista todos os usuários cadastrados.
  static Future<List<Usuario>> listarTodos() async {
    final response = await _client.from('usuarios').select();
    return (response as List).map((json) => Usuario.fromJson(json)).toList();
  }

  /// Valida e-mail e senha contra a autenticação do Supabase.
  /// Atualiza [usuarioLogadoId] em caso de sucesso.
  static Future<bool> login(String email, String senha) async {
    final emailNormalizado = email.trim().toLowerCase();

    debugPrint(
      '[UsuarioService] Tentando login com email: "$emailNormalizado" via Supabase Auth',
    );

    try {
      final response = await _client.auth.signInWithPassword(
        email: emailNormalizado,
        password: senha,
      );

      final user = response.user;
      if (user != null) {
        usuarioLogadoId = user.id;
        debugPrint('[UsuarioService] Login bem-sucedido: ${user.email}');
        return true;
      }
    } catch (e) {
      debugPrint('[UsuarioService] Erro ao fazer login no Supabase Auth: $e');
    }

    return false;
  }
}
