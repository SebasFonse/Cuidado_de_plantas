import 'package:flutter/material.dart';

import '../auth/login_pantalla.dart';
import 'tema.dart';

class PlantacertApp extends StatelessWidget {
  const PlantacertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plantacert AI',
      debugShowCheckedModeBanner: false,
      theme: temaPlantacert,
      home: const LoginPantalla(),
    );
  }
}
