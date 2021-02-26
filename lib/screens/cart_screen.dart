import 'package:barter/providers/product.dart';
import 'package:barter/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/cart_item.dart';
import '../providers/cart.dart';
import '../providers/products.dart';
import '../providers/orders.dart';

class CartScreen extends StatefulWidget {
  static String routeName = '/cart';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<Cart>(context);
    var productData = Provider.of<Products>(context);
    var orderData = Provider.of<Order>(context);
    var isAdding = false;
    return Scaffold(
        drawer: CustomDrawer(),
        appBar: AppBar(
          title: Text('Cart'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Column(
              children: <Widget>[
                Card(
                  margin: EdgeInsets.all(15),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Total',
                            style: TextStyle(
                              fontSize: 20,
                            )),
                        Spacer(),
                        Chip(
                          label: Text(
                            '${cart.totalPrice}',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .primaryTextTheme
                                    .title
                                    .color),
                          ),
                          backgroundColor: Theme.of(context).primaryColorDark,
                        ),
                        FlatButton(
                          child: isAdding
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Text(
                                  'ORDER NOW',
                                  // style: TextStyle(
                                  //     color: Theme.of(context)
                                  //         .primaryTextTheme
                                  //         .title
                                  //         .color),
                                ),
                          onPressed: () {
                            // print(cart.items);
                            double amount = 0;
                            List<Product> products = [];
                            cart.items.keys.forEach((key) {
                              // print(key);
                              amount += productData.findById(key).price;
                              products.add(productData.findById(key));
                            });
                            // print(amount);
                            setState(() {
                              isAdding = true;
                            });
                            orderData.addOrder(amount, products).then((_) {
                              setState(() {
                              isAdding = false;
                            });
                              cart.clearCart();
                            });
                          },
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: double.infinity,
              child: cart == null
                  ? Center(
                      child: Text('Cart is Empty, Add items to cart',
                          style: TextStyle(
                            color: Colors.black,
                          )))
                  : ListView.builder(
                      itemBuilder: (_, i) {
                        var value = cart.items.values.elementAt(i);
                        var key = cart.items.keys.elementAt(i);
                        return new CartItems(value: value, product_id: key);
                      },
                      itemCount: cart.items.length,
                    ),
            ),
          ],
        ));
  }
}
