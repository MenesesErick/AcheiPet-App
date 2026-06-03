import 'dart:async';

import 'package:achei_pet/models/notificacao.dart';
import 'package:achei_pet/models/pet.dart';
import 'package:achei_pet/servicos/pet_service.dart';
import 'package:achei_pet/servicos/usuario_service.dart';
import 'package:achei_pet/telas/tela_detalhes_pet.dart';
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
  String? _notificacaoAbrindoId;
  StreamSubscription<List<Map<String, dynamic>>>? _notificacoesSubscription;

  @override
  void initState() {
    super.initState();
    _carregarNotificacoes();
    _assinarNotificacoes();
  }

  @override
  void dispose() {
    _notificacoesSubscription?.cancel();
    super.dispose();
  }

  void _assinarNotificacoes() {
    final usuarioId = UsuarioService.usuarioLogadoId;
    if (usuarioId.isEmpty) return;

    _notificacoesSubscription = Supabase.instance.client
        .from('notificacoes')
        .stream(primaryKey: ['id'])
        .eq('usuario_id', usuarioId)
        .order('created_at', ascending: false)
        .listen(
          (rows) {
            if (!mounted) return;
            setState(() {
              _notificacoes = rows
                  .map((json) => Notificacao.fromJson(json))
                  .toList();
              _carregando = false;
            });
          },
          onError: (_) {
            if (!mounted) return;
            setState(() => _carregando = false);
          },
        );
  }

  Future<void> _carregarNotificacoes() async {
    try {
      final response = await Supabase.instance.client
          .from('notificacoes')
          .select()
          .eq('usuario_id', UsuarioService.usuarioLogadoId)
          .order('created_at', ascending: false);

      if (!mounted) return;
      setState(() {
        _notificacoes = (response as List)
            .map((json) => Notificacao.fromJson(json))
            .toList();
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _carregando = false);
    }
  }

  Future<void> _abrirAnuncio(Notificacao notificacao) async {
    setState(() => _notificacaoAbrindoId = notificacao.id);

    try {
      final pet = await _buscarPetDaNotificacao(notificacao);

      if (pet == null) {
        final mensagem = notificacao.petId == null
            ? 'Essa notificação antiga não identifica um único anúncio.'
            : 'Anúncio não encontrado.';
        _mostrarMensagem(mensagem);
        return;
      }

      if (!notificacao.lida) {
        await Supabase.instance.client
            .from('notificacoes')
            .update({'lida': true})
            .eq('id', notificacao.id);
      }

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TelaDetalhesPet(pet: pet)),
      );
      _carregarNotificacoes();
    } catch (e) {
      debugPrint('Erro ao abrir anúncio da notificação: $e');
      _mostrarMensagem('Não foi possível abrir o anúncio.');
    } finally {
      if (mounted) {
        setState(() => _notificacaoAbrindoId = null);
      }
    }
  }

  Future<Pet?> _buscarPetDaNotificacao(Notificacao notificacao) {
    final petId = notificacao.petId;
    if (petId != null) {
      return PetService.getPorId(petId);
    }

    return PetService.getPetPerdidoMaisProximoDoUsuario(
      UsuarioService.usuarioLogadoId,
      distanciaAlvoKm: _extrairDistanciaKm(notificacao.mensagem),
    );
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  double? _extrairDistanciaKm(String mensagem) {
    final match = RegExp(r'(\d+(?:[,.]\d+)?)\s*km').firstMatch(mensagem);
    if (match == null) return null;

    return double.tryParse(match.group(1)!.replaceAll(',', '.'));
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
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
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
                  final abrindo = _notificacaoAbrindoId == notif.id;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      onTap: abrindo ? null : () => _abrirAnuncio(notif),
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
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: abrindo
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.chevron_right),
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
