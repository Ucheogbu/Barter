import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/httpexception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  String _refreshToken;

  String get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  bool get isAuth {
    return token != null;
  }

  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    Map<String, Object> oldData = json.decode(prefs.getString('userData'));
    // print(oldData);
    DateTime expiryDate = DateTime.parse(oldData['expiryDate']);
    // print(expiryDate);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    } else {
      _token = oldData['token'];
      _expiryDate = expiryDate;
      _userId = oldData['userId'];
      _refreshToken = oldData['refreshToken'];
      notifyListeners();
      return true;
    }
  }

  Future<void> logout() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    _token = null;
    _expiryDate = null;
    _userId = null;
    _refreshToken = null;
    notifyListeners();
  }

  Future<void> _autoLogout() async {
    Duration expiesIn = _expiryDate.difference(DateTime.now());
    Timer(expiesIn, () {
      _token = null;
      _expiryDate = null;
      _userId = null;
      _refreshToken = null;
    });
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    String url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyD3WbfnyUEGYxhuZdT7Pylq5Pz3Zz57upA';
    try {
      var response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      if (response.statusCode >= 400) {
        print(response.body);
        throw HttpException(
            'Error Creating User with response code ${response.statusCode} with body ${response.body}');
      } else {
        var responseData = json.decode(response.body);
        if (responseData['error'] != null) {
          throw HttpException('Error ${responseData['error']['message']}');
        } else {
          _token = responseData['idToken'];
          _expiryDate = DateTime.now()
              .add(Duration(seconds: int.parse(responseData['expiresIn'])));
          _userId = responseData['localId'];
          _refreshToken = responseData['refreshToken'];

          _autoLogout();
          notifyListeners();
          final prefs = await SharedPreferences.getInstance();
          var data = json.encode({
            'token': _token,
            'expiryDate': _expiryDate.toIso8601String(),
            'userId': _userId,
            'refreshToken': _refreshToken
          });
          prefs.setString('userData', data);
        }
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }
}
