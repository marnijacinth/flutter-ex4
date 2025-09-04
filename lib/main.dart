import 'package:flutter/material.dart';


void main() {
  runApp(ProductBillingApp());
}


// Data model for a single product
class Product {
  final String name;
  final double price;
  final int quantity;


  Product({required this.name, required this.price, required this.quantity});


  double get subtotal => price * quantity;
}




class ProductBillingApp extends StatefulWidget {
  const ProductBillingApp({super.key});


  @override
  State<ProductBillingApp> createState() => _ProductBillingAppState();
}


class _ProductBillingAppState extends State<ProductBillingApp> {


  // state variables
  final _formkey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _quantityController = TextEditingController();


  final List<Product> _products = [];
  double _totalAmount = 0.0;
  double _gstAmount = 0.0;
  double _netBill = 0.0;
  Product? _highestPricedProduct;




  // Adds a product to the list and recalculates the bill
  void _addProduct() {
    if (_formkey.currentState!.validate()) {
      setState(() {                               // for updating the values
        final newProduct = Product(
          name: _productNameController.text,
          price: double.parse(_productPriceController.text),
          quantity: int.parse(_quantityController.text),
        );
        _products.add(newProduct);
        _calculateBill();


        // Clear input fields for next entry
        _productNameController.clear();
        _productPriceController.clear();
        _quantityController.clear();
      });
    }
  }


  // Calculates the total bill, GST, and finds the highest priced product
  void _calculateBill() {
    _totalAmount = _products.fold(0, (sum, item) => sum + item.subtotal);


    if (_totalAmount > 1000) {
      _gstAmount = _totalAmount * 0.05; // 5% GST
    } else {
      _gstAmount = 0.0;
    }
    _netBill = _totalAmount + _gstAmount;


    // Find the highest-priced product
    if (_products.isNotEmpty) {
      _highestPricedProduct = _products.reduce((curr, next) => curr.price > next.price ? curr : next);
    }
  }




  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Billing System',
      home: Scaffold(
        appBar: AppBar(title: Text('PRODUCT BILLING SYSTEM', style: TextStyle(color: Colors.white)), backgroundColor: Colors.indigo),
        body: Container(
          padding: EdgeInsets.all(25),
          child: SingleChildScrollView( // To avoid overflow when list grows
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _productNameController,
                    decoration: InputDecoration(
                        labelText: "Enter Product Name",
                        border: OutlineInputBorder()
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter the product name";
                      }
                      return null;
                    },
                  ),


                  SizedBox(height: 15),


                  TextFormField(
                    controller: _productPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: "Enter Product Price (₹)",
                        border: OutlineInputBorder()
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter the price";
                      }
                      if (double.tryParse(value) == null) {
                        return "Please enter a valid number";
                      }
                      if (double.parse(value) <= 0) {
                        return "Price must be greater than 0";
                      }
                      return null;
                    },
                  ),


                  SizedBox(height: 15),


                  TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: "Enter Quantity",
                        border: OutlineInputBorder()
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter the quantity";
                      }
                      if (int.tryParse(value) == null) {
                        return "Please enter a valid integer";
                      }
                      if (int.parse(value) <= 0) {
                        return "Quantity must be greater than 0";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 15)
                      ),
                      onPressed: _addProduct,
                      child: Text('Add Product')
                  ),
                  SizedBox(height: 20),


                  // Bill Display Section
                  if (_products.isNotEmpty) ...[
                    Text("Bill Details:", style: Theme.of(context).textTheme.titleLarge),
                    Divider(),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        final isHighest = product == _highestPricedProduct;
                        return Card(
                          color: isHighest ? Colors.orange.shade100 : Colors.white,
                          child: ListTile(
                            title: Text(
                              product.name,
                              style: TextStyle(
                                  fontWeight: isHighest ? FontWeight.bold : FontWeight.normal
                              ),
                            ),
                            subtitle: Text('${product.quantity} x ₹${product.price.toStringAsFixed(2)}'),
                            trailing: Text(
                              '₹${product.subtotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontWeight: isHighest ? FontWeight.bold : FontWeight.normal
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Divider(),
                    SizedBox(height: 10),
                    Text("Total Amount: ₹${_totalAmount.toStringAsFixed(2)}", style: TextStyle(fontSize: 16)),
                    Text("GST (5% if total > ₹1000): ₹${_gstAmount.toStringAsFixed(2)}", style: TextStyle(fontSize: 16)),
                    Text(
                      "Net Bill: ₹${_netBill.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ), backgroundColor: Colors.grey[200],
      ),
    );
  }
 
  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    _productNameController.dispose();
    _productPriceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
