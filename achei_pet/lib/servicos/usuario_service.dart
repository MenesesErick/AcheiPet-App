import 'package:isar/isar.dart';
import 'package:achei_pet/models/usuario.dart';
import 'package:achei_pet/servicos/isar_service.dart';

class UsuarioService {
  static Future<Usuario?> buscarPorId(String id) {
    return IsarService.db.usuarios.filter().idEqualTo(id).findFirst();
  }

  static Future<void> salvar(Usuario usuario) async {
    await IsarService.db.writeTxn(() async {
      await IsarService.db.usuarios.put(usuario);
    });
  }

  static Future<List<Usuario>> listarTodos() {
    return IsarService.db.usuarios.where().findAll();
  }

  static Future<Usuario?> buscarPorCredenciais(
    String email,
    String senha,
  ) async {
    final emailNormalizado = email.trim().toLowerCase();

    print('[UsuarioService] Tentando login com email: "$emailNormalizado"');

    final usuario = await IsarService.db.usuarios
        .filter()
        .emailEqualTo(emailNormalizado, caseSensitive: false)
        .findFirst();

    if (usuario == null) {
      print('[UsuarioService] Usuário não encontrado.');
      return null;
    }
    if (usuario.senha == null || usuario.senha != senha) {
      print('[UsuarioService] Senha incorreta para "${usuario.email}".');
      return null;
    }

    print('[UsuarioService] Login bem-sucedido: ${usuario.nome}');
    return usuario;
  }
}
