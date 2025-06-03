import 'package:flutter/material.dart';
import '../models/carrito_item.dart';

class CarritoProvider with ChangeNotifier {
  final List<CarritoItem> _items = [];

  List<CarritoItem> get items => _items;

  // Getter para obtener el número total de productos en el carrito
  int get itemsCount => _items.fold(0, (sum, item) => sum + item.cantidad);

  void agregarProducto(CarritoItem producto) {
    final index = _items.indexWhere((p) => p.id == producto.id);
    if (index >= 0) {
      _items[index].cantidad++;
    } else {
      _items.add(producto);
    }
    notifyListeners();
  }

  void eliminarProducto(String id) {
    _items.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void aumentarCantidad(String id) {
    final index = _items.indexWhere((p) => p.id == id);
    if (index >= 0) {
      _items[index].cantidad++;
      notifyListeners();
    }
  }

  void disminuirCantidad(String id) {
    final index = _items.indexWhere((p) => p.id == id);
    if (index >= 0 && _items[index].cantidad > 1) {
      _items[index].cantidad--;
      notifyListeners();
    }
  }

  double get subtotal => _items.fold(0, (sum, item) => sum + item.precio * item.cantidad);
  double get igv => subtotal * 0.18;
  double get total => subtotal + igv;
}