import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

      await FirebaseFirestore.instance.collection('usuarios').doc(cred.user!.uid).set({
        'nombres': nombre,
        'apellidos': apellido,
        'correo': correo,
        'imagenUrl': null, // no se usa imagen personalizada
      });

      Navigator.pushReplacementNamed(context, '/home');
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
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFF8D6AD9),
                    child: Icon(Icons.person, size: 60, color: Colors.white),
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