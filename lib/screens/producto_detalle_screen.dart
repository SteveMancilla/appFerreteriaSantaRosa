import 'package:flutter/material.dart';

class ProductoDetalleScreen extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagenUrl;

  const ProductoDetalleScreen({
    super.key,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagenUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nombre),
        backgroundColor: const Color(0xFF031059),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.network(imagenUrl, width: 200, height: 200),
            const SizedBox(height: 20),
            Text('S/. $precio', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(descripcion, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Agregar al Carrito'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF031059),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
