import 'dart:convert';

import 'package:ejemplo_api_crypto/constantes.dart';
import 'package:ejemplo_api_crypto/save_utils/file_handler.dart';

import '../models/moneda.dart';

class SaveController {
  FileHandler manejadorFichero = FileHandler(FICHERO_GUARDADO);

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
    manejadorFichero.escribirFichero(contenidoFichero);
  }

  Future<List<Moneda>> recuperarListaMonedas() async {
    List<Moneda> monedas = [];
    //esperamos a la lectura
    String ficheroCrudo = await manejadorFichero.leerFichero();

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
