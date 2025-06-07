import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/carrito_item.dart';
import '../providers/carrito_provider.dart';
import 'producto_detalle_screen.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String tipoSeleccionado = 'Todos';
  bool filtrarOferta = false;

  final List<String> tipos = ['Todos', 'Carpintería', 'Construcción', 'Mecánica', 'Almacenamiento'];
  int currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 218, 204, 228),
      appBar: AppBar(
        backgroundColor: const Color(0xFF031059),
        title: const Text('Listado de Productos', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        actions: [
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 12),
            _buildFiltros(),
            const SizedBox(height: 16),
            Expanded(child: _buildListaProductos()),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
          } else if (index == 2) {
            Navigator.pushNamed(context, '/notificaciones');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/ajustes');
          } else if (index == 4) {
            Navigator.pushNamed(context, '/perfil');
          }
        },
        selectedItemColor: const Color(0xFF031059),
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFFF7F1FA),
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

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: searchController,
        onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
        decoration: const InputDecoration(
          icon: Icon(Icons.search),
          hintText: 'Buscar producto',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: tipoSeleccionado,
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Tipo',
              labelStyle: const TextStyle(color: Colors.black),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: tipos.map((tipo) {
              return DropdownMenuItem(value: tipo, child: Text(tipo));
            }).toList(),
            onChanged: (value) => setState(() => tipoSeleccionado = value!),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          children: [
            Checkbox(
              value: filtrarOferta,
              activeColor: const Color(0xFF8D6AD9),
              onChanged: (value) => setState(() => filtrarOferta = value ?? false),
            ),
            const Text('Oferta', style: TextStyle(color: Color.fromARGB(255, 22, 22, 22))),
          ],
        ),
      ],
    );
  }

  Widget _buildListaProductos() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('productos')
          .where('disponible', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final productos = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final nombre = data['nombre'].toString().toLowerCase();
          final tipo = data['tipo']?.toString().toLowerCase();
          final oferta = data['oferta'] ?? false;

          final coincideBusqueda = nombre.contains(searchQuery);
          final coincideTipo = tipoSeleccionado == 'Todos' || tipo == tipoSeleccionado.toLowerCase();
          final coincideOferta = !filtrarOferta || oferta == true;

          return coincideBusqueda && coincideTipo && coincideOferta;
        }).toList();

        if (productos.isEmpty) {
          return const Center(child: Text('No se encontraron productos', style: TextStyle(color: Colors.white)));
        }

        return GridView.builder(
          padding: const EdgeInsets.only(top: 10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 320,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: productos.length,
          itemBuilder: (context, index) {
            final data = productos[index].data() as Map<String, dynamic>;
            final precio = (data['precio'] as num).toDouble();
            final descuento = (data['descuento'] ?? 0) as int;
            final precioFinal = (descuento > 0) ? precio * (1 - descuento / 100) : precio;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductoDetalleScreen(
                      nombre: data['nombre'],
                      descripcion: data['descripcion'],
                      precio: precio,
                      imagenUrl: 'https://drive.google.com/uc?export=view&id=${data['imagen_drive_id']}',
                      oferta: data['oferta'] ?? false,
                      descuento: descuento,
                      caracteristicas: data['caracteristicas']?.toString(),
                    ),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                color: const Color(0xFFF7F1FA),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'https://drive.google.com/uc?export=view&id=${data['imagen_drive_id']}',
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(data['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(data['descripcion'], maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      if (descuento > 0) ...[
                        Text('S/ ${precio.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            )),
                        Text('S/ ${precioFinal.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      ] else
                        Text('S/ ${precio.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (data['oferta'] == true)
                        const Text('¡En oferta!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          final carrito = Provider.of<CarritoProvider>(context, listen: false);
                          carrito.agregarProducto(
                            CarritoItem(
                              id: data['nombre'],
                              nombre: data['nombre'],
                              descripcion: data['descripcion'],
                              precio: precioFinal,
                              cantidad: 1,
                              imagenUrl: 'https://drive.google.com/uc?export=view&id=${data['imagen_drive_id']}',
                            ),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Producto agregado al carrito')),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Agregar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF031059),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}