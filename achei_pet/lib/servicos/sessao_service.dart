class SessaoService {
  static String _usuarioLogadoId = 'user_demo_1';

  static String get usuarioLogadoId => _usuarioLogadoId;

  static void autenticar(String usuarioId) {
    _usuarioLogadoId = usuarioId;
  }

  static void sair() {
    _usuarioLogadoId = 'user_demo_1';
  }
}
