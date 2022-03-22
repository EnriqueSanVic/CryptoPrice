import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

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

  //contructor para una moneda ya existente que se recupera de la serializacion
  Moneda.fromSerilized(this.nombre, this.codigo, this.colorIdentificador,
      this.colorForeground, this.eur, this.usd, this.gbp);

  Moneda.fromJson(Map<String, dynamic> json)
      : nombre = json['nombre'],
        codigo = json['codigo'],
        colorIdentificador = json['colorIdentificador'],
        colorForeground = json['colorForeground'],
        eur = json['eur'],
        usd = json['usd'],
        gbp = json['gbp'];

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'codigo': codigo,
        'colorIdentificador': colorIdentificador,
        'colorForeground': colorForeground,
        'eur': eur,
        'usd': usd,
        'gbp': gbp,
      };
}
