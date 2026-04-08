import 'package:achei_pet/utils/cores.dart';
import 'package:flutter/material.dart';

class ItemMenuPerfil extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final VoidCallback onTap;

  const ItemMenuPerfil({
    super.key,
    required this.icone,
    required this.titulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        tileColor: Colors.white,
        leading: Icon(icone, color: Cores.botaoGeral),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Cores.cinza),
      ),
    );
  }
}