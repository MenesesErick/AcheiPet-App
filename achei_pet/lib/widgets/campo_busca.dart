import 'package:achei_pet/utils/cores.dart';
import 'package:flutter/material.dart';

class CampoBusca extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;

  const CampoBusca({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText = 'Buscar por nome, local ou descrição',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Cores.branco,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0x4D000000), width: 1),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Cores.preto,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 18, right: 8),
            child: Icon(Icons.search, size: 42, color: Cores.iconesOpacos),
          ),
          prefixIconConstraints: const BoxConstraints(
            minHeight: 70,
            minWidth: 70,
          ),
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: Cores.iconesOpacos,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 22),
        ),
      ),
    );
  }
}
