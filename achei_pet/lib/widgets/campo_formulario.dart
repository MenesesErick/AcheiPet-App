import 'package:achei_pet/utils/cores.dart';
import 'package:flutter/material.dart';

class CampoFormulario extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CampoFormulario({
    super.key,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Cores.preto,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Cores.iconesOpacos,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0x4D000000), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Cores.botaoGeral, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
