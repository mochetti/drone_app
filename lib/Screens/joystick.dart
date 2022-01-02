import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:drone/Utils/websocket.dart';
import 'package:flutter/services.dart';
// import 'package:Tampi/Utils/bottle_cap_button_widget.dart';

class JoystickPage extends StatefulWidget {
  const JoystickPage({Key? key}) : super(key: key);

  @override
  _JoystickPageState createState() => _JoystickPageState();
}

class _JoystickPageState extends State<JoystickPage> {
  WebSocketsNotifications sockets = WebSocketsNotifications();
  @override
  void initState() {
    sockets.addListener(comandosServidor);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.initState();
  }

  @override
  void dispose() {
    sockets.removeListener(comandosServidor);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
          DraggableCard(
            child: Container(
              width: 150.0,
              height: 150.0,
              decoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              child: const Text('Direction'),
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

/// A draggable card that moves back to [Alignment.center] when it's
/// released.
class DraggableCard extends StatefulWidget {
  final Widget child;

  const DraggableCard({Key? key, required this.child}) : super(key: key);

  @override
  _DraggableCardState createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  WebSocketsNotifications sockets = new WebSocketsNotifications();

  /// The alignment of the card as it is dragged or being animated.
  ///
  /// While the card is being dragged, this value is set to the values computed
  /// in the GestureDetector onPanUpdate callback. If the animation is running,
  /// this value is set to the value of the [_animation].
  Alignment _dragAlignment = Alignment.center;

  late Animation<Alignment> _animation;

  /// Calculates and runs a [SpringSimulation].
  void _runAnimation(Offset pixelsPerSecond, Size size) {
    _animation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: Alignment.center,
      ),
    );
    // Calculate the velocity relative to the unit interval, [0,1],
    // used by the animation controller.
    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    _controller.animateWith(simulation);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _controller.addListener(() {
      setState(() {
        _dragAlignment = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onPanDown: (details) {
        _controller.stop();
      },
      onPanUpdate: (details) {
        setState(() {
          _dragAlignment += Alignment(
            details.delta.dx / (size.width / 2),
            details.delta.dy / (size.height / 2),
          );
        });

        double x = details.globalPosition.dx * 100 / size.width;
        double y = details.globalPosition.dy * 100 / size.height;
        double m1;
        double m2;

        if (x > 70) {
          // vira pra direita
          m1 = 700;
          m2 = -700;
        } else if (x < 30) {
          // vira pra direita
          m1 = -700;
          m2 = 700;
        } else {
          m1 = y * -1 * 2046 / 100 + 1023;
          m2 = y * -1 * 2046 / 100 + 1023;
        }

        String s = 'm'; // caracter de inicio de movimento
        s += m1.toStringAsFixed(0);
        s += ':';
        s += m2.toStringAsFixed(0);
        s += 'e';
        print(s);
        sockets.send(s);
      },
      onPanEnd: (details) {
        String s = '';
        s += 'm0:0e';
        print(s);
        sockets.send(s);
        _runAnimation(details.velocity.pixelsPerSecond, size);
      },
      child: Align(
        alignment: _dragAlignment,
        child: Card(
          elevation: 0,
          color: Colors.transparent,
          child: widget.child,
        ),
      ),
    );
  }
}
