class ServiceItem {
  final String id;
  final String code;
  final String name;
  final String description;
  final String iconName;
  final double basePrice;
  final double estimatedHours;
  final bool isActive;

  ServiceItem({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.iconName,
    required this.basePrice,
    required this.estimatedHours,
    this.isActive = true,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconName: json['icon_name'] as String? ?? 'wrench',
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      estimatedHours: (json['estimated_hours'] as num?)?.toDouble() ?? 1.0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
