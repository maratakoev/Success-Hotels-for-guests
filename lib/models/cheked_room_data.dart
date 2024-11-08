class CheckIn {
  final int roomId; // ID номера
  final String checkInDate; // Дата и время заезда

  CheckIn({
    required this.roomId,
    required this.checkInDate,
  });

  // Метод для преобразования объекта в JSON-формат
  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'check_in_date': checkInDate,
    };
  }
}
