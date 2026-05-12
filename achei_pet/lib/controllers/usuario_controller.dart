import 'package:achei_pet/models/usuario.dart';
import 'package:achei_pet/servicos/usuario_service.dart';
import 'package:uuid/uuid.dart';

class UsuarioController {
  static bool fazerLogin({
    required String email,
    required String senha,
  }) {
    return UsuarioService.login(email, senha);
  }

  static Usuario cadastrarUsuario({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
    String? fotoUrl,
  }) {
    final novoUsuario = Usuario(
      id: const Uuid().v4(),
      nome: nome.trim(),
      email: email.trim().toLowerCase(),
      telefonePessoal: telefone.trim(),
      fotoUrl: fotoUrl,
      senha: senha,
    );

    UsuarioService.salvar(novoUsuario);
    UsuarioService.usuarioLogadoId = novoUsuario.id;

    return novoUsuario;
  }

  static Usuario? buscarUsuarioLogado() {
    return UsuarioService.buscarPorId(
      UsuarioService.usuarioLogadoId,
    );
  }

  static Usuario atualizarPerfil({
    required Usuario usuarioOriginal,
    required String nome,
    required String email,
    required String telefone,
    String? novaFotoUrl,
  }) {
    final usuarioAtualizado = Usuario(
      id: usuarioOriginal.id,
      nome: nome.trim(),
      email: email.trim().toLowerCase(),
      telefonePessoal: telefone.trim(),
      fotoUrl: novaFotoUrl ?? usuarioOriginal.fotoUrl,
      senha: usuarioOriginal.senha,
    )..isarId = usuarioOriginal.isarId;

    UsuarioService.salvar(usuarioAtualizado);

    return usuarioAtualizado;
  }
}