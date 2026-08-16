class CartItem {
  final String productId;
  final String name;
  final double price;
  final String emoji;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.emoji,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;
}
