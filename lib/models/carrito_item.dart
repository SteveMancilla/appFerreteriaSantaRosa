class CarritoItem {
  final String id;
  final String nombre;
  final String descripcion;
  final String imagenUrl;
  final double precio;
  int cantidad;

  CarritoItem({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.imagenUrl,
    required this.precio,
    this.cantidad = 1,
  });
}
