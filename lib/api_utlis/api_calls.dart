import 'dart:convert';

import 'package:ejemplo_api_crypto/constantes.dart';
import 'package:ejemplo_api_crypto/models/moneda.dart';
import 'package:http/http.dart';

Future<void> peticionCryptoCompare(Moneda moneda) async {
  final parametrosPeticion = {
    'api_key': API_KEY,
    'fsym': moneda.codigo,
    'tsyms': 'EUR,USD,GBP'
  };
  var url = Uri.https(BASE_URL, RUTA, parametrosPeticion);

  Response res = await get(url);

//si la respuesta http tiene un codigo correcto
  if (res.statusCode == 200) {
    Map<String, dynamic> body = jsonDecode(res.body);

    moneda.setEur(body['EUR']);
    moneda.setUsd(body['USD']);
    moneda.setGbp(body['GBP']);
  } else {
    print("ERROR DE CONEXION API");
  }
}

Future<bool> comprobarExistenciaMoneda(Moneda moneda) async {
  final parametrosPeticion = {
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
