import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:drone/Utils/websocket.dart';
import 'package:flutter/services.dart';

class LineFollowerPage extends StatefulWidget {
  const LineFollowerPage({Key? key}) : super(key: key);

  @override
  _LineFollowerPageState createState() => _LineFollowerPageState();
}

class _LineFollowerPageState extends State<LineFollowerPage> {
  WebSocketsNotifications sockets = WebSocketsNotifications();
  @override
  void initState() {
    sockets.addListener(comandosServidor);
    super.initState();
  }

  @override
  void dispose() {
    sockets.removeListener(comandosServidor);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent,
      appBar: AppBar(
        title: const Text('Joystick'),
      ),
      body: Row(
        children: [
          RotatedBox(
            quarterTurns: 1,
            child: Slider(
              value: 50,
              onChanged: (newValue) {
                Null;
              },
            ),
          ),
        ],
      ),
    );
  }

  void comandosServidor(message) {
    print('servidor diz: ' + message);
  }
}
