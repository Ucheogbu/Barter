import 'package:barter/providers/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import './product_item.dart';

class ProductGrid extends StatefulWidget {
  final bool showFavorites;
  ProductGrid(this.showFavorites);

  @override
  _ProductGridState createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  @override
  Widget build(BuildContext context) {
    var productData = Provider.of<Products>(context);
    List<Product> products =
        widget.showFavorites ? productData.favoriteItems : productData.items;

    return products.length <= 0
        ? Center(
            child: Text('No Products Found'),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: products.length,
            itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                  value: products[i],
                  child: ProductItem(),
                ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10));
  }
}
