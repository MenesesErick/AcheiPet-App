import 'package:isar/isar.dart';
import 'package:achei_pet/models/usuario.dart';
import 'package:achei_pet/servicos/isar_service.dart';

class UsuarioService {
  static String usuarioLogadoId = 'user_demo_1';

  static Usuario? buscarPorId(String id) {
    return IsarService.db.usuarios.filter().idEqualTo(id).findFirstSync();
  }

  static void salvar(Usuario usuario) {
    IsarService.db.writeTxnSync(() {
      IsarService.db.usuarios.putSync(usuario);
    });
  }

  static List<Usuario> listarTodos() {
    return IsarService.db.usuarios.where().findAllSync();
  }

  static bool login(String email, String senha) {
    final emailNormalizado = email.trim().toLowerCase();

    print('[UsuarioService] Tentando login com email: "$emailNormalizado"');

    final usuario = IsarService.db.usuarios
        .filter()
        .emailEqualTo(emailNormalizado, caseSensitive: false)
        .findFirstSync();

    if (usuario == null) {
      print('[UsuarioService] Usuário não encontrado.');
      return false;
    }
    if (usuario.senha == null || usuario.senha != senha) {
      print('[UsuarioService] Senha incorreta para "${usuario.email}".');
      return false;
    }

    usuarioLogadoId = usuario.id;
    print('[UsuarioService] Login bem-sucedido: ${usuario.nome}');
    return true;
  }
}
