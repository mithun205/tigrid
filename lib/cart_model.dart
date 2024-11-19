import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_model.dart';

class CartCubit extends Cubit<List> {
  CartCubit() : super([]);

  // Add product to the cart
  void addToCart(Product product, int quantity) {
    if (quantity > 0) {
      final updatedCart = List<Map<String, dynamic>>.from(state);
      updatedCart.add({'product': product, 'quantity': quantity});
      emit(updatedCart);
    }
  }

  
  // Calculate the total cost
  double get totalCost {
    return state.fold(0, (sum, item) {
      return sum + (item['product'].price * item['quantity']);
    });
  }
}
