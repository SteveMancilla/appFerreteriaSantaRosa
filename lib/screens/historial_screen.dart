import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  String? rutaImagen;

  @override
  void initState() {
    super.initState();
    cargarImagenPerfil();
  }

  Future<void> cargarImagenPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      rutaImagen = prefs.getString('ultimaImagen');
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F1FA),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color(0xFF031059),
        title: const Text('Historial de Compras', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        actions: [
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/perfil');
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: rutaImagen != null && rutaImagen!.isNotEmpty
                    ? FileImage(File(rutaImagen!))
                    : const AssetImage('assets/images/usuario.png') as ImageProvider,
              ),
            ),
          ),
        ],
      ),
      body: uid == null
          ? const Center(child: Text('No has iniciado sesión.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc(uid)
                  .collection('compras')
                  .orderBy('fecha', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Aún no tienes compras registradas',
                        style: TextStyle(fontSize: 16, color: Colors.black54)),
                  );
                }

                final compras = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: compras.length,
                  itemBuilder: (context, index) {
                    final data = compras[index].data() as Map<String, dynamic>;
                    final productos = List<Map<String, dynamic>>.from(data['productos'] ?? []);
                    final fecha = (data['fecha'] as Timestamp).toDate();
                    final total = data['total'] ?? 0.0;

                    return ExpansionTile(
                      backgroundColor: const Color(0xFFFFFFFF),
                      collapsedBackgroundColor: const Color(0xFFE8E6F1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      title: Text(
                        'Compra del ${fecha.day}/${fecha.month}/${fecha.year}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Total: S/. ${total.toStringAsFixed(2)}'),
                      children: productos.map((producto) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(producto['imagenUrl']),
                          ),
                          title: Text(producto['nombre']),
                          subtitle: Text('Cantidad: ${producto['cantidad']}'),
                          trailing: Text('S/. ${producto['precio'].toStringAsFixed(2)}'),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // ← porque estamos en Historial Compras
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/productos');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/ubicacion');
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