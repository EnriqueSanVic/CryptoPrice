import 'dart:convert';

import 'package:crypto_price/constantes.dart';
import 'package:crypto_price/save_utils/file_handler.dart';

import '../models/moneda.dart';

class SaveController {
  final FileHandler _manejadorFichero = FileHandler(FICHERO_GUARDADO);

  final String SEPARADOR = "#_SEP_#";

  SaveController();

  guardarListaMonedas(List<Moneda> lista) {
    String contenidoFichero = "";
    for (int i = 0; i < lista.length; i++) {
      print(lista[i].toJson());
      contenidoFichero += jsonEncode(lista[i].toJson());

      //en todas las iteraciones menos en la ultima se pone separador para evitar problemas en la recuperacion con el split
      if (i < lista.length - 1) {
        contenidoFichero += SEPARADOR;
      }
    }
    _manejadorFichero.escribirFichero(contenidoFichero);
  }

  Future<List<Moneda>> recuperarListaMonedas() async {
    List<Moneda> monedas = [];
    //esperamos a la lectura
    String ficheroCrudo = await _manejadorFichero.leerFichero();

    print(ficheroCrudo);

    if (ficheroCrudo != "Error" && ficheroCrudo != "") {
      List<String> listaJson = ficheroCrudo.split(SEPARADOR);

      print(listaJson.length);

      Map<String, dynamic> json;

      for (int i = 0; i < listaJson.length; i++) {
        print("Logrado ");
        print(jsonDecode(listaJson[i]));
        json = Map.castFrom(jsonDecode(listaJson[i]));
        monedas.add(Moneda.fromJson(json));
      }
    }

    return monedas;
  }
}
