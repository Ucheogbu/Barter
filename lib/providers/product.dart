import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/httpexception.dart';

class Product with ChangeNotifier {
  final String title;
  final String id;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {@required this.id,
      @required this.description,
      @required this.imageUrl,
      this.isFavorite = false,
      @required this.title,
      @required this.price});

  Future<void> toggleFavourite(String token, String userId) async {
    print(token);
    isFavorite = !isFavorite;
    String url =
        'https://barter-c5f0b.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
    try {
      var response = await http.put(url, body: json.encode(isFavorite));
      if (response.statusCode >= 400) {
        isFavorite = !isFavorite;
      } else {
        var responseData = json.decode(response.body);
        print(responseData);
        if (responseData && responseData['error'] != null) {
          isFavorite = !isFavorite;
          throw HttpException('Error ${responseData['error']['message']}');
        }
      }
    } catch (error) {
      throw error;
    }

    notifyListeners();
  }
}
