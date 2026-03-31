import 'package:flutter/material.dart';
import 'package:achei_pet/utils/cores.dart';

enum FiltroPet { TODOS, PERDIDOS, ENCONTRADOS }

class FiltroPets extends StatefulWidget {
  final FiltroPet selecionado;
  final ValueChanged<FiltroPet> onChanged;

  const FiltroPets({
    super.key,
    required this.selecionado,
    required this.onChanged,
  });

  @override
  State<FiltroPets> createState() => _FiltroPetsState();
}

class _FiltroPetsState extends State<FiltroPets> {
  Alignment _getAlignment() => switch (widget.selecionado) {
    FiltroPet.TODOS => Alignment.centerLeft,
    FiltroPet.PERDIDOS => Alignment.center,
    FiltroPet.ENCONTRADOS => Alignment.centerRight,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Cores.botaoFiltroNotSelected,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: _getAlignment(),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: FractionallySizedBox(
              widthFactor: 1 / 3,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Cores.botaoGeral,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Cores.botaoGeral.withOpacity(0.4),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Row(
            children: FiltroPet.values
                .map(
                  (filtro) => Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onChanged(filtro),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Text(
                          _label(filtro),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: widget.selecionado == filtro
                                ? Cores.branco
                                : Cores.branco,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  String _label(FiltroPet f) => switch (f) {
    FiltroPet.TODOS => 'Todos',
    FiltroPet.PERDIDOS => 'Perdidos',
    FiltroPet.ENCONTRADOS => 'Encontrados',
  };
}
