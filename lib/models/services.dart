// service_model.dart

class Service {
  final int id;
  final int organizationId;
  final int staffCategoryId;
  final String price;
  final String currency;
  final String description;
  final String availableFrom;
  final String availableTo;
  final bool isActive;
  final String name;
  final List<Option>? options;
  final String icon;

  Service({
    required this.id,
    required this.organizationId,
    required this.staffCategoryId,
    required this.price,
    required this.currency,
    required this.description,
    required this.availableFrom,
    required this.availableTo,
    required this.isActive,
    required this.name,
    this.options,
    required this.icon,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    var optionsJson = json['options'] as List<dynamic>?;

    return Service(
      id: json['id'],
      organizationId: json['organization_id'],
      staffCategoryId: json['staff_category_id'],
      price: json['price'],
      currency: json['currency'],
      description: json['description'],
      availableFrom: json['available_from'],
      availableTo: json['available_to'],
      isActive: json['is_active'],
      name: json['name'],
      options: optionsJson?.map((option) => Option.fromJson(option)).toList(),
      icon: json['icon'],
    );
  }
}

class Option {
  final int type;
  final String name;
  final List<String>? values;

  Option({
    required this.type,
    required this.name,
    this.values,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    // Преобразуем строку с разделителями запятыми в список строк
    List<String>? valuesList = json['values'] != null
        ? (json['values'] as String)
            .split(',')
            .map((value) => value.trim())
            .toList()
        : null;
    return Option(
      type: json['type'],
      name: json['name'],
      values: valuesList, // Список строк вместо строки
    );
  }
}
