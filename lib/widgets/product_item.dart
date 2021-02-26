import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/product.dart';
import '../screens/product_detail.dart';

class ProductItem extends StatefulWidget {
  @override
  _ProductItemState createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<Auth>(context, listen: false);
    final Product product = Provider.of<Product>(context, listen: false);
    var cart = Provider.of<Cart>(context, listen: false);
    void viewDetail(BuildContext context) {
      Navigator.of(context)
          .pushNamed(ProductDetail.routeName, arguments: product.id);
    }

    return GridTile(
        child: GestureDetector(
          child: Hero(
            tag: product.id,
                      child: FadeInImage.assetNetwork(
              placeholder: 'assets/images/product-placeholder.png',
              fit: BoxFit.cover,
              image: product.imageUrl,
            ),
          ),
          onTap: () => viewDetail(context),
        ),
        footer: GridTileBar(
            leading: Consumer<Product>(
              builder: (context, product, child) => IconButton(
                  icon: Icon(product.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border),
                  color: Theme.of(context).accentColor,
                  onPressed: () => product
                          .toggleFavourite(auth.token, auth.userId)
                          .catchError((error) {
                        Scaffold.of(context).hideCurrentSnackBar();
                        Scaffold.of(context).showSnackBar(SnackBar(
                          backgroundColor: Theme.of(context).primaryColor,
                          content: Text('Unable TO Update favorites $error'),
                          duration: Duration(seconds: 3),
                        ));
                      })),
            ),
            backgroundColor: Colors.black54,
            trailing: IconButton(
                icon: Icon(Icons.shopping_cart),
                color: Theme.of(context).accentColor,
                onPressed: () {
                  cart.addItems(product.id, product.title, product.price);
                  Scaffold.of(context).hideCurrentSnackBar();
                  Scaffold.of(context).showSnackBar(SnackBar(
                    backgroundColor: Theme.of(context).primaryColor,
                    content: Text('one ${product.title} added to cart'),
                    duration: Duration(seconds: 3),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                      },
                    ),
                  ));
                }),
            title: Text(product.title, textAlign: TextAlign.center)));
  }
}
