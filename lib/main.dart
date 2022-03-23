import 'package:crypto_price/constantes.dart';
import 'package:flutter/material.dart';
import 'views/vista_inicial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: TITULO,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Color.fromARGB(255, 254, 255, 166),
        colorScheme: const ColorScheme.light(
          primary: COLOR_PRINCIPAL,
          secondary: COLOR_SECUNDARIO,
        ),
      ),
      home: const VistaInicio(title: TITULO),
    );
  }
}
