//чуть ниже класс а под ним экземпляр класса
class ServiceRequest {
  final int responseServiceId;
  final List<ResponseOption>? responseOptions;

  ServiceRequest({
    required this.responseServiceId,
    this.responseOptions,
  });

  // Метод для преобразования объекта ServiceRequest в JSON
  Map<String, dynamic> toJson() {
    return {
      'service_id': responseServiceId,
      'options':
          responseOptions?.map((option) => option.toJson()).toList() ?? [],
    };
  }
}

class ResponseOption {
  final int type;
  final String name;
  final String? values;

  // Конструктор для инициализации всех полей
  ResponseOption({
    required this.type,
    required this.name,
    required this.values,
  });

  // Метод для преобразования объекта Option в JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      'values': values,
    };
  }
}

//вот тут ниже экземпляр класса для отправки данных на сервер
void main() {
  // Создаем объект ServiceRequest
  ServiceRequest request = ServiceRequest(
    responseServiceId: 1,
    responseOptions: [
      ResponseOption(
          type: 3, name: "Название предмета", values: "jhjh, hjhjh,jhjh"),
    ],
  );

  // Преобразуем его в JSON
  Map<String, dynamic> json = request.toJson();

  // Выводим JSON в консоль
  print(json);
}
