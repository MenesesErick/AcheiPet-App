import 'package:achei_pet/controllers/pet_controller.dart';
import 'package:achei_pet/models/pet.dart';
import 'package:achei_pet/telas/tela_detalhes_pet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TelaMapaGeral extends StatefulWidget {
  const TelaMapaGeral({super.key});

  @override
  State<TelaMapaGeral> createState() => _TelaMapaGeralState();
}

class _TelaMapaGeralState extends State<TelaMapaGeral> {
  List<Pet> _petsPerdidos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarPets();
  }

  Future<void> _carregarPets() async {
    final todos = await PetController.listarPets(status: StatusPet.PERDIDO);
    if (!mounted) return;
    setState(() {
      _petsPerdidos = todos
          .where((p) => p.latitude != null && p.longitude != null)
          .toList();
      _carregando = false;
    });
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
                  color: Colors.black.withOpacity(0.3),
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
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.pets,
                        color: Colors.red,
                        size: 22,
                      ),
                    )
                  : const Icon(Icons.pets, color: Colors.red, size: 22),
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.red, size: 20),
        ],
      ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  options: const MapOptions(
                    initialCenter: LatLng(-10.1843, -48.3336),
                    initialZoom: 12.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.acheipet',
                    ),
                    MarkerLayer(
                      markers: _petsPerdidos.map((pet) {
                        return Marker(
                          point: LatLng(pet.latitude!, pet.longitude!),
                          width: 60,
                          height: 60,
                          alignment: Alignment.topCenter,
                          child: _buildMarkerChild(pet),
                        );
                      }).toList(),
                    ),
                  ],
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
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.map_outlined, size: 60, color: Colors.grey.shade300),
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
