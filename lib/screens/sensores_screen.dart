import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensoresScreen extends StatefulWidget {
  const SensoresScreen({super.key});

  @override
  State<SensoresScreen> createState() => _SensoresScreenState();
}

class _SensoresScreenState extends State<SensoresScreen> {
  String acelerometro = '', giroscopio = '', magnetometro = '', userAccel = '';

  @override
  void initState() {
    super.initState();

    SensorsPlatform.instance.accelerometerEventStream().listen((e) {
      setState(() {
        acelerometro = 'X: ${e.x.toStringAsFixed(2)}  |  Y: ${e.y.toStringAsFixed(2)}  |  Z: ${e.z.toStringAsFixed(2)}';
      });
    });

    SensorsPlatform.instance.gyroscopeEventStream().listen((e) {
      setState(() {
        giroscopio = 'X: ${e.x.toStringAsFixed(2)}  |  Y: ${e.y.toStringAsFixed(2)}  |  Z: ${e.z.toStringAsFixed(2)}';
      });
    });

    SensorsPlatform.instance.magnetometerEventStream().listen((e) {
      setState(() {
        magnetometro = 'X: ${e.x.toStringAsFixed(2)}  |  Y: ${e.y.toStringAsFixed(2)}  |  Z: ${e.z.toStringAsFixed(2)}';
      });
    });

    SensorsPlatform.instance.userAccelerometerEventStream().listen((e) {
      setState(() {
        userAccel = 'X: ${e.x.toStringAsFixed(2)}  |  Y: ${e.y.toStringAsFixed(2)}  |  Z: ${e.z.toStringAsFixed(2)}';
      });
    });
  }

  Widget buildSensorCard(String titulo, String valores, IconData icono, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icono, color: Colors.white),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(valores),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1FA),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color(0xFF031059),
        title: const Text('Sensores del Móvil', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            buildSensorCard('Acelerómetro', acelerometro, Icons.speed, Colors.blueAccent),
            buildSensorCard('Giroscopio', giroscopio, Icons.rotate_90_degrees_ccw, Colors.deepPurple),
            buildSensorCard('Magnetómetro', magnetometro, Icons.explore, Colors.teal),
            buildSensorCard('User Accel', userAccel, Icons.directions_walk, Colors.orange),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // ← porque estamos en Mapas/Sensores
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/productos');
          } else if (index == 2) {
            // ya estás aquí
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/historial');
          } else if (index == 4) {
            Navigator.pushReplacementNamed(context, '/perfil');
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
        selectedItemColor: const Color(0xFF031059),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.sell), label: 'Ofertas'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapas'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial Compras'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}