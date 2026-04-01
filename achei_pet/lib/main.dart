import 'package:flutter/material.dart';
import 'package:achei_pet/telas/tela_principal.dart'; // Importe a nova tela

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TelaPrincipal(), // Substitua HomePage() por TelaPrincipal()
    );
  }
}
