import 'package:flutter/material.dart';

/// Verde institucional de Plantacert AI.
const Color verdePlantacert = Color(0xFF2E7D32);

final ThemeData temaPlantacert = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: verdePlantacert),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
  ),
);
