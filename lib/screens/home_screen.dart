import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/carrito_provider.dart';
import '../models/carrito_item.dart';
import 'producto_detalle_screen.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Timer? _inactivityTimer; // Nuevo: Timer para manejar el tiempo de inactividad del usuario

  @override
  void initState() {
    super.initState();
    cargarDatosUsuario();
    WidgetsBinding.instance.addObserver(this);
    _resetInactivityTimer(); // Nuevo: Iniciar el temporizador de inactividad
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel(); // Nuevo: Cancelar el temporizador de inactividad al cerrar la pantalla
    super.dispose();
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel(); // Nuevo: Cancelar el temporizador anterior si existe
    _inactivityTimer = Timer(const Duration(minutes: 5), () {
      // Nuevo: Si el usuario está inactivo durante 5 minutos, cerrar sesión
      FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  final searchController = TextEditingController();
  String searchQuery = '';

  String? rutaImagen;
  String? nombreUsuario;

  Future<void> cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nombreUsuario = prefs.getString('ultimoNombre');
      rutaImagen = prefs.getString('ultimaImagen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // Nuevo: Detectar interacciones para reiniciar el temporizador
      behavior: HitTestBehavior.translucent,
      onTap: _resetInactivityTimer,
      onPanDown: (_) => _resetInactivityTimer(),
      child: Scaffold(
        drawer: Drawer(
          backgroundColor: const Color(0xFF2D3540),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              /*const DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF031059)),
                child: Text('Menú Principal', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),*/
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                decoration: const BoxDecoration(
                  color: Color(0xFF031059),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/icon/app_icon.png'),
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 40), // Espacio entre la imagen y el texto
                    const Text(
                      'Ferretería \nSanta Rosa',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.white),
                title: const Text('Inicio', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text('Perfil', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/perfil');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.white),
                title: const Text('Configuración', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pushNamed(context, '/ajustes');
                },
              ),
              ListTile(
                leading: const Icon(Icons.sensors, color: Colors.white),
                title: const Text('Ver Sensores', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pushNamed(context, '/sensores');
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.white),
                title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: const Color(0xFF031059),
          elevation: 0,
          toolbarHeight: 85,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            Consumer<CarritoProvider>(
              builder: (context, carritoProvider, child) {
                return Row(
                  children: [
                    IconButton(
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
                      onPressed: () => Navigator.pushNamed(context, '/carrito'),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/perfil'),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundImage: rutaImagen != null && rutaImagen!.isNotEmpty
                                ? FileImage(File(rutaImagen!))
                                : const AssetImage('assets/images/usuario.png') as ImageProvider,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                  ],
                );
              },
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
              height: 230,
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
          currentIndex: 0,
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
      ),
    );
  }

  Widget _buildProductoCard(BuildContext context, QueryDocumentSnapshot doc, {bool showButton = true}) {
    final data = doc.data() as Map<String, dynamic>;
    final double precio = (data['precio'] as num).toDouble();
    final int descuento = data['descuento'] ?? 0;
    final bool enOferta = data['oferta'] ?? false;
    final double precioDescuento = enOferta && descuento > 0 ? precio - (precio * descuento / 100) : precio;

    return GestureDetector(
      onTap: () {
        if (!showButton) {
          Navigator.push( // Nuevo: Navegar a detalle sin botón
            context,
            MaterialPageRoute( // Nuevo: Usar MaterialPageRoute para navegar a detalle
              builder: (_) => ProductoDetalleScreen(
                nombre: data['nombre'],
                descripcion: data['descripcion'],
                precio: precio,
                imagenUrl: 'https://drive.google.com/uc?export=view&id=${data['imagen_drive_id']}',
                oferta: enOferta,
                descuento: descuento,
                caracteristicas: data['caracteristicas']?.toString(),
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
                    if (enOferta && descuento > 0) ...[
                      Text(
                        'S/ $precio',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'S/ ${precioDescuento.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ] else ...[
                      Text('S/ ${precio.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                    if (enOferta)
                      const Text('¡En oferta!', style: TextStyle(color: Colors.red)),
                    if (showButton)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Provider.of<CarritoProvider>(context, listen: false).agregarProducto(
                              CarritoItem(
                                nombre: data['nombre'],
                                descripcion: data['descripcion'],
                                id: doc.id,
                                precio: precioDescuento,
                                imagenUrl: 'https://drive.google.com/uc?export=view&id=${data['imagen_drive_id']}',
                                cantidad: 1,
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Producto agregado al carrito')),
                            );
                          },
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