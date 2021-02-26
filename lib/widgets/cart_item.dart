import 'package:provider/provider.dart';

import '../providers/cart.dart';
import 'package:flutter/material.dart';

class CartItems extends StatelessWidget {
  final CartItem value;
  final String product_id;

  const CartItems({@required this.value, @required this.product_id});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(value.id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 10),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('Are you Sure?'),
                content: Text(
                    'are you sure you want to remove ${value.title} from cart?'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(ctx).pop(false);
                    },
                  ),
                  FlatButton(
                    child: Text('Yes'),
                    onPressed: () {
                      Navigator.of(ctx).pop(false);
                    },
                  ),
                ],
              );
            });
      },
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(product_id);
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: ListTile(
          title: Text('${value.title}'),
          subtitle: (Text('Total Price ${value.price * value.quantity}')),
          trailing: CircleAvatar(
            radius: 15,
            child: FittedBox(
              child: Text(
                '${value.quantity}x',
                style: TextStyle(
                    color: Theme.of(context).primaryTextTheme.title.color,
                    backgroundColor: Theme.of(context).primaryColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
