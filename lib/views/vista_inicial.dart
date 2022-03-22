import 'dart:async';
import 'dart:math';
import 'package:ejemplo_api_crypto/models/moneda.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../constantes.dart';
import '../controllers/moneda_controller.dart';

class VistaInicio extends StatefulWidget {
  const VistaInicio({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<VistaInicio> createState() => VistaInicioEstado();
}

class VistaInicioEstado extends State<VistaInicio> {
  final int TIEMPO_ACTUALIZACION = 1000;

  List<MonedaController> monedasControladores = [];

  bool visibilidadMenu = false;

  TextEditingController controladorInputTextoMenu = TextEditingController();

  FocusNode focusTextFieldBuscarCryptos = FocusNode();

  VistaInicioEstado() {
    iniciar();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    focusTextFieldBuscarCryptos.dispose();

    super.dispose();
  }

  void iniciar() {
    monedasControladores.add(MonedaController(
        Moneda("Bitcoin", "BTC", Colors.amber, Colors.black), this));
    monedasControladores.add(MonedaController(
        Moneda("Ethereum", "ETH", Colors.blue, Colors.black), this));
  }

  void addMoneda() {
    setState(() {
      visibilidadMenu = true;
    });

    ponerFocoEnTextFieldBuscarCryptos();
  }

  void toqueAreaPrincipal() {
    if (visibilidadMenu) {
      setState(() {
        visibilidadMenu = false;
      });
    }
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensaje),
    ));
  }

  void insertarNuevaMoneda() {
    String codigo = controladorInputTextoMenu.text;

    Color colorBackground = generarColorFondoRandom();

    Color colorForeground = decidirColorTexto(colorBackground);

    MonedaController nuevaMoneda = MonedaController(
        Moneda(codigo.toUpperCase(), codigo.toUpperCase(), colorBackground,
            colorForeground),
        this);

    Future<bool> promesa = nuevaMoneda.comprobarExistenciaCodigo();

    promesa.then((bool valor) {
      //se comprueba si existe
      if (valor) {
        //se llama al rebuild de la interfaz
        setState(() {
          //se borra el contenido input
          controladorInputTextoMenu.clear();
          //se cierra el menu de añadir
          visibilidadMenu = false;
          //se añade la nueva moneda
          monedasControladores.add(nuevaMoneda);
        });

        mostrarMensaje("Added correctly.");
      } else {
        mostrarMensaje("There is no cryptocurrency with this code.");
      }
    }).catchError((error) {
      mostrarMensaje("Connection error.");
    });
  }

//genera un color random
  Color generarColorFondoRandom() {
    return Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

  Color decidirColorTexto(Color color) {
    if ((color.red * 0.299 + color.green * 0.587 + color.blue * 0.114) > 186) {
      return Colors.black;
    }

    return Colors.white;
  }

  bool decidirTipoColorTexto(Color color) {
    if ((color.red * 0.299 + color.green * 0.587 + color.blue * 0.114) > 186) {
      return true;
    }

    return false;
  }

  void ponerFocoEnTextFieldBuscarCryptos() {
    focusTextFieldBuscarCryptos.requestFocus();
  }

  final TextStyle ESTILO_VALOR_MONEDA =
      const TextStyle(fontSize: 22, fontWeight: FontWeight.w600);

  final TextStyle ESTILO_CABECERA_ASSET_VALUE =
      const TextStyle(fontSize: 17, fontWeight: FontWeight.w700);

  final TextStyle ESTILO_TEXTOS_ASSET_VALUE =
      const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);

  final TextStyle ESTILO_TOTAL =
      const TextStyle(fontSize: 18, fontWeight: FontWeight.w700);

  final TextStyle ESTILO_TOTAL_VALOR =
      const TextStyle(fontSize: 26, fontWeight: FontWeight.w900);

  final TextStyle ESTILO_TOTAL_VALOR_DESPLEGABLE =
      const TextStyle(fontSize: 23, fontWeight: FontWeight.w900);

  @override
  Widget build(BuildContext context) {
    //se inicializa la lista de elementos cripto vacía en cada build
    List<Widget> hijosColumnaPrincipal = [];

    //se generan con las monedas existentes en el array de monedas
    monedasControladores.forEach((monedaControlador) {
      hijosColumnaPrincipal
          .add(crearFilaElementoCriptoMoneda(monedaControlador));
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Price',
            style: TextStyle(color: colorSecundario)),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: toqueAreaPrincipal,
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  key: UniqueKey(),
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: hijosColumnaPrincipal,
                ),
              ),
            ),
          ),
          Visibility(
              visible: visibilidadMenu,
              child: Container(
                width: double.infinity,
                height: 80.0,
                color: const Color.fromARGB(240, 100, 100, 100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "CODE : ",
                      style: TextStyle(fontSize: 25, color: colorPrincipal),
                    ),
                    Container(
                      width: 150.0,
                      height: 30.0,
                      child: TextField(
                        controller: controladorInputTextoMenu,
                        focusNode: focusTextFieldBuscarCryptos,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          color: colorPrincipal,
                        ),
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: colorPrincipal),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: colorPrincipal),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: insertarNuevaMoneda,
                      icon: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromARGB(100, 116, 106, 106),
                            border:
                                Border.all(width: 2.3, color: colorPrincipal)),
                        child: const Icon(Icons.add),
                      ),
                      color: colorPrincipal,
                    )
                  ],
                ),
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: addMoneda,
        heroTag: null,
      ),
    );
  }

  Padding crearFilaElementoCriptoMoneda(MonedaController monedaControlador) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //contenedor de capa que contiene a todos
          crearContenedorCriptoMoneda(monedaControlador),
        ],
      ),
    );
  }

  Widget crearContenedorCriptoMoneda(MonedaController monedaControlador) {
    //spinner
    var spinkit = SpinKitSpinningCircle(
      color: monedaControlador.moneda.colorForeground,
      size: 20.0,
    );

    Icon icono;

    void Function() funcionOnPressBotonMultiple;

    Color colorCajaIcono;

    Text textoTitulo = (true)
        ? Text(
            monedaControlador.moneda.codigo,
            style: const TextStyle(
                fontSize: 30, fontWeight: FontWeight.w900, color: Colors.black),
          )
        : Text(
            monedaControlador.moneda.codigo,
            style: const TextStyle(
                fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white),
          );

    if (!monedaControlador.modoEliminar) {
      colorCajaIcono = Color.fromARGB(255, 136, 125, 125);
      icono = Icon(
        Icons.refresh,
        color: monedaControlador.moneda.colorForeground,
      );

      funcionOnPressBotonMultiple = monedaControlador.actualizar;
    } else {
      colorCajaIcono = const Color.fromARGB(255, 209, 17, 17);
      icono = const Icon(
        Icons.delete_forever,
        color: Colors.white,
      );

      funcionOnPressBotonMultiple = monedaControlador.eliminarElemento;
    }

    return GestureDetector(
      onLongPress: monedaControlador.cambiarModoEliminar,
      child: Container(
        width: 270,
        height: 290,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: monedaControlador.moneda.colorIdentificador,
            border: Border.all(width: 2.6, color: Colors.black)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: const Border(
                        bottom: BorderSide(width: 2, color: Colors.black)),
                    color: monedaControlador.moneda.colorIdentificador,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 5,
                          child: Container(
                            height: double.infinity,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                border: Border(
                              right:
                                  BorderSide(width: 3.0, color: Colors.black),
                            )),
                            child: textoTitulo,
                          )),
                      Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: IconButton(
                                      onPressed: funcionOnPressBotonMultiple,
                                      icon: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: colorCajaIcono,
                                            border: Border.all(
                                                width: 2.3,
                                                color: monedaControlador
                                                    .moneda.colorForeground)),
                                        child: icono,
                                      ))),
                              if (monedaControlador.modoEliminar)
                                Expanded(
                                    flex: 2,
                                    child: IconButton(
                                        onPressed: monedaControlador
                                            .cerrarModoEliminar,
                                        icon: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Color.fromARGB(
                                                  255, 67, 153, 34),
                                              border: Border.all(
                                                  width: 2.3,
                                                  color: monedaControlador
                                                      .moneda.colorForeground)),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                          ),
                                        ))),
                              Visibility(
                                  visible: monedaControlador.cargando,
                                  child: Expanded(
                                    flex: 2,
                                    child: spinkit,
                                  ))
                            ],
                          )),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Color.fromARGB(255, 242, 245, 198),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!monedaControlador.modoEliminar)
                          Text(monedaControlador.eurLab,
                              style: ESTILO_VALOR_MONEDA),
                        if (!monedaControlador.modoEliminar)
                          Text(
                              monedaControlador
                                  .simboloDivisaSeleccionadaPrecioUnitario,
                              style: ESTILO_VALOR_MONEDA),
                        if (monedaControlador.modoEliminar)
                          Text(monedaControlador.moneda.codigo + " TO  ",
                              style: ESTILO_VALOR_MONEDA),
                        if (monedaControlador.modoEliminar)
                          DropdownButton(
                            value: monedaControlador
                                .simboloDivisaSeleccionadaPrecioUnitario,
                            icon: Icon(Icons.keyboard_arrow_down),
                            items: MonedaController.LISTA_SIMBOLOS
                                .map((String items) {
                              return DropdownMenuItem(
                                  value: items,
                                  child: Text(
                                    items,
                                    style: ESTILO_VALOR_MONEDA,
                                  ));
                            }).toList(),
                            onChanged: monedaControlador
                                .eventoCambioSeleccionDivisaPrecioUnitaro,
                          )
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 226, 226, 183),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 13, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "ASSET VALUE",
                                style: ESTILO_CABECERA_ASSET_VALUE,
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 17, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "AMOUNT : ",
                                style: ESTILO_TEXTOS_ASSET_VALUE,
                              ),
                              if (!monedaControlador.modoEliminar)
                                Text(
                                  monedaControlador.amountLab,
                                  style: ESTILO_CABECERA_ASSET_VALUE,
                                )
                              else
                                SizedBox(
                                  width: 100,
                                  height: 20,
                                  child: TextField(
                                      controller: monedaControlador
                                          .controladorInputTextoAmount,
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(
                                          fontSize: 20.0, color: Colors.black)),
                                )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "TOTAL : ",
                                style: ESTILO_TOTAL,
                              ),
                              if (!monedaControlador.modoEliminar)
                                Text(
                                  monedaControlador.totalLab,
                                  style: ESTILO_TOTAL_VALOR,
                                ),
                              if (monedaControlador.modoEliminar)
                                DropdownButton(
                                  value: monedaControlador
                                      .simboloDivisaSeleccionadaTotal,
                                  icon: Icon(Icons.keyboard_arrow_down),
                                  items: MonedaController.LISTA_SIMBOLOS
                                      .map((String items) {
                                    return DropdownMenuItem(
                                        value: items,
                                        child: Text(
                                          items,
                                          style: ESTILO_TOTAL_VALOR_DESPLEGABLE,
                                        ));
                                  }).toList(),
                                  onChanged: monedaControlador
                                      .eventoCambioSeleccionDivisaPrecioTotal,
                                )
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
