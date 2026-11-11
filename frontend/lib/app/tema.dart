import 'package:flutter/material.dart';

/// Paleta de Plantacert AI (la misma de la versión web en React).
const Color verdeOscuro = Color(0xFF1B4332);
const Color verdePlantacert = Color(0xFF2D6A4F);
const Color verdeMedio = Color(0xFF40916C);
const Color verdeClaro = Color(0xFF74C69D);
const Color verdeSuave = Color(0xFFD8F3DC);

const Color colorFondo = Color(0xFFF8FAF8);
const Color colorSuperficie = Colors.white;
const Color colorBorde = Color(0xFFE2EDE5);
const Color colorTexto = Color(0xFF1A2A1D);
const Color colorTextoSuave = Color(0xFF5A7263);

/// Degradado de las imágenes por defecto y de los encabezados.
const LinearGradient degradadoHoja = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFD1FAE5), Color(0xFFA7F3D0)],
);

const LinearGradient degradadoOscuro = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [verdeOscuro, verdePlantacert, verdeMedio],
);

final BorderRadius _radioCampo = BorderRadius.circular(12);

OutlineInputBorder _borde(Color color, [double ancho = 1.5]) => OutlineInputBorder(
      borderRadius: _radioCampo,
      borderSide: BorderSide(color: color, width: ancho),
    );

final ThemeData temaPlantacert = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: verdePlantacert,
    primary: verdePlantacert,
    secondary: verdeMedio,
    surface: colorSuperficie,
  ),
  scaffoldBackgroundColor: colorFondo,
  appBarTheme: const AppBarTheme(
    backgroundColor: colorFondo,
    foregroundColor: verdeOscuro,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: verdeOscuro,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: colorSuperficie,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: _borde(colorBorde),
    enabledBorder: _borde(colorBorde),
    focusedBorder: _borde(verdePlantacert, 2),
    errorBorder: _borde(const Color(0xFFDC2626)),
    focusedErrorBorder: _borde(const Color(0xFFDC2626), 2),
    labelStyle: const TextStyle(color: colorTextoSuave),
    prefixIconColor: verdeMedio,
    suffixIconColor: verdeMedio,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: verdePlantacert,
      foregroundColor: Colors.white,
      minimumSize: const Size(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: verdePlantacert,
      side: const BorderSide(color: verdePlantacert, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: verdePlantacert,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
