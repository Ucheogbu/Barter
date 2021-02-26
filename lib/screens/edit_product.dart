import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static String routeName = '/editscreen';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _urlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  Product _editedProduct =
      Product(id: null, title: '', description: '', price: 0.0, imageUrl: '');
  var isInit = true;

  @override
  void initState() {
    // TODO: implement initState
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (isInit) {
      Map<String, Product> args =
          ModalRoute.of(context).settings.arguments as Map<String, Product>;
      if (args['product'] != null) {
      _editedProduct = args['product'];
      }else {
      _editedProduct = Product(description: '', id: null, title: '', price: 0, imageUrl: '');
      }
      _urlController.text = _editedProduct.imageUrl;
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  void _saveForm() {
    _form.currentState.save();
    Provider.of<Products>(context, listen: false).addNewProduct(_editedProduct);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Map<String, Product> args = ModalRoute.of(context).settings.arguments as Map<String, Product>;
    // Product _editedProduct = args['product'];
    // _urlController.text = _editedProduct.imageUrl;

    return Scaffold(
      appBar: AppBar(
        title: _editedProduct.title.isEmpty
            ? Text('Add Product')
            : Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: Padding(
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                    initialValue: _editedProduct.title,
                    decoration: InputDecoration(labelText: 'Title'),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_priceFocusNode);
                    },
                    onSaved: (value) {
                      _editedProduct = Product(
                          id: _editedProduct.id,
                          title: value.isEmpty ? _editedProduct.title : value,
                          description: _editedProduct.description,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite);
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Title Cannot Be Empty';
                      }
                      return null;
                    }),
                TextFormField(
                    initialValue: _editedProduct.price.toString(),
                    decoration: InputDecoration(labelText: 'Price'),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    focusNode: _priceFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode);
                    },
                    onSaved: (value) {
                      _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          price: value.isEmpty
                              ? _editedProduct.price
                              : double.parse(value),
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite);
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Price Cannot Be Empty';
                      }
                      return null;
                    }),
                TextFormField(
                    initialValue: _editedProduct.description,
                    decoration: InputDecoration(labelText: 'Description'),
                    minLines: 3,
                    maxLines: 100,
                    keyboardType: TextInputType.multiline,
                    focusNode: _descriptionFocusNode,
                    onSaved: (value) {
                      _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: value.isEmpty
                              ? _editedProduct.description
                              : value,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite);
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Description Cannot Be Empty';
                      }
                      if (value.length < 10) {
                        return 'Description Cannot Be less than ten(10) characters';
                      }
                      return null;
                    }),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey)),
                      child: _urlController.text.isEmpty
                          ? Text('Enter Image Url')
                          : FittedBox(
                              child: Image.network(_urlController.text),
                            ),
                    ),
                    Expanded(
                      child: TextFormField(
                          decoration: InputDecoration(labelText: 'ImageUrl'),
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          controller: _urlController,
                          focusNode: _imageUrlFocusNode,
                          onFieldSubmitted: (_) => _saveForm(),
                          onSaved: (value) {
                            _editedProduct = Product(
                                id: _editedProduct.id,
                                title: _editedProduct.title,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                imageUrl: value.isEmpty
                                    ? _editedProduct.imageUrl
                                    : value,
                                isFavorite: _editedProduct.isFavorite);
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'ImageUrl Cannot Be Empty';
                            }
                            if ((!value.startsWith('http') &&
                                    !value.startsWith('https')) ||
                                (!value.endsWith('png') ||
                                    !value.endsWith('jpg') ||
                                    !value.endsWith('jpeg'))) {
                              return 'imageUrl has to be a valid URL';
                            }
                            return null;
                          }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        padding: EdgeInsets.all(16.0),
      ),
    );
  }
}
