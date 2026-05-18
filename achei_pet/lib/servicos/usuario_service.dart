import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:achei_pet/models/usuario.dart';

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

  /// Lista todos os usuários cadastrados.
  static Future<List<Usuario>> listarTodos() async {
    final response = await _client.from('usuarios').select();
    return (response as List).map((json) => Usuario.fromJson(json)).toList();
  }

  /// Valida e-mail e senha contra a tabela `usuarios`.
  /// Atualiza [usuarioLogadoId] em caso de sucesso.
  static Future<bool> login(String email, String senha) async {
    final emailNormalizado = email.trim().toLowerCase();

    print('[UsuarioService] Tentando login com email: "$emailNormalizado"');

    final response = await _client
        .from('usuarios')
        .select()
        .eq('email', emailNormalizado)
        .maybeSingle();

    if (response == null) {
      print('[UsuarioService] Usuário não encontrado.');
      return false;
    }

    final usuario = Usuario.fromJson(response);

    if (usuario.senha == null || usuario.senha != senha) {
      print('[UsuarioService] Senha incorreta para "${usuario.email}".');
      return false;
    }

    usuarioLogadoId = usuario.id;
    print('[UsuarioService] Login bem-sucedido: ${usuario.nome}');
    return true;
  }
}
