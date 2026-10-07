import 'package:flutter/material.dart';

void main() {
  runApp(const VidaPlenaApp());
}

class VidaPlenaApp extends StatelessWidget {
  const VidaPlenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VidaPlena Agenda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const Scaffold(),
    );
  }
}
