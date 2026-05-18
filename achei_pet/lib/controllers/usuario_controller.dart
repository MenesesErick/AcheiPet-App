import 'package:achei_pet/models/usuario.dart';
import 'package:achei_pet/servicos/usuario_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class UsuarioController {
  /// Tenta fazer login e retorna true se as credenciais forem válidas.
  static Future<bool> fazerLogin({
    required String email,
    required String senha,
  }) async {
    return UsuarioService.login(email, senha);
  }

  /// Cadastra um novo usuário e o define como sessão logada atual.
  static Future<Usuario> cadastrarUsuario({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
    String? fotoUrl,
  }) async {
    final emailNormalizado = email.trim().toLowerCase();

    // 1. Cadastra o usuário no cofre de autenticação (auth) do Supabase
    final authResponse = await Supabase.instance.client.auth.signUp(
      email: emailNormalizado,
      password: senha,
    );

    final user = authResponse.user;
    if (user == null) {
      throw Exception('Não foi possível registrar o usuário na autenticação do Supabase.');
    }

    // 2. Cria o objeto de perfil utilizando o UUID gerado pelo auth do Supabase
    final novoUsuario = Usuario(
      id: user.id,
      nome: nome.trim(),
      email: emailNormalizado,
      telefonePessoal: telefone.trim(),
      fotoUrl: fotoUrl,
    );

    // 3. Salva o perfil na tabela pública public.usuarios
    try {
      await UsuarioService.salvar(novoUsuario);
    } catch (e) {
      print('Erro ao salvar o perfil do usuário: $e');
      rethrow;
    }

    // 4. Atualiza a sessão local
    UsuarioService.usuarioLogadoId = user.id;

    return novoUsuario;
  }

  /// Busca e retorna o usuário atualmente logado.
  static Future<Usuario?> buscarUsuarioLogado() async {
    return UsuarioService.buscarPorId(UsuarioService.usuarioLogadoId);
  }

  /// Atualiza os dados de perfil do usuário e persiste no Supabase.
  static Future<Usuario> atualizarPerfil({
    required Usuario usuarioOriginal,
    required String nome,
    required String email,
    required String telefone,
    String? novaFotoUrl,
  }) async {
    final usuarioAtualizado = Usuario(
      id: usuarioOriginal.id,
      nome: nome.trim(),
      email: email.trim().toLowerCase(),
      telefonePessoal: telefone.trim(),
      fotoUrl: novaFotoUrl ?? usuarioOriginal.fotoUrl,
      senha: usuarioOriginal.senha,
    );

    await UsuarioService.salvar(usuarioAtualizado);
    return usuarioAtualizado;
  }

  /// Desloga o usuário do Supabase e limpa a sessão local.
  Future<void> fazerLogout() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      print('Erro ao realizar logout: $e');
    } finally {
      UsuarioService.usuarioLogadoId = '';
    }
  }
}