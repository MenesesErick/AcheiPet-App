import 'package:achei_pet/utils/cores.dart';
import 'package:flutter/material.dart';
import 'package:achei_pet/models/pet.dart';

class CardPet extends StatelessWidget {
  final Pet pet;
  final VoidCallback? onVerDetalhes;

  const CardPet({super.key, required this.pet, required this.onVerDetalhes});

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
              child: Image.asset(
                pet.imagemUrl,
                width: 110,
                height: 130,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 110,
                  height: 130,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.pets, size: 40, color: Colors.grey),
                ),
              ),
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
                          pet.localizacao,
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
