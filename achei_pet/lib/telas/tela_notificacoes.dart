import 'package:achei_pet/models/notificacao.dart';
import 'package:achei_pet/servicos/usuario_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TelaNotificacoes extends StatefulWidget {
  const TelaNotificacoes({super.key});

  @override
  State<TelaNotificacoes> createState() => _TelaNotificacoesState();
}

class _TelaNotificacoesState extends State<TelaNotificacoes> {
  List<Notificacao> _notificacoes = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarNotificacoes();
  }

  Future<void> _carregarNotificacoes() async {
    try {
      final response = await Supabase.instance.client
          .from('notificacoes')
          .select()
          .eq('usuario_id', UsuarioService.usuarioLogadoId)
          .order('created_at', ascending: false);

      setState(() {
        _notificacoes =
            (response as List).map((json) => Notificacao.fromJson(json)).toList();
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _notificacoes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.notifications_off_outlined,
                          size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhuma notificação',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _carregarNotificacoes,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notificacoes.length,
                    itemBuilder: (context, index) {
                      final notif = _notificacoes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: notif.lida
                                ? Colors.grey.shade200
                                : Colors.orange.shade100,
                            child: Icon(
                              Icons.pets,
                              color: notif.lida ? Colors.grey : Colors.orange,
                            ),
                          ),
                          title: Text(
                            notif.mensagem,
                            style: TextStyle(
                              fontWeight: notif.lida
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            _formatarData(notif.createdAt),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _formatarData(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}  '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}
