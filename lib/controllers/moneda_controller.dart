import 'package:ejemplo_api_crypto/api_utlis/api_calls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../models/moneda.dart';
import '../views/vista_inicial.dart';

class MonedaController {
  final String SIMBOLO_EUR = '€', SIMBOLO_USD = '\$', SIMBOLO_GBP = '£';

  Moneda moneda;

  bool cargando = false;

  //es false si está en modo normal y tru si está en modo eliminar
  bool modoEliminar = false;

  String eurLab = "0.0€";
  String usdLab = "0.0\$";
  String gbpLab = "0.0£";

  VistaInicioEstado vista;

  MonedaController(this.moneda, this.vista);

  void eliminarElemento() {
    vista.setState(() {
      //se elimina esta moneda de la lista de monedas ocn un set state para refrescar la interfaz
      vista.monedasControladores.remove(this);
    });
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
      eurLab = moneda.eur.toString() + SIMBOLO_EUR;
      usdLab = moneda.usd.toString() + SIMBOLO_USD;
      gbpLab = moneda.gbp.toString() + SIMBOLO_GBP;

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
    return comprobarExistenciaMoneda(moneda);
  }

  setEur(num eur) {
    moneda.eur = eur.toDouble();
  }

  setUsd(num usd) {
    moneda.usd = usd.toDouble();
  }

  setGbp(num gbp) {
    moneda.gbp = gbp.toDouble();
  }
}
