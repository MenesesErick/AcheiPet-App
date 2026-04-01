import 'package:achei_pet/utils/cores.dart';
import 'package:flutter/material.dart';

class BotaoStatus extends StatelessWidget {
  final String texto;
  final Color corAtiva;
  final bool isSelected;
  final VoidCallback onTap;

  const BotaoStatus({
    super.key,
    required this.texto,
    required this.corAtiva,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? corAtiva : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? corAtiva : const Color(0x4D000000),
            width: isSelected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          texto,
          style: TextStyle(
            color: isSelected ? Colors.white : Cores.preto,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}