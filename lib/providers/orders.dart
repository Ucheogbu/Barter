import 'dart:convert';
import 'package:barter/providers/product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/httpexception.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<Product> products;
  final DateTime date;

  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.products,
      @required this.date});
}

class Order with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  var authToken = '';
  var userId = '';

  Order(this.authToken, this.userId, this._orders);
  Future<void> getOrders() {
    String url =
        'https://barter-c5f0b.firebaseio.com/orders/$userId.json?auth=$authToken';
    return http.get(url).then((response) {
      // print(response.body);
      // print(response.statusCode);
      if (response.statusCode >= 400) {
        _orders = [];
        notifyListeners();
      } else {
        if (json.decode(response.body) == null) {
          _orders = [];
          notifyListeners();
        } else {
          List<Product> products = [];
          _orders = [];
          Map<String, dynamic> decodedData = json.decode(response.body);
          decodedData.forEach((orderid, order) {
            if (order['products'] != null) {
              order['products'].forEach((product) {
                products.add(Product(
                    description: product['description'],
                    id: product['id'],
                    imageUrl: product['imageUrl'],
                    price: product['price'],
                    title: product['title'],
                    isFavorite: product['isFavorite']));
              });
            } else {
              products = [];
            }
            _orders.add(OrderItem(
                id: orderid,
                amount: order['amount'],
                date: DateTime.tryParse(order['date']),
                products: products));
          });
          // print(_orders);
          notifyListeners();
        }
      }
    });
  }

  Future<void> addOrder(double amount, List<Product> products) {
    var productState = true;
    List<Map<String, dynamic>> productmap = [];
    if (products != null || products.isNotEmpty) {
      products.forEach((prod) {
        productmap.add({
          'id': prod.id,
          'title': prod.title,
          'description': prod.description,
          'imageUrl': prod.imageUrl,
          'price': prod.price,
          'isFavourite': prod.isFavorite
        });
      });
      // print(productmap);
    } else {
      productmap = [];
      productState = false;
    }
    String url =
        'https://barter-c5f0b.firebaseio.com/orders/$userId.json?auth=$authToken';
    return http
        .post(url,
            body: json.encode({
              'amount': amount,
              'date': DateTime.now().toIso8601String(),
              'products': productState ? productmap : "[]"
            }))
        .then((response) {
      if (response.statusCode >= 400) {
        throw HttpException('Error making order');
      } else {
        notifyListeners();
      }
    });
  }

  void updateOrder(String id, double amount, List<Product> products) {
    List<Map<String, dynamic>> productmap = [];
    OrderItem order = _orders.firstWhere((order) => order.id == id);
    int orderIndex = _orders.indexWhere((order) => order.id == id);
    _orders.add(OrderItem(
        id: id, amount: amount, products: products, date: DateTime.now()));
    var prodIndex = _orders.indexWhere((order) => order.id == id);
    products.forEach((prod) {
      productmap.add({
        'id': prod.id,
        'title': prod.title,
        'description': prod.description,
        'imageUrl': prod.imageUrl,
        'price': prod.price,
        'isFavourite': prod.isFavorite
      });
    });
    String url = 'https://barter-c5f0b.firebaseio.com/orders/$id.json?auth=$authToken';
    http
        .patch(url,
            body: json.encode({'amount': amount, 'products': productmap}))
        .then((response) {
      if (response.statusCode >= 400) {
        _orders.removeAt(prodIndex);
        List<Product> prodList = [];
        productmap.forEach((product) {
          prodList.add(Product(
              description: product['description'],
              id: product['id'],
              title: product['title'],
              imageUrl: product['imageUrl'],
              price: product['price'],
              isFavorite: product['isFavorites']));
        });
      }
    });
    notifyListeners();
  }

  void removeOrder(orderId) {
    OrderItem order = _orders.firstWhere((order) => order.id == orderId);
    int orderIndex = _orders.indexWhere((order) => order.id == orderId);
    _orders.removeWhere((order) => order.id == orderId);
    String url = 'https://barter-c5f0b.firebaseio.com/$orderId.json';
    http.delete(url).then((response) {
      if (response.statusCode >= 400) {
        _orders.insert(orderIndex, order);
      }
    });
    notifyListeners();
  }

  void clearOrders() {
    _orders = [];
    notifyListeners();
  }

  int orderCount() {
    return _orders.length;
  }
}
