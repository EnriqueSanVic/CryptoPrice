import 'package:ejemplo_api_crypto/api_utlis/api_calls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../models/moneda.dart';
import '../views/vista_inicial.dart';

class MonedaController {
  static const String SIMBOLO_EUR = '€', SIMBOLO_USD = '\$', SIMBOLO_GBP = '£';

  static List<String> LISTA_SIMBOLOS = [SIMBOLO_EUR, SIMBOLO_USD, SIMBOLO_GBP];

  Moneda moneda;

  bool cargando = false;

  //es false si está en modo normal y tru si está en modo eliminar
  bool modoEliminar = false;

  String eurLab = "0.0";
  String usdLab = "0.0";
  String gbpLab = "0.0";

  String simboloDivisaSeleccionadaPrecioUnitario = "\$";
  String simboloDivisaSeleccionadaTotal = "\$";

  String amountLab = "0.0";

  String totalLab = "0.0";

  VistaInicioEstado vista;

  TextEditingController controladorInputTextoAmount = TextEditingController();

  MonedaController(this.moneda, this.vista) {
    simboloDivisaSeleccionadaPrecioUnitario =
        getSimboloDivisaSeleccionadaPrecioUnitario();
    simboloDivisaSeleccionadaTotal = getSimboloDivisaSeleccionadaTotal();

    actualizarLabsPreciosUnitarios();

    actualizarAmount();

    actualizarTotal();
  }

  String generarLabValorUnitario(String codigo, double valor) {
    return "1 " + codigo + " = " + valor.toString();
  }

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
      vista.mostrarMensaje("Connection error.");
    }).timeout(const Duration(seconds: 20));
  }

  void actualizarVista() {
    vista.setState(() {
      simboloDivisaSeleccionadaPrecioUnitario =
          getSimboloDivisaSeleccionadaPrecioUnitario();
      simboloDivisaSeleccionadaTotal = getSimboloDivisaSeleccionadaTotal();

      actualizarLabsPreciosUnitarios();
      //se  cambia el valor de las variables que controlan el valor unitario
      actualizarLabsPreciosUnitarios();

      //se cambia el valor de la variable que controla el total
      actualizarTotal();

      //se quita la animación del spinner de carga
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
    String cantidadTexto = controladorInputTextoAmount.text.toString();

    try {
      //se cambian las , por . y se pasa a double
      moneda.cantidad = double.parse(cantidadTexto.replaceAll(",", "."));
    } on FormatException {
      vista.mostrarMensaje("Bad number format.");
    }

    vista.setState(() {
      actualizarAmount();
      actualizarTotal();
      modoEliminar = false;
    });
  }

  Future<bool> comprobarExistenciaCodigo() async {
    return comprobarExistenciaMoneda(moneda);
  }

  String getSimboloDivisaSeleccionadaPrecioUnitario() {
    return _elegirSimboloDivisa(moneda.divisaSeleccionadaPrecioUnitario);
  }

  String getSimboloDivisaSeleccionadaTotal() {
    return _elegirSimboloDivisa(moneda.divisaSeleccionadaTotal);
  }

  String _elegirSimboloDivisa(Divisa divisa) {
    switch (divisa) {
      case Divisa.EUR:
        return SIMBOLO_EUR;
      case Divisa.USD:
        return SIMBOLO_USD;
      case Divisa.GBP:
        return SIMBOLO_GBP;
    }
  }

  double getTotal() {
    switch (moneda.divisaSeleccionadaTotal) {
      case Divisa.EUR:
        return (moneda.cantidad * moneda.eur);
      case Divisa.USD:
        return (moneda.cantidad * moneda.usd);
      case Divisa.GBP:
        return (moneda.cantidad * moneda.gbp);
    }
  }

  void actualizarLabsPreciosUnitarios() {
    eurLab = generarLabValorUnitario(moneda.codigo, moneda.eur);
    usdLab = generarLabValorUnitario(moneda.codigo, moneda.usd);
    gbpLab = generarLabValorUnitario(moneda.codigo, moneda.gbp);
  }

  void actualizarAmount() {
    amountLab = moneda.cantidad.toString() + " " + moneda.codigo;
  }

  void actualizarTotal() {
    totalLab = getTotal().toStringAsFixed(2) +
        " " +
        getSimboloDivisaSeleccionadaTotal();
  }

  void eventoCambioSeleccionDivisaPrecioUnitaro(String? valorSeleccionado) {
    moneda.divisaSeleccionadaPrecioUnitario =
        decidirDivisaSeleccionada(valorSeleccionado!);

    vista.setState(() {
      simboloDivisaSeleccionadaPrecioUnitario =
          getSimboloDivisaSeleccionadaPrecioUnitario();
    });
  }

  void eventoCambioSeleccionDivisaPrecioTotal(String? valorSeleccionado) {
    moneda.divisaSeleccionadaTotal =
        decidirDivisaSeleccionada(valorSeleccionado!);

    vista.setState(() {
      simboloDivisaSeleccionadaTotal = getSimboloDivisaSeleccionadaTotal();
    });
  }

  Divisa decidirDivisaSeleccionada(String simbolo) {
    switch (simbolo) {
      case SIMBOLO_EUR:
        return Divisa.EUR;
      case SIMBOLO_USD:
        return Divisa.USD;
      case SIMBOLO_GBP:
        return Divisa.GBP;
      default:
        return Divisa.USD;
    }
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
