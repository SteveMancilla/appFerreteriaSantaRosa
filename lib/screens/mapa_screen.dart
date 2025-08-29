import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final LatLng ubicacionTienda = const LatLng(-11.202946, -76.286335); // Tu punto fijo
  LatLng? ubicacionUsuario;
  GoogleMapController? _mapController;
  final Set<Marker> _marcadores = {};
  final Set<Polyline> _rutas = {};
  final String apiKey = 'AIzaSyBVJ_C6BY9estDwwvW9BzBQ5iBCn0evpGA'; // <-- Reemplaza con tu API KEY

  @override
  void initState() {
    super.initState();
    _verificarPermisoUbicacion();
  }

  Future<void> _verificarPermisoUbicacion() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      _inicializarMapa();
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso de ubicación denegado')),
      );
    }
  }

  Future<void> _inicializarMapa() async {
    final posicion = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      ubicacionUsuario = LatLng(posicion.latitude, posicion.longitude);

      _marcadores.addAll([
        Marker(
          markerId: const MarkerId('usuario'),
          position: ubicacionUsuario!,
          infoWindow: const InfoWindow(title: 'Tu ubicación'),
        ),
        Marker(
          markerId: const MarkerId('tienda'),
          position: ubicacionTienda,
          infoWindow: const InfoWindow(title: 'Ferretería Santa Rosa'),
        ),
      ]);
    });

    _crearRuta();
  }

  Future<void> _crearRuta() async {
    final puntos = PolylinePoints();

    final resultado = await puntos.getRouteBetweenCoordinates(
      googleApiKey: apiKey,
      request: PolylineRequest(
        origin: PointLatLng(ubicacionUsuario!.latitude, ubicacionUsuario!.longitude),
        destination: PointLatLng(ubicacionTienda.latitude, ubicacionTienda.longitude),
        mode: TravelMode.walking, // como peatón
      ),
    );

    if (resultado.points.isNotEmpty) {
      setState(() {
        _rutas.add(
          Polyline(
            polylineId: const PolylineId('ruta'),
            color: Colors.blue,
            width: 5,
            points: resultado.points.map((e) => LatLng(e.latitude, e.longitude)).toList(),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: const Text('Ubicación de la Tienda', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF031059),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: ubicacionUsuario == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(target: ubicacionUsuario!, zoom: 14),
              markers: _marcadores,
              polylines: _rutas,
              myLocationEnabled: true,
              onMapCreated: (controller) => _mapController = controller,
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // ← porque estamos en Mapas
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/productos');
          } else if (index == 2) {
            // ya estás en mapas
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
