//Estilo
import 'package:flutter/material.dart';

const String TITULO = "Crypto Price";

const String FICHERO_GUARDADO = "datos.json";

const Color COLOR_PRINCIPAL = Color.fromARGB(255, 126, 126, 126);

const Color COLOR_SECUNDARIO = Color.fromARGB(255, 251, 255, 0);

const Color COLOR_TERCIARIO = Color.fromARGB(240, 26, 149, 87);

//COLORES PREDETERMINADOS MONEDAS
const Map<String, Color> FILTRO_COLORES_MONEDAS = {
  'BTC': Color.fromARGB(255, 242, 169, 0),
  'ETH': Color.fromARGB(255, 236, 240, 241),
  'USDT': Color.fromARGB(255, 80, 175, 149),
  'BNB': Color.fromARGB(255, 240, 185, 11),
  'USDC': Color.fromARGB(255, 39, 117, 202),
  'LUNA': Color.fromARGB(255, 23, 40, 82),
  'ADA': Color.fromARGB(255, 51, 51, 51),
  'SOL': Color.fromARGB(255, 0, 255, 163),
  'AVAX': Color.fromARGB(255, 232, 65, 66),
  'BUSD': Color.fromARGB(255, 240, 185, 11),
  'DOT': Color.fromARGB(255, 230, 0, 122),
  'DOGE': Color.fromARGB(255, 207, 182, 108),
  'SHIB': Color.fromARGB(255, 240, 4, 0),
};

//API
final String BASE_URL = "min-api.cryptocompare.com";

final String RUTA = "/data/price";

final String API_KEY =
    "befd5ffcf30b12c753496144ee50414f6cd7aeba20f1a03eb36ebbd83ecdc721";
