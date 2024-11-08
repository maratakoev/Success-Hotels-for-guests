import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hotels_clients_app/models/orders.dart';

class ApiOrders {
  final Dio _dio = Dio();
  final FlutterSecureStorage storage = FlutterSecureStorage();

  // Метод для получения списка заказов
  Future<OrdersResponse?> fetchOrders() async {
    try {
      // Получаем токен
      String? token = await storage.read(key: 'token');
// Логируем, что запрос отправляется
      print('Отправляется запрос на получение заказанных услуг...');
      final response = await _dio.get(
        'https://app.successhotel.ru/api/client/orders',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Добавляем токен в заголовок
            'User-Agent': 'YourAppName/1.0.0', // Идентификация приложения
            'Accept': 'application/json', // Ожидаемый тип данных
          },
        ),
      );

      // Логируем ответ
      print('Заказанные услуги от сервера: ${response.data}');

      if (response.statusCode == 200) {
        // Парсим JSON и создаем объект OrdersResponse
        return OrdersResponse.fromJson(response.data);
      } else {
        print('Error: ${response.statusCode}'); // Логируем код ошибки
      }
    } catch (e) {
      print('Error fetching orders: $e'); // Логируем исключения
    }
    return null; // Возвращаем null в случае ошибки
  }
}
