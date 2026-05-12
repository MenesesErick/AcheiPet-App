import 'package:achei_pet/models/usuario.dart';
import 'package:achei_pet/servicos/sessao_service.dart';
import 'package:achei_pet/servicos/usuario_service.dart';
import 'package:uuid/uuid.dart';

class UsuarioController {
  static Future<bool> fazerLogin({
    required String email,
    required String senha,
  }) async {
    final usuario = await UsuarioService.buscarPorCredenciais(email, senha);
    if (usuario == null) {
      return false;
    }

    SessaoService.autenticar(usuario.id);
    return true;
  }

  static String? validarCadastroUsuario({
    required String senha,
    required String confirmarSenha,
  }) {
    if (senha != confirmarSenha) {
      return 'As senhas não coincidem!';
    }

    return null;
  }

  static Future<Usuario> cadastrarUsuario({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
    required String confirmarSenha,
    String? fotoUrl,
  }) async {
    final erroValidacao = validarCadastroUsuario(
      senha: senha,
      confirmarSenha: confirmarSenha,
    );
    if (erroValidacao != null) {
      throw ArgumentError(erroValidacao);
    }

    final novoUsuario = Usuario(
      id: const Uuid().v4(),
      nome: nome.trim(),
      email: email.trim().toLowerCase(),
      telefonePessoal: telefone.trim(),
      fotoUrl: fotoUrl,
      senha: senha,
    );

    await UsuarioService.salvar(novoUsuario);
    SessaoService.autenticar(novoUsuario.id);

    return novoUsuario;
  }

  static Future<Usuario?> buscarUsuarioLogado() {
    return UsuarioService.buscarPorId(SessaoService.usuarioLogadoId);
  }

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
    )..isarId = usuarioOriginal.isarId;

    await UsuarioService.salvar(usuarioAtualizado);

    return usuarioAtualizado;
  }
}
