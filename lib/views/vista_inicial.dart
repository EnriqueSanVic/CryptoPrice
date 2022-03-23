import 'dart:async';
import 'dart:math';
import 'package:crypto_price/models/moneda.dart';
import 'package:crypto_price/save_utils/save_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io' show Platform;

import '../constantes.dart';
import '../controllers/moneda_controller.dart';

class VistaInicio extends StatefulWidget {
  const VistaInicio({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<VistaInicio> createState() => VistaInicioEstado();
}

// se añade la interfaz WidgetsBindingObserver para poder escuchar el ciclo de vida de la vista
class VistaInicioEstado extends State<VistaInicio>
    with WidgetsBindingObserver, WindowListener {
  final int MIN_WIDTH = 1000;

  SaveController guardadoControlador = SaveController();

  List<MonedaController> monedasControladores = [];

  bool visibilidadMenu = false;

  TextEditingController controladorInputTextoMenu = TextEditingController();

  FocusNode focusTextFieldBuscarCryptos = FocusNode();

  VistaInicioEstado();

  @override
  void initState() {
    //se recuperan todas las monedas guardadas
    recuperarEstado();

    super.initState();

    //para que tenga en cuenta los cambio en el ciclo de vida de esta vista
    WidgetsBinding.instance!.addObserver(this);

    if (_isDesktopPlatform()) {
      windowManager.addListener(this);

      windowManager.setPreventClose(true);
    }

    setState(() {});
  }

  bool _isDesktopPlatform() =>
      (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  @override
  void dispose() {
    focusTextFieldBuscarCryptos.dispose();

    //para que deje de tener en cuenta los cambio en el ciclo de vida de esta vista
    WidgetsBinding.instance!.removeObserver(this);

    if (_isDesktopPlatform()) {
      windowManager.removeListener(this);
    }

    guardarEstado();

    super.dispose();
  }

  //Función escuchadora que se llama cuando se produce un cambio en el diclo de vida de la vista
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        recuperarEstado();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        guardarEstado();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  //para plataformas desktop
  @override
  void onWindowClose() async {
    bool _isPreventClose = await windowManager.isPreventClose();
    if (_isPreventClose) {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Are you sure you want to close this window?'),
            actions: [
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () async {
                  guardarEstado();
                  Navigator.of(context).pop();
                  await windowManager.destroy();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void guardarEstado() {
    List<Moneda> listaMonedas = [];

    monedasControladores.forEach((controlador) {
      listaMonedas.add(controlador.moneda);
    });

    print("guardando estado...");
    guardadoControlador.guardarListaMonedas(listaMonedas);
  }

  void recuperarEstado() {
    print("recuperando estado...");
    guardadoControlador.recuperarListaMonedas().then((listaMonedas) {
      setState(() {
        monedasControladores = [];
        for (int i = 0; i < listaMonedas.length; i++) {
          monedasControladores.add(MonedaController(listaMonedas[i], this));
        }
      });
    });
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

    Color? colorBackground = FILTRO_COLORES_MONEDAS[codigo.toUpperCase()];

    if (colorBackground == null) {
      colorBackground = generarColorFondoRandom();
    }

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
          //se añade la nueva moneda al principio
          monedasControladores.insert(0, nuevaMoneda);

          //una vez insertada se empieza actualizar una primera vez
          nuevaMoneda.actualizar();
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
            style: TextStyle(color: COLOR_SECUNDARIO)),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: toqueAreaPrincipal,
            child: SingleChildScrollView(
              child: Center(
                child: Column(
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
                      style: TextStyle(fontSize: 25, color: COLOR_SECUNDARIO),
                    ),
                    SizedBox(
                      width: 150.0,
                      height: 30.0,
                      child: TextField(
                        controller: controladorInputTextoMenu,
                        focusNode: focusTextFieldBuscarCryptos,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          color: COLOR_SECUNDARIO,
                        ),
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: COLOR_SECUNDARIO),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: COLOR_SECUNDARIO),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: insertarNuevaMoneda,
                      iconSize: 40,
                      icon: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromARGB(0, 0, 0, 0),
                            border: Border.all(
                                width: 2.3, color: COLOR_SECUNDARIO)),
                        child: const Icon(
                          Icons.add,
                          size: 35,
                          color: COLOR_SECUNDARIO,
                        ),
                      ),
                      color: COLOR_PRINCIPAL,
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
        backgroundColor: COLOR_PRINCIPAL,
        foregroundColor: COLOR_SECUNDARIO,
        focusColor: COLOR_TERCIARIO,
      ),
    );
  }

  Widget crearFilaElementoCriptoMoneda(MonedaController monedaControlador) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: //contenedor de capa que contiene a todos
              Padding(
            padding: EdgeInsets.only(top: 15, bottom: 15, left: 30, right: 30),
            child: crearContenedorCriptoMoneda(monedaControlador),
          ),
        ),
      ],
    );
  }

  Widget crearContenedorCriptoMoneda(MonedaController monedaControlador) {
    //spinner

    Color colorForeground;
    Text textoTitulo;
    Icon iconoRefrescar;
    Icon iconoEditar;

    if (decidirTipoColorTexto(monedaControlador.moneda.colorIdentificador)) {
      textoTitulo = Text(
        monedaControlador.moneda.codigo,
        style: const TextStyle(
            fontSize: 30, fontWeight: FontWeight.w900, color: Colors.black),
      );
      iconoRefrescar = const Icon(
        Icons.refresh,
        size: 37,
        color: Colors.black,
      );

      iconoEditar = const Icon(
        Icons.edit,
        size: 37,
        color: Colors.black,
      );
      colorForeground = Colors.black;
    } else {
      textoTitulo = Text(
        monedaControlador.moneda.codigo,
        style: const TextStyle(
            fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white),
      );
      iconoRefrescar = const Icon(
        Icons.refresh,
        size: 37,
        color: Colors.white,
      );
      iconoEditar = const Icon(
        Icons.edit,
        size: 37,
        color: Colors.white,
      );
      colorForeground = Colors.white;
    }

    var spinkit = SpinKitSpinningCircle(
      color: colorForeground,
      size: 30.0,
    );

    return GestureDetector(
      onLongPress: monedaControlador.cambiarModoEliminar,
      child: Container(
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
                              if (!monedaControlador.modoEliminar &&
                                  !monedaControlador.cargando)
                                Expanded(
                                    flex: 2,
                                    child: IconButton(
                                        onPressed: monedaControlador.actualizar,
                                        iconSize: 45,
                                        icon: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: const Color.fromARGB(
                                                  255, 136, 125, 125),
                                              border: Border.all(
                                                  width: 2.3,
                                                  color: colorForeground)),
                                          child: iconoRefrescar,
                                        ))),
                              if (!monedaControlador.modoEliminar &&
                                  !monedaControlador.cargando &&
                                  _isDesktopPlatform())
                                Expanded(
                                    flex: 2,
                                    child: IconButton(
                                        onPressed: monedaControlador
                                            .cambiarModoEliminar,
                                        iconSize: 45,
                                        icon: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: const Color.fromARGB(
                                                  255, 136, 125, 125),
                                              border: Border.all(
                                                  width: 2.3,
                                                  color: colorForeground)),
                                          child: iconoEditar,
                                        ))),
                              if (monedaControlador.modoEliminar &&
                                  !monedaControlador.cargando)
                                Expanded(
                                    flex: 2,
                                    child: IconButton(
                                        iconSize: 40,
                                        onPressed:
                                            monedaControlador.eliminarElemento,
                                        icon: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: const Color.fromARGB(
                                                  255, 209, 17, 17),
                                              border: Border.all(
                                                  width: 2.3,
                                                  color: monedaControlador
                                                      .moneda.colorForeground)),
                                          child: const Icon(
                                            Icons.delete_forever,
                                            size: 35,
                                            color: Colors.white,
                                          ),
                                        ))),
                              if (monedaControlador.modoEliminar &&
                                  !monedaControlador.cargando)
                                Expanded(
                                    flex: 2,
                                    child: IconButton(
                                        iconSize: 40,
                                        onPressed: monedaControlador
                                            .cerrarModoEliminar,
                                        icon: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: const Color.fromARGB(
                                                  255, 67, 153, 34),
                                              border: Border.all(
                                                  width: 2.3,
                                                  color: monedaControlador
                                                      .moneda.colorForeground)),
                                          child: const Icon(
                                            Icons.check,
                                            size: 35,
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
                          Text(monedaControlador.valorUnitarioLab,
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
