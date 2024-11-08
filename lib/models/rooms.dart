class Rooms {
  final int roomsId;
  final int? organizationId;
  final String? name;
  final String? descripton;
  final String? roomsQrCode;
  final bool? isActive;
  final List<dynamic>? gallery; // Массив данных

  Rooms(
      {required this.roomsId,
      this.organizationId,
      this.name,
      this.descripton,
      this.roomsQrCode,
      this.isActive,
      this.gallery});

  // Фабричный метод для создания объекта Rooms из JSON
  factory Rooms.fromJson(Map<String, dynamic> json) {
    return Rooms(
      roomsId: json['id'],
      organizationId: json['organization_id'],
      name: json['name'],
      descripton: json['description'],
      roomsQrCode: json['qr_code'],
      isActive: json['is_active'],
      gallery: json['gallery'] as List<dynamic>?, // Учтён массив
    );
  }

  int? get id => null;
}

// Модель ответа
class RoomsResponse {
  final bool success;
  final List<Rooms> rooms;

  RoomsResponse({
    required this.success,
    required this.rooms,
  });

  // Фабричный метод для создания объекта OrganizationResponse из JSON
  factory RoomsResponse.fromJson(Map<String, dynamic> json) {
    var orgList = json['rooms'] as List;
    List<Rooms> rooms =
        orgList.map((orgJson) => Rooms.fromJson(orgJson)).toList();

    return RoomsResponse(
      success: json['success'],
      rooms: rooms,
    );
  }
}
