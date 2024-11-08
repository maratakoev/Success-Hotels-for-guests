class ProfileResponse {
  final bool success;
  final Profile profile;

  ProfileResponse({required this.success, required this.profile});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'],
      profile: Profile.fromJson(json['profile']),
    );
  }
}

class Profile {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String? phone;
  final String deviceToken;
  final bool checkedIn;
  final String fullName;
  final CurrentClientRoom? currentClientRoom;
  final int ordersCount;
  final int activeOrdersCount;

  Profile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.phone,
    required this.deviceToken,
    required this.checkedIn,
    required this.fullName,
    this.currentClientRoom,
    required this.ordersCount,
    required this.activeOrdersCount,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      middleName: json['middle_name'],
      phone: json['phone'],
      deviceToken: json['device_token'],
      checkedIn: json['checked_in'],
      fullName: json['full_name'],
      currentClientRoom: json['current_client_room'] != null
          ? CurrentClientRoom.fromJson(json['current_client_room'])
          : null,
      ordersCount: json['orders_count'],
      activeOrdersCount: json['active_orders_count'],
    );
  }
}

class CurrentClientRoom {
  final int id;
  final int clientId;
  final int roomId;
  final DateTime checkInDate;
  final DateTime? checkOutDate;
  final bool isActive;
  final Room room;

  CurrentClientRoom({
    required this.id,
    required this.clientId,
    required this.roomId,
    required this.checkInDate,
    this.checkOutDate,
    required this.isActive,
    required this.room,
  });

  factory CurrentClientRoom.fromJson(Map<String, dynamic> json) {
    return CurrentClientRoom(
      id: json['id'],
      clientId: json['client_id'],
      roomId: json['room_id'],
      checkInDate: DateTime.parse(json['check_in_date']),
      checkOutDate: json['check_out_date'] != null
          ? DateTime.parse(json['check_out_date'])
          : null,
      isActive: json['is_active'],
      room: Room.fromJson(json['room']),
    );
  }
}

class Room {
  final int id;
  final int organizationId;
  final String name;
  final String? description;
  final String qrCode;
  final bool isActive;
  final List<dynamic>
      gallery; // Если предполагается, что это будет список изображений или других элементов

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
      id: json['id'],
      organizationId: json['organization_id'],
      name: json['name'],
      description: json['description'],
      qrCode: json['qr_code'],
      isActive: json['is_active'],
      gallery: json['gallery'] ?? [], // Если поле может отсутствовать
    );
  }
}
