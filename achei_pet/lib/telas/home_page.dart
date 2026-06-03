import 'package:achei_pet/models/pet.dart';
import 'package:achei_pet/controllers/pet_controller.dart';
import 'package:achei_pet/servicos/usuario_service.dart';
import 'package:achei_pet/telas/tela_detalhes_pet.dart';
import 'package:achei_pet/telas/tela_notificacoes.dart';
import 'package:achei_pet/utils/cores.dart';
import 'package:achei_pet/utils/constantes.dart';
import 'package:achei_pet/widgets/campo_busca.dart';
import 'package:achei_pet/widgets/card_pet.dart';
import 'package:achei_pet/widgets/filtro_pet.dart';
import 'package:achei_pet/widgets/texto_formatado.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FiltroPet _filtroAtual = FiltroPet.TODOS;
  final TextEditingController _buscaController = TextEditingController();
  String _textoBusca = '';

  // Lista em memória que é atualizada após cada carregamento do Supabase
  List<Pet> _pets = [];
  bool _carregando = true;
  bool _temNotificacaoNaoLida = false;
  Position? _minhaPosicao;

  @override
  void initState() {
    super.initState();
    _carregarPets();
    _carregarStatusNotificacoes();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarPets() async {
    setState(() => _carregando = true);
    await _carregarMinhaLocalizacao();

    final status = switch (_filtroAtual) {
      FiltroPet.TODOS => null,
      FiltroPet.PERDIDOS => StatusPet.PERDIDO,
      FiltroPet.ENCONTRADOS => StatusPet.ENCONTRADO,
    };

    final pets = await PetController.listarPets(
      status: status,
      termoBusca: _textoBusca,
    );

    if (!mounted) return;
    setState(() {
      _pets = pets;
      if (_minhaPosicao != null) {
        _pets.sort((a, b) {
          final distA = _calcularDistancia(a.latitude, a.longitude);
          final distB = _calcularDistancia(b.latitude, b.longitude);
          return distA.compareTo(distB);
        });
      }
      _carregando = false;
    });
  }

  Future<void> _carregarStatusNotificacoes() async {
    try {
      final temNaoLida = await UsuarioService.temNotificacaoNaoLida();
      if (!mounted) return;
      setState(() => _temNotificacaoNaoLida = temNaoLida);
    } catch (_) {
      if (!mounted) return;
      setState(() => _temNotificacaoNaoLida = false);
    }
  }

  Future<void> _carregarMinhaLocalizacao() async {
    try {
      final servicoAtivo = await Geolocator.isLocationServiceEnabled();
      if (!servicoAtivo) return;

      var permissao = await Geolocator.checkPermission();
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }

      if (permissao == LocationPermission.denied ||
          permissao == LocationPermission.deniedForever) {
        return;
      }

      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _minhaPosicao = posicao;
      UsuarioService.atualizarLocalizacao(
        latitude: posicao.latitude,
        longitude: posicao.longitude,
      );
    } catch (_) {
      // Se a localização falhar, a Home continua carregando os pets normalmente.
    }
  }

  double _calcularDistancia(double? petLat, double? petLon) {
    final posicao = _minhaPosicao;
    if (petLat == null || petLon == null || posicao == null) return 9999.0;

    return Geolocator.distanceBetween(
          posicao.latitude,
          posicao.longitude,
          petLat,
          petLon,
        ) /
        1000;
  }

  void _navegarParaDetalhes(Pet pet) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TelaDetalhesPet(pet: pet)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.corFundo,
      appBar: AppBar(
        toolbarHeight: 120,
        centerTitle: true,
        title: const TextoFormatado(texto: Constantes.nomeApp),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 16),
            child: IconButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TelaNotificacoes(),
                  ),
                );
                _carregarStatusNotificacoes();
              },
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    size: 50,
                    color: Colors.black,
                  ),
                  if (_temNotificacaoNaoLida)
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CampoBusca(
              controller: _buscaController,
              onChanged: (valor) {
                setState(() => _textoBusca = valor);
                _carregarPets();
              },
            ),
            const SizedBox(height: 17),
            FiltroPets(
              selecionado: _filtroAtual,
              onChanged: (filtro) {
                setState(() => _filtroAtual = filtro);
                _carregarPets();
              },
            ),
            const SizedBox(height: 29),
            const Text(
              'Ajude um pet a voltar para casa',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Publique um anúncio de pet perdido',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _carregando
                  ? const Center(child: CircularProgressIndicator())
                  : _pets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pets_outlined,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum pet encontrado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _textoBusca.isEmpty
                                ? 'Não há pets cadastrados'
                                : 'Tente outra busca',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _carregarPets,
                      child: ListView.builder(
                        itemCount: _pets.length,
                        itemBuilder: (context, index) => CardPet(
                          pet: _pets[index],
                          usuarioLatitude: _minhaPosicao?.latitude,
                          usuarioLongitude: _minhaPosicao?.longitude,
                          onVerDetalhes: () =>
                              _navegarParaDetalhes(_pets[index]),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
