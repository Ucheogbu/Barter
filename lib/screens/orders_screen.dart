import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' as od;
import '../widgets/drawer.dart';
import '../widgets/order_item.dart';

class OrderScreen extends StatefulWidget {
  static String routeName = '/orders';

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool isLoading = true;
  bool isInit = true;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (isInit){
      Provider.of<od.Order>(context).getOrders().then((_) => isLoading = false);
    setState(() {
      isInit = false;
    });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    List<od.OrderItem> orders = Provider.of<od.Order>(context).orders;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      drawer: CustomDrawer(),
      body: isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                ) : orders.length > 0 ? ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (_, index) {
                    return OrderItem(order: orders[index]);
                  },
                ) : Center(
              child:
                  Text('No Orders Added...Add Orders to Populate this Screen'),
            ),
              
          
    );
  }
}
