import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final correoController = TextEditingController();
  final contraseniaController = TextEditingController();
  bool rememberMe = false;
  String errorMsg = '';
  String? _imagenRuta;

  @override
  void initState() {
    super.initState();
    _cargarImagenYCorreo();
  }

  Future<void> _cargarImagenYCorreo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _imagenRuta = prefs.getString('ultimaImagen');
      correoController.text = prefs.getString('ultimoCorreo') ?? '';
    });
  }

  Future<void> validarLogin() async {
    final correo = correoController.text.trim();
    final contrasenia = contraseniaController.text.trim();

    if (correo.isEmpty || contrasenia.isEmpty) {
      setState(() => errorMsg = 'Todos los campos son obligatorios');
      return;
    }

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: correo,
        password: contrasenia,
      );

      if (credential.user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('ultimoCorreo', correo);
        await prefs.setString('ultimaImagen', _imagenRuta ?? '');
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          errorMsg = 'No existe un usuario con ese correo.';
        } else if (e.code == 'wrong-password') {
          errorMsg = 'Contraseña incorrecta.';
        } else {
          errorMsg = 'Error: ${e.message}';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3540),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                //const Text('BIENVENIDO'),
                //style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 24),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFFF2E205),
                  backgroundImage: _imagenRuta != null && _imagenRuta!.isNotEmpty
                      ? FileImage(File(_imagenRuta!))
                      : null,
                  child: _imagenRuta == null || _imagenRuta!.isEmpty
                      ? const Icon(Icons.person, size: 50, color: Color(0xFF2D3540))
                      : null,
                ),
                const SizedBox(height: 70),
                TextFormField(
                  controller: correoController,
                  decoration: _buildInputDecoration('Correo'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: contraseniaController,
                  obscureText: true,
                  decoration: _buildInputDecoration('Password'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value!;
                        });
                      },
                      activeColor: const Color(0xFF8D6AD9),
                    ),
                    const Text('Recordarme', style: TextStyle(color: Colors.white)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(color: Colors.white, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
                if (errorMsg.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(errorMsg, style: const TextStyle(color: Colors.red)),
                  ),
                ElevatedButton(
                  onPressed: validarLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF031059),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Iniciar sesión', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 24),
                const Text('¿No tienes cuenta?', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B735C),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Registrarse', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),
                const Text('O continúa con', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    FaIcon(FontAwesomeIcons.google, size: 28, color: Colors.white),
                    SizedBox(width: 30),
                    FaIcon(FontAwesomeIcons.apple, size: 28, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}