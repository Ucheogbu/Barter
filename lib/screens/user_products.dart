import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';
import '../screens/edit_product.dart';
import '../widgets/user_product_item.dart';

class UserProductsScreen extends StatefulWidget {
  static String routeName = '/user_product_screen';

  @override
  _UserProductsScreenState createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {

  Future<void> _refreshAndUpdate(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndUpdateProducts(sort: true);
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(EditProductScreen.routeName, arguments: {
                'product': Product(
                    id: DateTime.now().toString(),
                    title: '',
                    description: '',
                    price: 0.0,
                    imageUrl: '',
                    isFavorite: false)
              });
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _refreshAndUpdate(context),
        builder: (ctx, snapshot) => snapshot.connectionState == ConnectionState.waiting ? Center(child: CircularProgressIndicator(),) : RefreshIndicator(
          onRefresh: () => _refreshAndUpdate(ctx),
          child: Consumer<Products>(
            builder: (ctx, products, _) => ListView.builder(
              itemCount: products.items.length,
              itemBuilder: (ctx, i) {
                return Card(
                  elevation: 3,
                  child: Column(
                    children: <Widget>[
                      UserProductItem(product: products.items[i]),
                      Divider()
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
