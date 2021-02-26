import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/httpexception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  var authToken;
  var userId;

  List<Product> get items {
    return [..._items];
  }

  Products(this.authToken, this.userId, this._items);

  List<Product> get favoriteItems {
    List<Product> favlist =
        _items.where((product) => product.isFavorite).toList();
    return favlist;
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  void removeProduct(String id) {
    var url =
        'https://barter-c5f0b.firebaseio.com/products/$userId/$id.json?auth=$authToken';
    var existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product existingProduct = _items.firstWhere((prod) => prod.id == id);
    _items.removeWhere((product) => product.id == id);
    try {
      var response = http.delete(url).then((response) {
        if (response.statusCode >= 400) {
          _items.insert(existingProductIndex, existingProduct);
          // _items.add(existingProduct);
        } else {
          var responseData = json.decode(response.body);
          print(responseData);
          if (responseData && responseData['error'] != null) {
            _items.insert(existingProductIndex, existingProduct);
            throw HttpException('Error ${responseData['error']['message']}');
          }
        }
      });
    } catch (error) {
      _items.insert(existingProductIndex, existingProduct);
      throw error;
    }
    notifyListeners();
  }

  Future<void> fetchAndUpdateProducts({bool sort = false}) async {
    String sortKey = sort ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    List<Product> tempProductList = [];
    var url =
        'https://barter-c5f0b.firebaseio.com/product.json?auth=$authToken&$sortKey';
    var favoriteUrl =
        'https://barter-c5f0b.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
    try {
      final response = await http.get(url);
      final favoriteResponse = await http.get(favoriteUrl);
      Map<String, dynamic> decodedData = json.decode(response.body);
      Map<String, dynamic> favoriteData = json.decode(favoriteResponse.body);
      // print(decodedData);
      if (decodedData == null) {
        _items = [];
        notifyListeners();
        return;
      } else {
        if (decodedData.isEmpty) {
          _items = [];
          notifyListeners();
          return; 
        } else {
          decodedData.forEach((productId, productData) {
            tempProductList.add(Product(
                id: productId,
                description: productData['description'],
                title: productData['title'],
                imageUrl: productData['imageUrl'],
                isFavorite: favoriteData == null
                    ? false
                    : favoriteData == []
                        ? false
                        : favoriteData[productId] == null
                            ? false
                            : favoriteData[productId] ?? false,
                price: productData['price']));
            _items = tempProductList;
            // print(_items);
            notifyListeners();
          });
        }
      }
    } catch (error) {
      _items = [];
      throw HttpException('Error Fetching Data From FireBase $error');
    }
  }

  void addProduct(String id, String title, String description, double price,
      String imageUrl) {
    _items.add(Product(
        description: description,
        id: id,
        title: title,
        imageUrl: imageUrl,
        price: price));
    notifyListeners();
  }

  void addNewProduct(Product product) {
    if (_items.any((prod) => prod.id == product.id)) {
      // Update Product
      var url =
          'https://barter-c5f0b.firebaseio.com/products/$userId/${product.id}.json?auth=$authToken';
      var existingProductIndex =
          _items.indexWhere((prod) => prod.id == product.id);
      Product existingProduct =
          _items.firstWhere((prod) => prod.id == product.id);
      _items.removeWhere((prod) => prod.id == product.id);
      _items.add(product);
      try {
        var response = http
            .patch(url,
                body: json.encode({
                  'title': product.title,
                  'price': product.price,
                  'description': product.description,
                  'imageUrl': product.imageUrl,
                }))
            .then((response) {
          if (response.statusCode >= 400) {
            _items.removeAt(existingProductIndex);
            _items.add(existingProduct);
          } else {
            var responseData = json.decode(response.body);
            if (responseData['error'] != null) {
              _items.removeAt(existingProductIndex);
              _items.add(existingProduct);
              throw HttpException('Error ${responseData['error']['message']}');
            }
          }
        });
      } catch (error) {
        _items.removeAt(existingProductIndex);
        _items.add(existingProduct);
      }

      notifyListeners();
    } else {
      //Add New Product
      var url =
          'https://barter-c5f0b.firebaseio.com/products/$userId.json?auth=$authToken';
      _items.add(product);
      var newProductIndex = _items.indexWhere((prod) => prod.id == product.id);
      try {
        var response = http
            .post(url,
                body: json.encode({
                  'title': product.title,
                  'price': product.price,
                  'description': product.description,
                  'imageUrl': product.imageUrl,
                }))
            .then((response) {
          if (response.statusCode >= 400) {
            _items.removeAt(newProductIndex);
          }
        });
      } catch (error) {
        _items.removeAt(newProductIndex);
      }
      notifyListeners();
    }
  }
}
