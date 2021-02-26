import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// import './product.dart';

String url = 'https://barter-c5f0b.firebaseio.com/';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem(
      {@required this.id,
      @required this.price,
      @required this.quantity,
      @required this.title});
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return _items;
  }

  double get totalPrice {
    var val = 0.0;
    _items.forEach((key, value) {
      val += value.price * value.quantity;
    });
    return val;
  }

  int get itemCount {
    return _items.length;
  }

  void removeItem(id) {
    items.remove(id);
    notifyListeners();
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }

  void addItems(String id, String title, double price) {
    // print(id);
    if (_items == null) {
      _items[id] = CartItem(
          id: id,
          title: title,
          price: price,
          quantity: 1);
    } else if (_items.containsKey(id)) {
      _items.update(
          id,
          (item) => CartItem(
              id: item.id,
              title: item.title,
              price: item.price,
              quantity: item.quantity + 1));
    } else {
      _items.putIfAbsent(
          id,
          () => CartItem(
              id: id,
              title: title,
              price: price,
              quantity: 1));
    }
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId].quantity > 1) {
      _items.update(
          productId,
          (existingItem) => CartItem(
              price: existingItem.price,
              quantity: existingItem.quantity - 1,
              id: existingItem.id,
              title: existingItem.title));
    }else {
      _items.remove(productId);
    }

    notifyListeners();
  }
}
