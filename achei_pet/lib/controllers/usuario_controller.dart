import 'package:achei_pet/models/usuario.dart';
import 'package:achei_pet/servicos/usuario_service.dart';
import 'package:uuid/uuid.dart';

class UsuarioController {
  /// Realiza o login do usuário verificando e-mail e senha.
  bool fazerLogin(String email, String senha) {
    return UsuarioService.login(email, senha);
  }

  /// Valida e cadastra um novo usuário no sistema, já deixando-o logado.
  void cadastrarUsuario({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
    String? fotoUrl,
  }) {
    final novoId = const Uuid().v4();
    
    final novoUsuario = Usuario(
      id: novoId,
      nome: nome,
      email: email.trim().toLowerCase(),
      telefonePessoal: telefone,
      fotoUrl: fotoUrl,
      senha: senha,
    );

    UsuarioService.salvar(novoUsuario);
    UsuarioService.usuarioLogadoId = novoId; // Atualiza a sessão
    UsuarioService.debugListarTodos();
  }

  /// Limpa a sessão do usuário atual.
  void fazerLogout() {
    UsuarioService.usuarioLogadoId = '';
  }

  /// Retorna os dados do usuário logado na sessão atual.
  Usuario obterUsuarioLogado() {
    return UsuarioService.buscarPorId(UsuarioService.usuarioLogadoId) ??
        Usuario(
          id: '0',
          nome: 'Usuário Desconhecido',
          email: 'erro@app.com',
          telefonePessoal: '',
        );
  }
}
