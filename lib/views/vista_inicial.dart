import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../constantes.dart';
import '../models/moneda.dart';

class VistaInicio extends StatefulWidget {
  const VistaInicio({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<VistaInicio> createState() => VistaInicioEstado();
}

class VistaInicioEstado extends State<VistaInicio> {
  final int TIEMPO_ACTUALIZACION = 1000;

  List<Moneda> monedas = [];

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
    monedas.add(Moneda("Bitcoin", "BTC", Colors.amber, Colors.black, this));
    monedas.add(Moneda("Ethereum", "ETH", Colors.blue, Colors.black, this));
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

    Moneda nuevaMoneda = Moneda(codigo.toUpperCase(), codigo.toUpperCase(),
        colorBackground, colorForeground, this);

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
          monedas.add(nuevaMoneda);
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
    monedas.forEach((moneda) {
      hijosColumnaPrincipal.add(crearFilaElementoCriptoMoneda(moneda));
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

  Padding crearFilaElementoCriptoMoneda(Moneda moneda) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //contenedor de capa que contiene a todos
          crearContenedorCriptoMoneda(moneda),
        ],
      ),
    );
  }

  Widget crearContenedorCriptoMoneda(Moneda moneda) {
    //spinner
    var spinkit = SpinKitSpinningCircle(
      color: moneda.colorForeground,
      size: 20.0,
    );

    Icon icono;
    Color colorCajaIcono = Color.fromARGB(255, 146, 144, 144);

    if (!moneda.modoEliminar) {
      icono = Icon(
        Icons.refresh,
        color: moneda.colorForeground,
      );
    } else {
      icono = Icon(
        Icons.delete_forever,
        color: moneda.colorForeground,
      );
    }

    return GestureDetector(
      onLongPress: moneda.cambiarModoEliminar,
      child: Container(
        width: 200,
        height: 300,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: moneda.colorIdentificador,
            border: Border.all(width: 2.6, color: Colors.black)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: moneda.colorIdentificador,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      moneda.codigo,
                      style: TextStyle(
                          color: moneda.colorForeground, fontSize: 22),
                    ),
                    IconButton(
                        onPressed: moneda.toqueBotonMultiple,
                        icon: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: colorCajaIcono,
                              border: Border.all(
                                  width: 2.3, color: moneda.colorForeground)),
                          child: icono,
                        )),
                    if (moneda.modoEliminar)
                      IconButton(
                          onPressed: moneda.cerrarModoEliminar,
                          icon: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.red,
                                border: Border.all(
                                    width: 2.3, color: moneda.colorForeground)),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          )),
                    Visibility(
                        visible: moneda.cargando,
                        child:
                            spinkit), //la visibilidad del spinnner se controla por la variable cargando
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color.fromARGB(255, 214, 213, 203),
                child: Center(
                  child: Text(moneda.eurLab, style: estiloTexto),
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color.fromARGB(255, 192, 191, 186),
                child: Center(
                  child: Text(moneda.usdLab, style: estiloTexto),
                ),
              ),
            ),
            Expanded(
                child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 165, 165, 160),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
              child: Center(
                child: Text(moneda.gbpLab, style: estiloTexto),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
