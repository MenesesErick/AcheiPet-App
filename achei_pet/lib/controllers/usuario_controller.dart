import 'package:achei_pet/models/usuario.dart';
import 'package:achei_pet/servicos/usuario_service.dart';
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
    final novoUsuario = Usuario(
      id: const Uuid().v4(),
      nome: nome.trim(),
      email: email.trim().toLowerCase(),
      telefonePessoal: telefone.trim(),
      fotoUrl: fotoUrl,
      senha: senha,
    );

    await UsuarioService.salvar(novoUsuario);
    UsuarioService.usuarioLogadoId = novoUsuario.id;

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
}