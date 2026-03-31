import 'package:achei_pet/utils/cores.dart';
import 'package:flutter/material.dart';

class TextoFormatado extends StatelessWidget {
  final String texto;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign textAlign;
  
  const TextoFormatado({
    super.key,
    required this.texto,
    this.fontSize = 36,
    this.fontWeight = FontWeight.bold,
    this.color = Cores.fonteTitulo,
    this.textAlign = TextAlign.center
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: 0.3
      ),
    );
  }
}
