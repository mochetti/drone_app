import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:drone/Screens/joystick.dart';
import 'package:drone/Screens/line_follower.dart';
import 'package:drone/Utils/round_button.dart';
import 'package:drone/Utils/websocket.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  WebSocketsNotifications sockets = new WebSocketsNotifications();

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Quit'),
            content: const Text('Quit?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  if (sockets.isOn) {
                    print('ws desconectado');
                    tentarReconectar = false;
                    sockets.reset();
                  }
                  Navigator.popUntil(context, ModalRoute.withName('/home'));
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.yellowAccent,
        appBar: AppBar(
          title: const Text('Drone'),
        ),
        body: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(20),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
          children: <Widget>[
            _buildLineFollowerButton(),
            _buildJoystickButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLineFollowerButton() {
    return roundButton(
        text: 'line',
        leadingIcon: const Icon(Icons.line_style),
        leadingIconMargin: 5,
        color: Colors.orange,
        onClick: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const JoystickPage(),
            ),
          );
        });
  }

  Widget _buildJoystickButton() {
    return roundButton(
        text: 'joystick',
        leadingIcon: const Icon(Icons.games),
        leadingIconMargin: 5,
        color: Colors.orange,
        onClick: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const JoystickPage(),
            ),
          );
        });
  }
}
