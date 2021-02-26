import 'package:barter/screens/edit_product.dart';
import 'package:barter/screens/orders_screen.dart';
import 'package:barter/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/orders.dart';
import 'screens/cart_screen.dart';
import 'providers/cart.dart';
import 'providers/products.dart';
import 'providers/auth.dart';
import 'screens/product_detail.dart';
import 'screens/product_overview.dart';
import 'screens/user_products.dart';
import 'screens/auth_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            builder: (ctx) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Products>(
            initialBuilder: (_) => Products(null, null, []),
            builder: (ctx, auth, previousProduct) => Products(
                auth.token,
                auth.userId,
                previousProduct == null ? [] : previousProduct.items),
          ),
          ChangeNotifierProxyProvider<Auth, Order>(
            initialBuilder: (_) => Order(null, null, []),
            builder: (ctx, auth, previousOrder) => Order(
                auth.token, auth.userId, previousOrder == null ? [] : previousOrder.orders),
          ),
          ChangeNotifierProvider(
            builder: (ctx) => Cart(),
          )
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
              theme: ThemeData(
                primarySwatch: Colors.deepPurple,
                accentColor: Colors.deepOrangeAccent,
              ),
              home: auth.isAuth
                  ? ProductOverView()
                  : FutureBuilder(
                      future: auth.autoLogin(),
                      builder: (ctx, snapshot) =>
                          snapshot.connectionState == ConnectionState.waiting
                              ? SplashScreen()
                              : AuthScreen()),
              routes: {
                ProductDetail.routeName: (ctx) {
                  return ProductDetail();
                },
                CartScreen.routeName: (ctx) {
                  return CartScreen();
                },
                OrderScreen.routeName: (ctx) {
                  return OrderScreen();
                },
                UserProductsScreen.routeName: (ctx) {
                  return UserProductsScreen();
                },
                EditProductScreen.routeName: (ctx) {
                  return EditProductScreen();
                },
              }),
        ));
  }
}
