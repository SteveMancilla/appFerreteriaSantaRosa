// lib/screens/recomendaciones_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RecomendacionesScreen extends StatefulWidget {
  final List<String> productosComprados;

  const RecomendacionesScreen({Key? key, required this.productosComprados}) : super(key: key);

  @override
  State<RecomendacionesScreen> createState() => _RecomendacionesScreenState();
}

class _RecomendacionesScreenState extends State<RecomendacionesScreen> {
  List<String> recomendaciones = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    obtenerRecomendaciones();
  }

  Future<void> obtenerRecomendaciones() async {
    try {
      final url = Uri.parse('http://10.0.2.2:5000/recomendar');
      print('Productos enviados: ${widget.productosComprados}');
      final respuesta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'productos': widget.productosComprados}),
      );

      if (respuesta.statusCode == 200) {
        final data = jsonDecode(respuesta.body);
        setState(() {
          recomendaciones = List<String>.from(data['recomendaciones']);
          cargando = false;
        });
      } else {
        setState(() {
          cargando = false;
        });
      }
    } catch (e) {
      print('Error al obtener recomendaciones: $e');
      setState(() {
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recomendaciones'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 2,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : recomendaciones.isEmpty
              ? const Center(
                  child: Text(
                    'No hay recomendaciones disponibles',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: recomendaciones.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: Icon(Icons.recommend, color: Colors.white),
                        ),
                        title: Text(
                          recomendaciones[index],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}