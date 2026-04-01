import 'dart:ui';

import 'package:achei_pet/utils/cores.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BotaoFormatado extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final double? largura;
  final double altura;
  final double tamanhoFonte;
  final FontWeight fontWeight;

  const BotaoFormatado({
    super.key,
    required this.texto,
    this.onPressed,
    this.largura,
    this.altura = 44,
    this.tamanhoFonte = 14,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: largura,
      height: altura,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Cores.botaoGeral,
          foregroundColor: Cores.branco,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: tamanhoFonte,
            fontWeight: fontWeight,
            color: Cores.branco,
          ),
        ),
      ),
    );
  }
}
