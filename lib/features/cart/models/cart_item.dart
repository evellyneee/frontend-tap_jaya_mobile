class CartItem {
  final String id;
  final String productName;
  final String imagePath;
  final int unitPrice;

  int quantity;
  bool isSelected;

  final String size;
  final bool extraShot;
  final bool lessIce;
  final bool lessSugar;
  final String note;

  CartItem({
    required this.id,
    required this.productName,
    required this.imagePath,
    required this.unitPrice,
    required this.quantity,
    this.isSelected = true,
    this.size = '',
    this.extraShot = false,
    this.lessIce = false,
    this.lessSugar = false,
    this.note = '',
  });

  int get totalPrice {
    return unitPrice * quantity;
  }
}
