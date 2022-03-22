import 'dart:ui';
import 'package:flutter/material.dart';

enum Divisa { EUR, USD, GBP }

class Moneda {
  String nombre;
  String codigo;

  Color colorIdentificador = Colors.white;

  Color colorForeground;

  double eur = 0.0;
  double usd = 0.0;
  double gbp = 0.0;

  double cantidad = 0.0;

  //por defecto la divisa seleccionada es el dolar
  Divisa divisaSeleccionadaPrecioUnitario = Divisa.USD;

  Divisa divisaSeleccionadaTotal = Divisa.USD;

  //Constroctor para una nueva moneda
  Moneda(
      this.nombre, this.codigo, this.colorIdentificador, this.colorForeground);

  //contructor para una moneda ya existente que se recupera de la serializacion json
  Moneda.fromJson(Map<String, dynamic> json)
      : nombre = json['nombre'],
        codigo = json['codigo'],
        colorIdentificador = fromHex(json['colorIdentificador']),
        colorForeground = fromHex(json['colorForeground']),
        eur = json['eur'],
        usd = json['usd'],
        gbp = json['gbp'],
        cantidad = json['cantidad'],
        divisaSeleccionadaPrecioUnitario =
            Divisa.values[json['divisaSeleccionadaPrecioUnitario']],
        divisaSeleccionadaTotal =
            Divisa.values[json['divisaSeleccionadaTotal']];

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'codigo': codigo,
        'colorIdentificador': colorToHex(colorIdentificador),
        'colorForeground': colorToHex(colorForeground),
        'eur': eur,
        'usd': usd,
        'gbp': gbp,
        'cantidad': cantidad,
        'divisaSeleccionadaPrecioUnitario':
            divisaSeleccionadaPrecioUnitario.index,
        'divisaSeleccionadaTotal': divisaSeleccionadaTotal.index
      };

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String colorToHex(Color color) {
    return '${true ? '#' : ''}'
        '${color.alpha.toRadixString(16).padLeft(2, '0')}'
        '${color.red.toRadixString(16).padLeft(2, '0')}'
        '${color.green.toRadixString(16).padLeft(2, '0')}'
        '${color.blue.toRadixString(16).padLeft(2, '0')}';
  }
}
