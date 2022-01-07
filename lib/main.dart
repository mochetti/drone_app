import 'dart:async';
import 'package:drone/Screens/menu.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:drone/Utils/websocket.dart';
import 'package:drone/Screens/joystick.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:Tampi/Screens/instrucoesConexaoPage.dart';
import 'package:drone/Utils/round_button.dart';
// import 'package:Tampi/Utils/Animations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      home: const Home(),
      routes: <String, WidgetBuilder>{
        // '/logo': (BuildContext context) => new LogoAnimator(),
        '/home': (BuildContext context) => Home(),
        '/menu': (BuildContext context) => MenuPage(),
        '/joystick': (BuildContext context) => JoystickPage(),
      },
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> with SingleTickerProviderStateMixin {
  bool conectado = false;
  bool conectando = false;
  WebSocketsNotifications sockets = WebSocketsNotifications();
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final NetworkInfo _networkInfo = NetworkInfo();

  @override
  void initState() {
    super.initState();
    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    sockets.removeListener(_onMessageReceived);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onMessageReceived('welcome'),
        child: const Icon(Icons.wifi),
      ),
      body: Center(
        child: _buildConnectButton(),
      ),
    );
  }

  Widget _buildConnectButton() {
    return roundButton(
      text: 'Connect',
      height: 100,
      onClick: () async {
        print('conectando...');
        // checa se estamos num wifi
        var connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult != ConnectivityResult.wifi) {
          // nao estamos no wifi
          print('nao estamos no wifi');
          faltaConectar();
          return;
        }

        // estamos no wifi
        var ssid = await _networkInfo.getWifiName();
        // checa se estamos no wifi correto
        if (ssid == 'kkkk') {
          // está retornado null sempre
          print('rede errada');
          print(ssid);
          faltaConectar();
          return;
        } else {
          // tenta abrir o websocket
          print('tentando conectar');
          sockets.initCommunication();
          print('oi');
          sockets.addListener(_onMessageReceived);
          // debug
          // _onMessageReceived('welcome');
        }
      },
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status');
      print(e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  void faltaConectar() {
    print('falta conectar');
    // Navigator.pop(context);
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => instrucoesConexao(),
    //   ),
    // );
  }

  void _onMessageReceived(message) {
    // verifica se a msg é pra mim
    if (message.toString() == 'welcome') {
      Navigator.pushNamed(context, "/joystick");
    } else if (message.toString() == 'erro') {
      sockets.removeListener(_onMessageReceived);
      faltaConectar();
    }
  }
}
