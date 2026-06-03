import 'dart:io';
import 'package:flutter/foundation.dart'; // Necessário para usar o kIsWeb
import 'package:achei_pet/utils/cores.dart';
import 'package:flutter/material.dart';
import 'package:achei_pet/models/pet.dart';
import 'package:geolocator/geolocator.dart';

class CardPet extends StatelessWidget {
  final Pet pet;
  final VoidCallback? onVerDetalhes;
  final double? usuarioLatitude;
  final double? usuarioLongitude;

  const CardPet({
    super.key,
    required this.pet,
    required this.onVerDetalhes,
    this.usuarioLatitude,
    this.usuarioLongitude,
  });

  // Função inteligente para carregar a imagem dependendo da origem
  Widget _carregarImagem(String url) {
    // Tratamento de erro caso a URL venha vazia por algum motivo
    if (url.isEmpty) {
      return Container(
        width: 110,
        height: 130,
        color: Colors.grey.shade200,
        child: const Icon(Icons.pets, size: 40, color: Colors.grey),
      );
    }

    // Se for um pet do mock original (asset)
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: 110,
        height: 130,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 110,
          height: 130,
          color: Colors.grey.shade200,
          child: const Icon(Icons.pets, size: 40, color: Colors.grey),
        ),
      );
    }
    // Se for uma URL da nuvem (Supabase Storage ou qualquer link HTTP)
    else if (url.startsWith('http')) {
      return Image.network(
        url,
        width: 110,
        height: 130,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 110,
          height: 130,
          color: Colors.grey.shade200,
          child: const Icon(Icons.pets, size: 40, color: Colors.grey),
        ),
      );
    }
    // Se for um pet cadastrado localmente rodando na Web (Edge/Chrome)
    else if (kIsWeb) {
      return Image.network(
        url,
        width: 110,
        height: 130,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 110,
          height: 130,
          color: Colors.grey.shade200,
          child: const Icon(Icons.pets, size: 40, color: Colors.grey),
        ),
      );
    }
    // Se for um pet cadastrado localmente rodando no Windows/Android/iOS (caminho local legado)
    else {
      return Image.file(
        File(url),
        width: 110,
        height: 130,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 110,
          height: 130,
          color: Colors.grey.shade200,
          child: const Icon(Icons.pets, size: 40, color: Colors.grey),
        ),
      );
    }
  }

  String _obterTextoDistancia() {
    if (pet.latitude != null &&
        pet.longitude != null &&
        usuarioLatitude != null &&
        usuarioLongitude != null) {
      final distancia = Geolocator.distanceBetween(
        usuarioLatitude!,
        usuarioLongitude!,
        pet.latitude!,
        pet.longitude!,
      );

      if (distancia < 1000) {
        return 'A ${distancia.round()} m de você';
      }

      return 'A ${(distancia / 1000).toStringAsFixed(1)} km de você';
    }

    return pet.localizacao.isNotEmpty
        ? pet.localizacao
        : 'Localização desconhecida';
  }

  @override
  Widget build(BuildContext context) {
    final isPerdido = pet.status == StatusPet.PERDIDO;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              // Substituí o Image.asset pela função inteligente
              child: _carregarImagem(pet.imagemUrl),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
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
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Cores.iconesOpacos,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _obterTextoDistancia(),
                          style: const TextStyle(color: Cores.cinza),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    pet.descricao,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: onVerDetalhes,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Cores.botaoGeral,
                      ),
                      child: const Text(
                        'Ver Detalhes',
                        style: TextStyle(
                          color: Cores.branco,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
