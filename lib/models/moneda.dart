import 'package:ejemplo_api_crypto/api_utlis/api_calls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../views/vista_inicial.dart';

class Moneda {
  final String SIMBOLO_EUR = '€', SIMBOLO_USD = '\$', SIMBOLO_GBP = '£';

  String nombre;
  String codigo;

  Color colorIdentificador;

  Color colorForeground;

  double eur = 0.0;
  double usd = 0.0;
  double gbp = 0.0;

  bool cargando = false;

  //es false si está en modo normal y tru si está en modo eliminar
  bool modoEliminar = false;

  String eurLab = "0.0€";
  String usdLab = "0.0\$";
  String gbpLab = "0.0£";

  VistaInicioEstado vista;

  Moneda(this.nombre, this.codigo, this.colorIdentificador,
      this.colorForeground, this.vista);

  void toqueBotonMultiple() {
    //si la moneda no está en modo eliminar entonces se atualizará
    if (!modoEliminar) {
      actualizar();
      //se eliminará la moneda
    } else {
      vista.setState(() {
        //se elimina esta moneda de la lista de monedas ocn un set state para refrescar la interfaz
        vista.monedas.remove(this);
      });
    }
  }

  void actualizar() {
    //comienza el spinner de la carga
    vista.setState(() {
      cargando = true;
    });

    Future promesa = peticionCryptoCompare(this);

    promesa.then((value) {
      actualizarVista();
    }).onError((error, stackTrace) {
      vista.mostrarMensaje("Error de conexion.");
    });
  }

  void actualizarVista() {
    vista.setState(() {
      print("Actualizada moneda");
      eurLab = eur.toString() + SIMBOLO_EUR;
      usdLab = usd.toString() + SIMBOLO_USD;
      gbpLab = gbp.toString() + SIMBOLO_GBP;

      cargando = false;
    });
  }

  Future<void> cambiarModoEliminar() async {
    vista.setState(() {
      modoEliminar = true;
    });

    //hacemos vibrar el dipositivo si se puede y tiene soporte para esto
    HapticFeedback.heavyImpact();
  }

  void cerrarModoEliminar() {
    vista.setState(() {
      modoEliminar = false;
    });
  }

  Future<bool> comprobarExistenciaCodigo() async {
    return comprobarExistenciaMoneda(this);
  }

  setEur(num eur) {
    this.eur = eur.toDouble();
  }

  setUsd(num usd) {
    this.usd = usd.toDouble();
  }

  setGbp(num gbp) {
    this.gbp = gbp.toDouble();
  }
}
