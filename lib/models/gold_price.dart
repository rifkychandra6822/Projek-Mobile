class GoldPrice {
  final double sell;
  final double buy;
  final String type;
  final String? info;
  final String? weight;
  final String unit;

  GoldPrice({
    required this.sell,
    required this.buy,
    required this.type,
    this.info,
    this.weight,
    required this.unit,
  });

  factory GoldPrice.fromJson(Map<String, dynamic> json) {
    return GoldPrice(
      sell: json['sell'].toDouble(),
      buy: json['buy'].toDouble(),
      type: json['type'],
      info: json['info'],
      weight: json['weight'],
      unit: json['unit'],
    );
  }
} 