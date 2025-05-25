import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'producto_detalle_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: const Color(0xFF2D3540),
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF031059)),
              child: Text('Menú Principal', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.white),
              title: Text('Inicio', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.white),
              title: Text('Configuración', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF031059),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              controller: searchController,
              onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
              decoration: const InputDecoration(
                icon: Icon(Icons.search),
                hintText: 'Buscar en ferretería',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('PRODUCTOS DESTACADOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          SizedBox(
            height: 220,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('productos')
                  .where('disponible', isEqualTo: true)
                  .where('destacado', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final productos = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['nombre'].toString().toLowerCase().contains(searchQuery);
                }).toList();

                return PageView.builder(
                  controller: PageController(viewportFraction: 0.9),
                  itemCount: productos.length,
                  itemBuilder: (context, index) => _buildProductoCard(context, productos[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          const Text('PRODUCTOS RECIENTES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('productos')
                .where('disponible', isEqualTo: true)
                .where('reciente', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final productos = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['nombre'].toString().toLowerCase().contains(searchQuery);
              }).toList();

              return Column(
                children: productos.map((doc) => _buildProductoCard(context, doc, showButton: false)).toList(),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF031059),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.sell), label: 'Ofertas'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notificaciones'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildProductoCard(BuildContext context, QueryDocumentSnapshot doc, {bool showButton = true}) {
    final data = doc.data() as Map<String, dynamic>;

    return GestureDetector(
      onTap: () {
        if (!showButton) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductoDetalleScreen(
                nombre: data['nombre'],
                descripcion: data['descripcion'],
                precio: data['precio'],
                imagenUrl: 'https://drive.google.com/uc?export=view&id=${data['imagen_drive_id']}',
              ),
            ),
          );
        }
      },
      child: Card(
        color: const Color(0xFFF7F1FA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://drive.google.com/uc?export=view&id=${data['imagen_drive_id']}',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.error, size: 90),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['nombre'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(data['descripcion'], maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('S/ ${data['precio']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    if (data['oferta'] == true)
                      const Text('¡En oferta!', style: TextStyle(color: Colors.red)),
                    if (showButton)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.shopping_cart_checkout),
                          label: const Text('Añadir al carrito'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF031059),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}