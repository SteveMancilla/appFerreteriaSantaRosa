import 'package:flutter/material.dart';

class ConfirmacionCompraScreen extends StatelessWidget {
  const ConfirmacionCompraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1FA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
              const SizedBox(height: 20),
              const Text(
                '¡Compra realizada con éxito!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Gracias por tu compra. Puedes ver los detalles en tu historial.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF031059),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Volver al Inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}