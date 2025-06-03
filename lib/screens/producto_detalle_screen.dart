import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/carrito_provider.dart';
import '../models/carrito_item.dart';

class ProductoDetalleScreen extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagenUrl;
  final bool oferta;
  final int descuento;
  final String? caracteristicas;

  const ProductoDetalleScreen({
    super.key,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagenUrl,
    this.oferta = false,
    this.descuento = 0,
    this.caracteristicas,
  });

  @override
  Widget build(BuildContext context) {
    final double precioFinal = oferta && descuento > 0
        ? precio * (1 - descuento / 100)
        : precio;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF031059),
        title: Text(nombre, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Icono de compartir
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Lógica para compartir
            },
          ),
          // Icono del carrito con el contador
          Consumer<CarritoProvider>(
            builder: (context, carritoProvider, child) {
              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.shopping_cart, color: Colors.white),
                    if (carritoProvider.itemsCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            carritoProvider.itemsCount.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/carrito');
                },
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Image.network(imagenUrl, width: 200, height: 200),
          ),
          const SizedBox(height: 16),
          Text(
            nombre,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          if (oferta && descuento > 0)
            Text(
              'S/. ${precio.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
              ),
            ),

          Text(
            'S/. ${precioFinal.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: oferta && descuento > 0 ? Colors.red : Colors.black,
            ),
          ),

          if (oferta)
            const Text('¡En oferta!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),

          const SizedBox(height: 12),
          Text(
            descripcion,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),

          if (caracteristicas != null && caracteristicas!.isNotEmpty) ...[
            const Text(
              'Características',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(caracteristicas!, style: const TextStyle(fontSize: 15)),
          ],

          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Provider.of<CarritoProvider>(context, listen: false).agregarProducto(
                CarritoItem(
                  nombre: nombre,
                  id: DateTime.now().toString(), // Generar un ID único
                  descripcion: descripcion,
                  imagenUrl: imagenUrl,
                  precio: precioFinal,
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Producto añadido al carrito'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Agregar al Carrito'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF031059),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF031059),
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFFF7F1FA),
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/productos');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/notificaciones');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/ajustes');
          } else if (index == 4) {
            Navigator.pushNamed(context, '/perfil');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.sell), label: 'Productos'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notificaciones'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
