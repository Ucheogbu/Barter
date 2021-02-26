import 'package:barter/providers/auth.dart';
import 'package:barter/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';
import '../providers/cart.dart';

class ProductDetail extends StatelessWidget {
  static const routeName = '/details';
  @override
  Widget build(BuildContext context) {
    String productId = ModalRoute.of(context).settings.arguments as String;
    var auth = Provider.of<Auth>(context, listen:false);

    Product product =
        Provider.of<Products>(context, listen: false).findById(productId);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: Container(
                  height: 250,
                  width: double.infinity,
                  child: Hero(
                    tag: product.id,
                                      child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  )),
            ),
            ListTile(
              leading: CircleAvatar(
                child: FittedBox(
                  child: Text('\$${product.price.toStringAsPrecision(2)}'),
                ),
              ),
              title: FittedBox(
                child: Text(product.title,
                    style: Theme.of(context).textTheme.title),
              ),
              subtitle: Text(product.description),
              trailing: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Provider.of<Cart>(context, listen: false)
                      .addItems(product.id, product.title, product.price);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: product.isFavorite
            ? Icon(
                Icons.favorite,
                color: Colors.white,
              )
            : Icon(Icons.favorite_border),
        onPressed: () {
          product
              .toggleFavourite(auth.token, auth.userId)
              .catchError((error) {
            Scaffold.of(context).showSnackBar(SnackBar(
              backgroundColor: Theme.of(context).primaryColor,
              content: Text('Unable TO Update favorites $error'),
              duration: Duration(seconds: 3),
            ));
          });
        },
      ),
    );
  }
}
