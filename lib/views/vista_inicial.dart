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

        mostrarMensaje("Añadida correctamente");
      } else {
        mostrarMensaje("No existe una cryptomoneda con ese código.");
      }
    }).catchError((error) {
      mostrarMensaje("Error de conexion.");
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

  void ponerFocoEnTextFieldBuscarCryptos() {
    focusTextFieldBuscarCryptos.requestFocus();
  }

  final TextStyle estiloTexto = const TextStyle(fontSize: 22);
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

    Color colorCajaIcono = Color.fromARGB(255, 146, 144, 144);

    if (!monedaControlador.modoEliminar) {
      icono = Icon(
        Icons.refresh,
        color: monedaControlador.moneda.colorForeground,
      );

      funcionOnPressBotonMultiple = monedaControlador.actualizar;
    } else {
      icono = Icon(
        Icons.delete_forever,
        color: monedaControlador.moneda.colorForeground,
      );

      funcionOnPressBotonMultiple = monedaControlador.eliminarElemento;
    }

    return GestureDetector(
      onLongPress: monedaControlador.cambiarModoEliminar,
      child: Container(
        width: 250,
        height: 300,
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
                          flex: 10,
                          child: Container(
                            height: double.infinity,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                                border: Border(
                              right:
                                  BorderSide(width: 3.0, color: Colors.black),
                            )),
                            child: Text(
                              monedaControlador.moneda.codigo,
                              style: TextStyle(
                                  color:
                                      monedaControlador.moneda.colorForeground,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          )),
                      Expanded(
                          flex: 9,
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
                                              color: Colors.red,
                                              border: Border.all(
                                                  width: 2.3,
                                                  color: monedaControlador
                                                      .moneda.colorForeground)),
                                          child: const Icon(
                                            Icons.close,
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
                  color: const Color.fromARGB(255, 214, 213, 203),
                  child: Center(
                    child: Text(monedaControlador.eurLab, style: estiloTexto),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: const Color.fromARGB(255, 192, 191, 186),
                  child: Center(
                    child: Text(monedaControlador.usdLab, style: estiloTexto),
                  ),
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 165, 165, 160),
                    ),
                    child: Center(
                      child: Text(monedaControlador.gbpLab, style: estiloTexto),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
