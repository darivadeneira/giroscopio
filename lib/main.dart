import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // Set dark mode theme
      home: GyroscopeControlPage(),
    );
  }
}

class GyroscopeControlPage extends StatefulWidget {
  @override
  _GyroscopeControlPageState createState() => _GyroscopeControlPageState();
}

class _GyroscopeControlPageState extends State<GyroscopeControlPage> {
  late WebSocketChannel channel;
  double x = 0, y = 0, z = 0;
  String commandSent = '';
  String commandReceived = '';
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
    gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        x = event.x;
        y = event.y;
        z = event.z;
      });
      _sendCommandBasedOnGyroscope(event);
    });
    channel.stream.listen((message) {
      setState(() {
        commandReceived = message;
      });
    });
  }

  void _connectToWebSocket() async {
    try {
      channel = IOWebSocketChannel.connect(
        Uri.parse('ws://10.40.14.38:12345'),
      );
      setState(() {
        isConnected = true;
      });
    } catch (e) {
      setState(() {
        isConnected = false;
      });
    }
  }

  void _sendCommandBasedOnGyroscope(GyroscopeEvent event) {
    if (event.x > 2) {
      channel.sink.add('OPEN_BROWSER');
      setState(() {
        commandSent = 'OPEN_BROWSER';
      });
    } else if (event.y > 2) {
      channel.sink.add('OPEN_WORD');
      setState(() {
        commandSent = 'OPEN_WORD';
      });
    } else if (event.z > 2) {
      channel.sink.add('PLAY_MEDIA');
      setState(() {
        commandSent = 'PLAY_MEDIA';
      });
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Control con Giroscopio')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rotate_right, size: 50),
            SizedBox(height: 20),
            Text('Giroscopio:'),
            Text('X: ${x.toStringAsFixed(2)}'),
            Text('Y: ${y.toStringAsFixed(2)}'),
            Text('Z: ${z.toStringAsFixed(2)}'),
            SizedBox(height: 20),
            Icon(Icons.send, size: 30),
            Text('Comando Enviado: $commandSent'),
            SizedBox(height: 20),
            Icon(Icons.receipt, size: 30),
            Text('Comando Recibido: $commandReceived'),
            SizedBox(height: 20),
            Text(
              'Mueve el dispositivo para enviar comandos.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            if (isConnected)
              Text(
                'Conectado con éxito!',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              )
            else
              Text(
                'Esperando conexión...',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
