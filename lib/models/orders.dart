// Основная модель для хранения успешного ответа и списка заказов
class OrdersResponse {
  final bool success;
  final List<Order> orders;

  OrdersResponse({required this.success, required this.orders});

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      success: json['success'],
      orders: (json['orders'] as List)
          .map((order) => Order.fromJson(order))
          .toList(),
    );
  }
}

// Модель для одного заказа
class Order {
  final int id;
  final int clientId;
  final int clientRoomId;
  final int? staffId;
  final int status;
  final String? clientComment;
  final String? staffComment;
  final List<Option>? options;
  final int serviceId;
  final DateTime? acceptedAt;
  final DateTime? finishedAt;
  final bool isPaid;
  final String? canceledBy;
  final String? clientFinishComment;
  final double? rating;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String price;
  final String currency;
  final bool refund;
  final Room room;
  final Service service;
  final dynamic staff;

  Order({
    required this.id,
    required this.clientId,
    required this.clientRoomId,
    this.staffId,
    required this.status,
    this.clientComment,
    this.staffComment,
    required this.options,
    required this.serviceId,
    this.acceptedAt,
    this.finishedAt,
    required this.isPaid,
    this.canceledBy,
    this.clientFinishComment,
    this.rating,
    required this.createdAt,
    required this.updatedAt,
    required this.price,
    required this.currency,
    required this.refund,
    required this.room,
    required this.service,
    this.staff,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      clientId: json['client_id'] ?? 0,
      clientRoomId: json['client_room_id'] ?? 0,
      staffId: json['staff_id'] ?? 0,
      status: json['status'] ?? 0,
      clientComment: json['client_comment'],
      staffComment: json['staff_comment'],
      options: (json['options'] as List?)
              ?.map((option) => Option.fromJson(option))
              .toList() ??
          [],
      serviceId: json['service_id'] ?? 0,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'])
          : null,
      finishedAt: json['finished_at'] != null
          ? DateTime.parse(json['finished_at'])
          : null,
      isPaid: json['is_paid'],
      canceledBy: json['canceled_by'],
      clientFinishComment: json['client_finish_comment'],
      rating: json['rating'] != null ? json['rating'].toDouble() : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      price: json['price'] ?? 0,
      currency: json['currency'] ?? 'USD',
      refund: json['refund'],
      room: Room.fromJson(json['room']),
      service: Service.fromJson(json['service']),
      staff: json['staff'],
    );
  }
}

// Модель для Room (Комната)
class Room {
  final int id;
  final int organizationId;
  final String name;
  final String? description;
  final String qrCode;
  final bool isActive;
  final List<dynamic> gallery;

  Room({
    required this.id,
    required this.organizationId,
    required this.name,
    this.description,
    required this.qrCode,
    required this.isActive,
    required this.gallery,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? 0,
      organizationId: json['organization_id'] ?? 0,
      name: json['name'],
      description: json['description'],
      qrCode: json['qr_code'],
      isActive: json['is_active'],
      gallery: json['gallery'],
    );
  }
}

// Модель для Service (Услуга)
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
  final List<Option> options;
  final String icon;
  final Map<String, bool> availability; // Понедельник-воскресенье

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
    required this.options,
    required this.icon,
    required this.availability,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? 0,
      organizationId: json['organization_id'] ?? 0,
      staffCategoryId: json['staff_category_id'] ?? 0,
      price: json['price'] ?? 0,
      currency: json['currency'] ?? 0,
      description: json['description'],
      availableFrom: json['available_from'] ?? 0,
      availableTo: json['available_to'] ?? 0,
      isActive: json['is_active'],
      name: json['name'],
      options: (json['options'] as List?)
              ?.map((option) => Option.fromJson(option))
              .toList() ??
          [],
      icon: json['icon'],
      availability: {
        'Monday': json['Monday'] ?? false,
        'Tuesday': json['Tuesday'] ?? false,
        'Wednesday': json['Wednesday'] ?? false,
        'Thursday': json['Thursday'] ?? false,
        'Friday': json['Friday'] ?? false,
        'Saturday': json['Saturday'] ?? false,
        'Sunday': json['Sunday'] ?? false,
      },
    );
  }
}

// Модель для Options
class Option {
  final int? type;
  final String name;
  final String? values;

  Option({required this.type, required this.name, this.values});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      type: json['type'] ?? 0,
      name: json['name'],
      values: json['values'],
    );
  }
}
