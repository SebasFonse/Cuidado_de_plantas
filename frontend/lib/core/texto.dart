/// Pasa a minúsculas y quita tildes para comparar textos.
String normalizarTexto(String valor) {
  const conTilde = 'áàäâéèëêíìïîóòöôúùüûñ';
  const sinTilde = 'aaaaeeeeiiiioooouuuun';
  final buffer = StringBuffer();
  for (final letra in valor.trim().toLowerCase().split('')) {
    final i = conTilde.indexOf(letra);
    buffer.write(i >= 0 ? sinTilde[i] : letra);
  }
  return buffer.toString();
}
