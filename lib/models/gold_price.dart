class GoldPrice {
  final int? id;
  final String type;
  final double buyPrice;
  final double sellPrice;
  final DateTime date;

  GoldPrice({
    this.id,
    required this.type,
    required this.buyPrice,
    required this.sellPrice,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'buy_price': buyPrice,
      'sell_price': sellPrice,
      'date': date.toIso8601String(),
    };
  }

  factory GoldPrice.fromMap(Map<String, dynamic> map) {
    return GoldPrice(
      id: map['id'],
      type: map['type'],
      buyPrice: map['buy_price'],
      sellPrice: map['sell_price'],
      date: DateTime.parse(map['date']),
    );
  }
} 