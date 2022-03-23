import 'dart:convert';

import 'package:crypto_price/constantes.dart';
import 'package:crypto_price/controllers/moneda_controller.dart';
import 'package:http/http.dart';

import '../models/moneda.dart';

Future<void> peticionCryptoCompare(MonedaController monedaControlador) async {
  final Map<String, String> parametrosPeticion = {
    'api_key': API_KEY,
    'fsym': monedaControlador.moneda.codigo,
    'tsyms': 'EUR,USD,GBP'
  };

  Uri url = Uri.https(BASE_URL, RUTA, parametrosPeticion);

  Response res = await get(url);

//si la respuesta http tiene un codigo correcto
  if (res.statusCode == 200) {
    Map<String, dynamic> body = jsonDecode(res.body);

    print(res.body);

    monedaControlador.setEur(body['EUR']);
    monedaControlador.setUsd(body['USD']);
    monedaControlador.setGbp(body['GBP']);
  } else {
    print("ERROR DE CONEXION API");
  }
}

Future<bool> comprobarExistenciaMoneda(Moneda moneda) async {
  final Map<String, String> parametrosPeticion = {
    'api_key': API_KEY,
    'fsym': moneda.codigo,
    'tsyms': 'EUR,USD,GBP'
  };
  var url = Uri.https(BASE_URL, RUTA, parametrosPeticion);

  Response res = await get(url);

  if (res.statusCode == 200) {
    Map<String, dynamic> body = jsonDecode(res.body);

    if (body.containsKey('Response') && body['Response'] == "Error") {
      return false;
    }

    return true;
  } else {
    print("ERROR DE CONEXION API");
    return false;
  }
}
