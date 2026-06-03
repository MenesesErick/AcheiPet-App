import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:achei_pet/models/pet.dart';
import 'package:achei_pet/utils/cores.dart';
import 'package:url_launcher/url_launcher.dart';

class TelaDetalhesPet extends StatelessWidget {
  final Pet pet;

  const TelaDetalhesPet({super.key, required this.pet});

  Widget _carregarImagem(String url) {
    if (url.isEmpty) {
      return Container(
        width: double.infinity,
        height: 300,
        color: Colors.grey.shade200,
        child: const Icon(Icons.pets, size: 80, color: Colors.grey),
      );
    } else if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: double.infinity,
          height: 300,
          color: Colors.grey.shade200,
          child: const Icon(Icons.pets, size: 80, color: Colors.grey),
        ),
      );
    } else if (url.startsWith('http')) {
      // URL da nuvem (Supabase Storage ou qualquer link HTTP)
      return Image.network(
        url,
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: double.infinity,
          height: 300,
          color: Colors.grey.shade200,
          child: const Icon(Icons.pets, size: 80, color: Colors.grey),
        ),
      );
    } else if (kIsWeb) {
      // Caminho relativo rodando na Web
      return Image.network(
        url,
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: double.infinity,
          height: 300,
          color: Colors.grey.shade200,
          child: const Icon(Icons.pets, size: 80, color: Colors.grey),
        ),
      );
    } else {
      // Caminho local legado (Windows/Android/iOS)
      return Image.file(
        File(url),
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: double.infinity,
          height: 300,
          color: Colors.grey.shade200,
          child: const Icon(Icons.pets, size: 80, color: Colors.grey),
        ),
      );
    }
  }

  Future<void> _abrirWhatsApp(BuildContext context) async {
    final telefone = _normalizarTelefoneWhatsApp(pet.telefoneContato);

    if (telefone == null) {
      _mostrarMensagem(context, 'Telefone de contato inválido.');
      return;
    }

    final mensagem = Uri.encodeComponent(
      'Olá! Vi o anúncio do pet ${pet.nome} no AcheiPet e gostaria de conversar.',
    );
    final uri = Uri.parse('https://wa.me/$telefone?text=$mensagem');

    final abriu = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    ).catchError((_) => false);

    if (!abriu && context.mounted) {
      _mostrarMensagem(context, 'Não foi possível abrir o WhatsApp.');
    }
  }

  String? _normalizarTelefoneWhatsApp(String telefone) {
    var digitos = telefone.replaceAll(RegExp(r'\D'), '');
    digitos = digitos.replaceFirst(RegExp(r'^0+'), '');

    if (digitos.isEmpty) return null;

    if (digitos.length == 10 || digitos.length == 11) {
      digitos = '55$digitos';
    }

    if (digitos.length < 12 || digitos.length > 13) return null;
    return digitos;
  }

  void _mostrarMensagem(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    final isPerdido = pet.status == StatusPet.PERDIDO;

    return Scaffold(
      backgroundColor: Cores.corFundo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalhes do Pet',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _carregarImagem(pet.imagemUrl),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          pet.nome,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isPerdido
                              ? Cores.vermehoPerdido
                              : Cores.verdeEncontrado,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isPerdido ? 'Perdido' : 'Encontrado',
                          style: const TextStyle(
                            color: Cores.branco,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _buildLocalizacaoSection(),

                  const SizedBox(height: 16),

                  _buildInfoSection(
                    icon: Icons.description_outlined,
                    titulo: 'Descrição',
                    conteudo: pet.descricao,
                  ),

                  const SizedBox(height: 16),

                  _buildInfoSection(
                    icon: Icons.pets_outlined,
                    titulo: 'Raça',
                    conteudo:
                        pet.raca ??
                        'Não informada', // Lidando com a possibilidade de null
                  ),

                  const SizedBox(height: 16),

                  _buildInfoSection(
                    icon: Icons.perm_identity,
                    titulo: 'Nome do Dono / Responsável',
                    conteudo: pet.nomeDono,
                  ),

                  const SizedBox(height: 16),

                  _buildInfoSection(
                    icon: Icons.phone_android_outlined,
                    titulo: 'Telefone para Contato',
                    conteudo: pet.telefoneContato, // Exibindo o novo campo
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Funcionalidade de compartilhamento em desenvolvimento',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Compartilhar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _abrirWhatsApp(context),
                          icon: const Icon(Icons.chat),
                          label: const Text('Contatar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Cores.botaoGeral,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalizacaoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on_outlined, color: Cores.botaoGeral, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Localização',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (pet.latitude != null && pet.longitude != null)
          Container(
            height: 200,
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(pet.latitude!, pet.longitude!),
                  initialZoom: 15.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.acheipet',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(pet.latitude!, pet.longitude!),
                        width: 60,
                        height: 60,
                        alignment: Alignment.topCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.red,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: pet.imagemUrl.startsWith('http')
                                    ? Image.network(
                                        pet.imagemUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  color: Colors.white,
                                                  child: const Icon(
                                                    Icons.pets,
                                                    color: Colors.red,
                                                    size: 20,
                                                  ),
                                                ),
                                      )
                                    : Container(
                                        color: Colors.white,
                                        child: const Icon(
                                          Icons.pets,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                      ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.red,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        else
          Text(
            pet.localizacao.isNotEmpty
                ? pet.localizacao
                : 'Localização não informada no mapa',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
      ],
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String titulo,
    required String conteudo,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Cores.botaoGeral, size: 20),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          conteudo,
          style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
        ),
      ],
    );
  }
}
