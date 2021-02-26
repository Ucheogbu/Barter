import 'package:barter/models/badge.dart';
import 'package:barter/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/products.dart';
import '../widgets/productsGrid.dart';
import 'cart_screen.dart';

class ProductOverView extends StatefulWidget {
  static const routeName = '/productOverview';
  @override
  _ProductOverViewState createState() => _ProductOverViewState();
}

class _ProductOverViewState extends State<ProductOverView> {
  var _showFavorites = false;
  bool _isLoading = true;
  bool isInit = false;
  bool errorState = false;
  String errorMessage = '';

  Future<void> fetchData() {
    return Provider.of<Products>(context).fetchAndUpdateProducts().then((_) {
      setState(() {
        _isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        errorState = true;
        errorMessage = error.toString();
        _isLoading = false;
      });
    });
  }

  @override
  void didChangeDependencies() {
    if (!isInit) {
      fetchData();
    }
    setState(() {
      isInit = true;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: CustomDrawer(),
        appBar: AppBar(
          title: Text('Barter'),
          centerTitle: true,
          actions: <Widget>[
            PopupMenuButton(
              onSelected: (selectedValue) {
                setState(() {
                  if (selectedValue == 0) {
                    _showFavorites = true;
                  } else if (selectedValue == 1) {
                    _showFavorites = false;
                  }
                });
              },
              icon: Icon(Icons.more_vert),
              itemBuilder: (_) => [
                PopupMenuItem(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.favorite),
                      Text('Show Favorites')
                    ],
                  ),
                  value: 0,
                ),
                PopupMenuItem(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.select_all),
                      Text('Show All')
                    ],
                  ),
                  value: 1,
                ),
              ],
            ),
            Consumer<Cart>(
              builder: (_, cart, ch) => Badge(
                child: ch,
                value: '${cart.itemCount}',
              ),
              child: IconButton(
                icon: Icon(
                  Icons.shopping_cart,
                ),
                onPressed: () =>
                    Navigator.of(context).pushNamed(CartScreen.routeName),
              ),
            )
          ],
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : errorState
                ? RefreshIndicator(
                  onRefresh: () => fetchData(),
                  child: Center(
                    child: Text('Error Pulling Files From CLoud $errorMessage'),
                  )
                )
                : RefreshIndicator(
                    onRefresh: () => fetchData(),
                    child: ProductGrid(_showFavorites)));
  }
}
