import 'package:barter/providers/auth.dart';
import 'package:barter/screens/orders_screen.dart';
import 'package:barter/screens/user_products.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            height: 250,
            width: double.infinity,
            child: Image.asset('assets/images/store.png', fit: BoxFit.cover,)
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/');
            },
            child: ListTile(
              leading: Icon(Icons.shop),
              title: Text('Shop'),
            ),
          ),
          Divider(),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(OrderScreen.routeName);
            },
            child: ListTile(
              leading: Icon(Icons.schedule),
              title: Text('Orders'),
            ),
          ),
          Divider(),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(UserProductsScreen.routeName);
            },
            child: ListTile(
              leading: Icon(Icons.category),
              title: Text('Products'),
            ),
          ),
          Divider(),
          GestureDetector(
            onTap: () {
              // Navigator.of(context).pushNamed('/');
              Navigator.of(context).pop();
              Provider.of<Auth>(context, listen: false).logout();
            },
            child: ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}
