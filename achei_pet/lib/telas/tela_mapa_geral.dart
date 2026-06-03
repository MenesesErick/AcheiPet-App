import 'dart:async';

import 'package:achei_pet/controllers/pet_controller.dart';
import 'package:achei_pet/models/pet.dart';
import 'package:achei_pet/servicos/usuario_service.dart';
import 'package:achei_pet/telas/tela_detalhes_pet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class TelaMapaGeral extends StatefulWidget {
  const TelaMapaGeral({super.key});

  @override
  State<TelaMapaGeral> createState() => _TelaMapaGeralState();
}

class _TelaMapaGeralState extends State<TelaMapaGeral> {
  List<Pet> _petsPerdidos = [];
  bool _carregando = true;
  final MapController _mapController = MapController();
  LatLng? _minhaLocalizacao;
  bool _mapaPronto = false;
  bool _centralizacaoPendente = false;
  StreamSubscription<Position>? _localizacaoSubscription;

  @override
  void initState() {
    super.initState();
    _carregarPets();
    iniciarLocalizacaoEmTempoReal();
  }

  @override
  void dispose() {
    _localizacaoSubscription?.cancel();
    super.dispose();
  }

  Future<void> _carregarPets() async {
    final todos = await PetController.listarPets(status: StatusPet.PERDIDO);
    if (!mounted) return;
    setState(() {
      _petsPerdidos = todos.where(_petTemCoordenadaValida).toList();
      _carregando = false;
    });
  }

  Future<bool> _prepararLocalizacao() async {
    final servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) return false;

    var permissao = await Geolocator.checkPermission();

    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    if (permissao == LocationPermission.denied ||
        permissao == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> iniciarLocalizacaoEmTempoReal() async {
    final podeUsar = await _prepararLocalizacao();
    if (!podeUsar) return;

    try {
      final posicaoInicial = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _atualizarMinhaLocalizacao(posicaoInicial, centralizar: true);
    } catch (_) {
      // O stream abaixo ainda pode entregar a primeira posição depois.
    }

    _localizacaoSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 20,
          ),
        ).listen((Position posicaoAtual) {
          _atualizarMinhaLocalizacao(posicaoAtual);
          verificarPetsProximos(posicaoAtual.latitude, posicaoAtual.longitude);
        });
  }

  void _atualizarMinhaLocalizacao(
    Position posicao, {
    bool centralizar = false,
  }) {
    if (!_coordenadaValida(posicao.latitude, posicao.longitude)) return;

    final novaLocalizacao = LatLng(posicao.latitude, posicao.longitude);

    if (!mounted) return;
    setState(() {
      _minhaLocalizacao = novaLocalizacao;
    });

    UsuarioService.atualizarLocalizacao(
      latitude: posicao.latitude,
      longitude: posicao.longitude,
    );

    if (centralizar) {
      _moverMapaPara(novaLocalizacao);
    }
  }

  void _centralizarNaMinhaLocalizacao() {
    final localizacao = _minhaLocalizacao;
    if (localizacao == null) return;

    _moverMapaPara(localizacao);
  }

  void _moverMapaPara(LatLng localizacao) {
    if (!_coordenadaValida(localizacao.latitude, localizacao.longitude)) return;

    if (!_mapaPronto) {
      _centralizacaoPendente = true;
      return;
    }

    _mapController.move(localizacao, 15);
  }

  void _aoMapaPronto() {
    _mapaPronto = true;

    if (!_centralizacaoPendente ||
        _minhaLocalizacao == null ||
        !_coordenadaValida(
          _minhaLocalizacao!.latitude,
          _minhaLocalizacao!.longitude,
        )) {
      return;
    }

    _centralizacaoPendente = false;
    _mapController.move(_minhaLocalizacao!, 15);
  }

  void verificarPetsProximos(double minhaLat, double minhaLng) {
    if (!_coordenadaValida(minhaLat, minhaLng)) return;

    for (final pet in _petsPerdidos) {
      if (!_petTemCoordenadaValida(pet)) continue;

      final distanciaMetros = Geolocator.distanceBetween(
        minhaLat,
        minhaLng,
        pet.latitude!,
        pet.longitude!,
      );

      if (distanciaMetros <= 500) {
        debugPrint('Você está perto de ${pet.nome}');
      }
    }
  }

  bool _petTemCoordenadaValida(Pet pet) {
    return _coordenadaValida(pet.latitude, pet.longitude);
  }

  bool _coordenadaValida(double? latitude, double? longitude) {
    return latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  Widget _buildMarkerChild(Pet pet) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TelaDetalhesPet(pet: pet)),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              color: Colors.white,
            ),
            child: ClipOval(
              child: pet.imagemUrl.startsWith('http')
                  ? Image.network(
                      pet.imagemUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.pets, color: Colors.red, size: 22),
                    )
                  : const Icon(Icons.pets, color: Colors.red, size: 22),
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.red, size: 20),
        ],
      ),
    );
  }

  Widget _buildMinhaLocalizacaoMarker() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withValues(alpha: 0.18),
          ),
        ),
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.shade600,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Mapa de Pets Perdidos',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (!_carregando)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_petsPerdidos.length} perdido${_petsPerdidos.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(-10.1843, -48.3336),
                    initialZoom: 12.0,
                    onMapReady: _aoMapaPronto,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.acheipet',
                    ),
                    MarkerLayer(
                      markers: [
                        if (_minhaLocalizacao != null)
                          Marker(
                            point: _minhaLocalizacao!,
                            width: 54,
                            height: 54,
                            child: _buildMinhaLocalizacaoMarker(),
                          ),
                        ..._petsPerdidos.map((pet) {
                          return Marker(
                            point: LatLng(pet.latitude!, pet.longitude!),
                            width: 60,
                            height: 75,
                            alignment: Alignment.topCenter,
                            child: _buildMarkerChild(pet),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton.small(
                    heroTag: 'centralizar-minha-localizacao',
                    backgroundColor: Colors.white,
                    foregroundColor: _minhaLocalizacao == null
                        ? Colors.grey
                        : Colors.blue.shade700,
                    onPressed: _minhaLocalizacao == null
                        ? null
                        : _centralizarNaMinhaLocalizacao,
                    child: const Icon(Icons.my_location),
                  ),
                ),
                if (_petsPerdidos.isEmpty)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 60,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Nenhum pet perdido\ncom localização cadastrada',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
