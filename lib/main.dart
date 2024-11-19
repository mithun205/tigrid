import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tigrid/api_serivice.dart';
import 'package:tigrid/cart_model.dart';
import 'product_model.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartCubit(),
      child: MaterialApp(
        home: ProductListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class ProductListScreen extends StatelessWidget {
  final ApiService apiService = ApiService();

  ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        title: const Text(
          'Product List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<List<Product>>(
        future: apiService.fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.black,
            ));
          } else if (snapshot.hasError) {
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text('Error : ${snapshot.error}'),
            ));
          } else if (snapshot.hasData) {
            final products = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductItem(product: product);
                    },
                  ),
                ),
                const TotalCostSection(),
              ],
            );
          }
          return const Center(child: Text('No products available.'));
        },
      ),
    );
  }
}

class ProductItem extends StatefulWidget {
  final Product product;

  const ProductItem({super.key, required this.product});

  @override
  _ProductItemState createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  int _quantity = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.yellow[300],
      shadowColor: Colors.black,
      elevation: 8,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.product.thumbnail,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.product.description.length > 30
                        ? '${widget.product.description.substring(0, 30)}...'
                        : widget.product.description,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${widget.product.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 5),
                DropdownButton<int>(
                  dropdownColor: Colors.yellow[200],
                  value: _quantity,
                  items: List.generate(11, (index) {
                    return DropdownMenuItem<int>(
                      value: index,
                      child: Text('$index'),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      _quantity = value!;
                    });
                    context.read<CartCubit>().addToCart(widget.product, _quantity);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TotalCostSection extends StatelessWidget {
  const TotalCostSection({super.key});

  @override
  Widget build(BuildContext context) {
    final totalCost = context.select<CartCubit, double>((cubit) => cubit.totalCost);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        'Total: \$${totalCost.toStringAsFixed(2)}',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
