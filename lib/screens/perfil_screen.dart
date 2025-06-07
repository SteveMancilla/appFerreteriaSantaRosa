import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String? nombres = '';
  String? apellidos = '';
  String? email = '';
  String? telefono = '';
  String? rutaImagen;
  final TextEditingController _telefonoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user!.uid).get();
    final data = doc.data();

    setState(() {
      nombres = data?['nombres'] ?? '';
      apellidos = data?['apellidos'] ?? '';
      email = data?['correo'] ?? user!.email;
      telefono = data?['telefono'] ?? '';
      rutaImagen = data?['imagenUrl'] ?? prefs.getString('ultimaImagen');
      _telefonoController.text = telefono ?? '';
    });
  }

  Future<void> actualizarTelefono() async {
    final nuevoTelefono = _telefonoController.text.trim();
    if (nuevoTelefono.isNotEmpty) {
      await FirebaseFirestore.instance.collection('usuarios').doc(user!.uid).update({
        'telefono': nuevoTelefono,
      });
      setState(() {
        telefono = nuevoTelefono;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Número actualizado')),
      );
    }
  }

  Future<void> seleccionarNuevaImagen() async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(source: ImageSource.gallery);

    if (imagen != null) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        rutaImagen = imagen.path;
        prefs.setString('ultimaImagen', imagen.path);
      });
      await FirebaseFirestore.instance.collection('usuarios').doc(user!.uid).update({
        'imagenUrl': imagen.path,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1FA),
      body: ListView(
        children: [
          Stack(
            children: [
              Container(
                height: 300,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A00E0), Color(0xFF031059)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                ),
              ),
              Positioned(
                top: 40,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                ),
              ),
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: const Center(
                  child: Text(
                    'Mi Perfil',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                top: 120,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: rutaImagen != null && rutaImagen!.isNotEmpty
                              ? FileImage(File(rutaImagen!))
                              : const AssetImage('assets/images/usuario.png') as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: seleccionarNuevaImagen,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, size: 20, color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$nombres $apellidos',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 80),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Correo'),
            subtitle: Text(email ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Nombre'),
            subtitle: Text(nombres ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Apellido'),
            subtitle: Text(apellidos ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Teléfono'),
            subtitle: TextField(
              controller: _telefonoController,
              decoration: const InputDecoration(
                hintText: 'Ingrese su número',
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.phone,
              onSubmitted: (_) => actualizarTelefono(),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.save, color: Colors.green),
              onPressed: actualizarTelefono,
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Redes sociales', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.facebook, size: 30, color: Color(0xFF1877F2)),
              SizedBox(width: 20),
              Icon(Icons.wechat_sharp, size: 30, color: Color(0xFF25D366)),
              SizedBox(width: 20),
              Icon(Icons.library_add, size: 30, color: Color(0xFF0077B5)),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}