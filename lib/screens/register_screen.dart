import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final correoController = TextEditingController();
  final contraseniaController = TextEditingController();
  bool aceptaCondiciones = false;

  String error = '';
  bool cargando = false;
  XFile? _imagen; // Variable para guardar la imagen seleccionada

  // Método para obtener la ubicación del directorio
  Future<String> _getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Método para guardar la imagen localmente
  Future<void> _guardarImagen() async {
    if (_imagen != null) {
      final path = await _getLocalPath();
      final fileName = DateTime.now().toString() + '.jpg'; // Generar un nombre único
      final file = File('$path/$fileName');

      // Guarda la imagen localmente
      await file.writeAsBytes(await _imagen!.readAsBytes());

      // Aquí puedes guardar la URL local de la imagen en Firestore, si es necesario
      // await FirebaseFirestore.instance.collection('usuarios').doc(userId).update({
      //   'imagenUrl': file.path,
      // });
    }
  }

  // Método para seleccionar la imagen desde la galería
  Future<void> _seleccionarImagen() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagen = pickedFile;  // Actualiza la imagen seleccionada
      });
    }
  }

  // Método para tomar la foto con la cámara
  Future<void> _tomarFoto() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imagen = pickedFile;  // Actualiza la imagen tomada
      });
    }
  }

  Future<void> registrarUsuario() async {
    final nombre = nombreController.text.trim();
    final apellido = apellidoController.text.trim();
    final correo = correoController.text.trim();
    final password = contraseniaController.text.trim();

    if (nombre.isEmpty || apellido.isEmpty || correo.isEmpty || password.isEmpty) {
      setState(() => error = 'Todos los campos son obligatorios');
      return;
    }

    if (!aceptaCondiciones) {
      setState(() => error = 'Debes aceptar los términos');
      return;
    }

    setState(() {
      cargando = true;
      error = '';
    });

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: correo,
        password: password,
      );

      // Guardar imagen si hay
      String? imagenRuta;
      if (_imagen != null) {
        await _guardarImagen();
        imagenRuta = _imagen!.path;
      }

      // Guardar en Firestore
      await FirebaseFirestore.instance.collection('usuarios').doc(cred.user!.uid).set({
        'nombres': nombre,
        'apellidos': apellido,
        'correo': correo,
        'imagenUrl': imagenRuta,
      });

      // Guardar en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ultimaImagen', imagenRuta ?? '');
      await prefs.setString('ultimoCorreo', correo);

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
        setState(() => error = 'Error: ${e.toString()}');
    } finally {
        setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3540),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text('CREAR UNA CUENTA',
                      style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: const Color(0xFF8D6AD9),
                        child: _imagen == null
                            ? const Icon(Icons.person, size: 60, color: Colors.white)
                            : ClipOval(
                                child: Image.file(
                                  File(_imagen!.path),
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: GestureDetector(
                          onTap: () {
                            _seleccionarImagen(); // Llamada a la función de la galería
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 20,
                            child: const Icon(Icons.edit, size: 18, color: Colors.black), // Ícono del lápiz
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            _tomarFoto(); // Llamada a la función para tomar foto con la cámara
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 20,
                            child: const Icon(Icons.camera_alt, size: 18, color: Colors.black), // Ícono de la cámara
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _campo('Nombres', nombreController),
                  const SizedBox(height: 12),
                  _campo('Apellido', apellidoController),
                  const SizedBox(height: 12),
                  _campo('Correo Electrónico', correoController),
                  const SizedBox(height: 12),
                  _campo('Contraseña', contraseniaController, oculto: true),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: aceptaCondiciones,
                        onChanged: (val) => setState(() => aceptaCondiciones = val ?? false),
                        activeColor: const Color(0xFF8D6AD9),
                      ),
                      const Expanded(
                        child: Text(
                          'Acepto las políticas y términos de condiciones',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  if (error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(error, style: const TextStyle(color: Colors.red)),
                    ),
                  ElevatedButton(
                    onPressed: cargando ? null : registrarUsuario,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B735C),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: cargando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Registrarse', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Volver al login
                    },
                    child: const Text(
                      '¿Ya tienes cuenta? Inicia sesión',
                      style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(String label, TextEditingController controller, {bool oculto = false}) {
    return TextField(
      controller: controller,
      obscureText: oculto,
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: Colors.white70,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}