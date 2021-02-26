import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/orders.dart' as od;

class OrderItem extends StatefulWidget {
  final od.OrderItem order;

  OrderItem({@required this.order});

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool showOrders = false;

  @override
  Widget build(BuildContext context) {
    // print(widget.order.products);
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Card(
          margin: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: ListTile(
            title: Text('\$${widget.order.amount}'),
            subtitle: Text('${DateFormat().format(widget.order.date)}'),
            trailing: IconButton(
              icon: Icon(showOrders
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down),
              onPressed: () {
                setState(() {
                  showOrders = !showOrders;
                });
              },
            ),
          ),
        ),
        AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeIn,
            height: showOrders ? 200 : 0,
            constraints: BoxConstraints(maxHeight: showOrders ? 200 : 0),
            child: widget.order.products.length > 0
                ? ListView.builder(
                    itemCount: widget.order.products.length,
                    itemBuilder: (_, i) => ListTile(
                      leading: CircleAvatar(
                        child: FittedBox(
                            child: Text('${widget.order.products[i].id}')),
                      ),
                      title: Text(
                        '${widget.order.products[i].title}',
                        style: Theme.of(context).textTheme.title,
                      ),
                      subtitle: Text('${widget.order.products[i].description}'),
                      trailing: CircleAvatar(
                        child: FittedBox(
                            child: Text('\$${widget.order.products[i].price}')),
                      ),
                    ),
                  )
                : Container(
                    child: Text('No Products in this Order, Error!!'),
                    height: 12,
                  ))
      ]),
    );
  }
}
