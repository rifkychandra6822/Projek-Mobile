class Calculation {
  final int? id;
  final int? userId;
  final double goldWeight;
  final String priceType;
  final double unitPrice;
  final double totalPrice;
  final String currency;
  final DateTime calculatedAt;

  Calculation({
    this.id,
    this.userId,
    required this.goldWeight,
    required this.priceType,
    required this.unitPrice,
    required this.totalPrice,
    required this.currency,
    DateTime? calculatedAt,
  }) : calculatedAt = calculatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'gold_weight': goldWeight,
      'price_type': priceType,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'currency': currency,
      'calculated_at': calculatedAt.toIso8601String(),
    };
  }

  factory Calculation.fromMap(Map<String, dynamic> map) {
    return Calculation(
      id: map['id'],
      userId: map['user_id'],
      goldWeight: map['gold_weight'],
      priceType: map['price_type'],
      unitPrice: map['unit_price'],
      totalPrice: map['total_price'],
      currency: map['currency'],
      calculatedAt: DateTime.parse(map['calculated_at']),
    );
  }
} 