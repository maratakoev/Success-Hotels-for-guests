import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hotels_clients_app/models/user_info.dart';
import '../models/organization.dart';
import '../models/rooms.dart';
import '../models/services.dart';
import '../models/services_response.dart';

class ApiService {
  final Dio _dio = Dio(); // Инициализация Dio
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage(); // Инициализация Secure Storage
  final FlutterSecureStorage storage =
      FlutterSecureStorage(); // Создаем экземпляр хранилища

  // Метод для удаления аккаунта
  Future<Response> deleteAccount() async {
    try {
      // Получаем токен из хранилища
      String? token = await _storage.read(key: 'token');

      // Отправляем GET-запрос на указанный URL
      final response = await _dio.get(
        'https://app.successhotel.ru/api/client/profile/destroy', // URL для удаления аккаунта
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Добавляем токен в заголовки
            'Accept': 'application/json', // Указываем ожидаемый тип данных
          },
        ),
      );

      // Проверяем ответ сервера
      if (response.data['success'] == true) {
        print('Аккаунт успешно удален');
      } else {
        print('Ошибка при удалении аккаунта');
      }

      return response; // Возвращаем ответ сервера
    } catch (e) {
      // Обработка ошибок
      throw Exception('Ошибка при выполнении запроса на удаление аккаунта: $e');
    }
  }

  // Метод для запроса выселения из номера
  Future<Response> checkOut() async {
    try {
      // Получаем токен из хранилища
      String? token = await _storage.read(key: 'token');

      // Отправляем GET-запрос на указанный URL
      final response = await _dio.get(
        'https://app.successhotel.ru/api/client/check-out', // URL для выселения
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Добавляем токен в заголовки
            'Accept': 'application/json', // Указываем ожидаемый тип данных
          },
        ),
      );

      // Проверяем ответ сервера
      if (response.data['success'] == true) {
        print('Выселение прошло успешно');
      } else {
        print('Ошибка при выселении');
      }

      return response; // Возвращаем ответ сервера
    } catch (e) {
      // Обработка ошибок
      throw Exception('Ошибка при выполнении запроса на выселение: $e');
    }
  }

  //Получаем инфу профиля
  Future<Profile?> fetchProfile() async {
    try {
      // Получаем токен
      String? token = await storage.read(key: 'token');

      final response = await _dio.get(
        'https://app.successhotel.ru/api/client/profile', // URL для запроса профиля
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Добавляем токен в заголовок
            'User-Agent':
                'YourAppName/1.0.0', // Идентификация приложения (опционально)
            'Accept': 'application/json', // Ожидаемый тип данных
          },
        ),
      );

      // Логируем ответ
      print('Response from server: ${response.data}');

      if (response.statusCode == 200) {
        // Парсим JSON и создаем объект профиля
        final profileJson = response.data['profile'];
        return Profile.fromJson(profileJson);
      } else {
        print('Error: ${response.statusCode}'); // Логируем код ошибки
      }
    } catch (e) {
      print('Error fetching profile: $e'); // Логируем исключения
    }
    return null; // Возвращаем null в случае ошибки
  }

//Получаем список заказанных услуг
  Future<Response> sendServiceRequest(ServiceRequest request) async {
    try {
      // Получаем токен из хранилища
      String? token = await _storage.read(key: 'token');

      // Выводим данные POST-запроса в консоль
      print("Данные POST-запроса: ${request.toJson()}");

      // Отправляем POST-запрос на нужный URL
      final response = await _dio.post(
        'https://app.successhotel.ru/api/client/orders/create', // URL для отправки запроса
        data: request.toJson(), // Преобразуем объект в JSON
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Добавляем токен в заголовки
            'Content-Type': 'application/json', // Указываем тип содержимого
          },
        ),
      );
      return response; // Возвращаем ответ сервера
    } catch (e) {
      // Обработка ошибок
      throw Exception('Ошибка при отправке запроса: $e');
    }
  }

  Future<List<Service>?> fetchServices() async {
    try {
      // Получаем токен
      String? token = await storage.read(key: 'token');
      print('Полученный токен: $token'); // Логируем полученный токен

      final response = await _dio.get(
        'https://app.successhotel.ru/api/client/services',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Добавляем токен в заголовок
            'User-Agent':
                'YourAppName/1.0.0', // (опционально) Идентификация приложения
            'Accept': 'application/json', // (опционально) Ожидаемый тип данных
          },
        ),
      );

      // Логируем ответ
      print('Response from server: ${response.data}');

      if (response.statusCode == 200) {
        // Логируем код статуса
        print('Успешный ответ: ${response.statusCode}');

        // Парсим JSON и создаем список услуг
        final servicesJson = response.data['services'] as List;
        print(
            'Полученные услуги: $servicesJson'); // Логируем полученный массив услуг

        return servicesJson
            .map((service) => Service.fromJson(service))
            .toList();
      } else {
        // Логируем код ошибки
        print('Error: ${response.statusCode}'); // Логируем код ошибки
        print(
            'Ответ сервера: ${response.data}'); // Логируем данные ответа для диагностики
      }
    } catch (e) {
      // Логируем исключения
      print('Error fetching services: $e'); // Логируем исключения
    }
    return null; // Возвращаем null в случае ошибки
  }

  // Метод для бронирования номера
  Future<Response> bookRoom(int roomId, DateTime checkInDate) async {
    const String url =
        'https://app.successhotel.ru/api/client/check-in'; // Ваш URL

    // Создание данных для отправки в нужном формате
    final data = {
      'room_id': roomId, // ID выбранной комнаты
      'check_in_date':
          '${checkInDate.year}-${checkInDate.month.toString().padLeft(2, '0')}-${checkInDate.day.toString().padLeft(2, '0')} ${checkInDate.hour.toString().padLeft(2, '0')}:${checkInDate.minute.toString().padLeft(2, '0')}', // Форматируем дату
    };

    // Выводим данные в консоль перед отправкой
    print('Отправляемые данные: $data');

    try {
      // Выполнение POST-запроса
      final response = await _dio.post(
        url,
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json', // Указываем тип содержимого
            'Accept': 'application/json', // Ожидаемый тип данных
          },
        ),
      );
      return response; // Возвращаем ответ сервера
    } catch (e) {
      // Обработка ошибок
      print('Ошибка при отправке запроса: $e');
      rethrow; // Пробрасываем ошибку выше
    }
  }

// Метод для получения списка номеров по ID отеля
  Future<List<Rooms>> getRoomsByHotelId(int hotelId) async {
    String? token = await _storage.read(key: 'token'); // Получаем токен

    try {
      final response = await _dio.get(
        'https://app.successhotel.ru/api/client/organizations/$hotelId/rooms', // URL для списка номеров отеля
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Токен
            'User-Agent': 'HotelsApp/1.0.0', // Идентификация приложения
            'Accept': 'application/json', // Ожидаемый тип данных
          },
        ),
      );

      // Выводим полный ответ от сервера в консоль
      print('Ответ от сервера: ${response.data}');

      if (response.statusCode == 200) {
        // Преобразуем ответ в список объектов Room
        var roomsList = response.data['rooms'] as List;
        List<Rooms> rooms =
            roomsList.map((roomJson) => Rooms.fromJson(roomJson)).toList();

        return rooms;
      } else {
        throw Exception('Ошибка при получении списка номеров');
      }
    } catch (e) {
      print('Произошла ошибка: $e');
      rethrow; // Пробрасываем ошибку дальше
    }
  }

  // запрос списка отелей
  Future<OrganizationResponse> getHotels() async {
    String? token = await _storage.read(key: 'token'); // Получаем токен

    final response = await _dio.get(
      'https://app.successhotel.ru/api/client/organizations', // URL для списка отелей
      options: Options(
        headers: {
          'Authorization': 'Bearer $token', // Токен
          'User-Agent': 'HotelsApp/1.0.0', // Идентификация приложения
          'Accept': 'application/json', // Ожидаемый тип данных
        },
      ),
    );

    // Выводим ответ сервера в консоль
    print('Ответ от сервера: ${response.data}');

    // Парсим ответ в модель OrganizationResponse
    OrganizationResponse organizationResponse =
        OrganizationResponse.fromJson(response.data);

    // Возвращаем объект OrganizationResponse
    return organizationResponse;
  }

  // Метод для регистрации пользователя
  Future<Response> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    required String guard,
  }) async {
    const String registerUrl =
        'https://app.successhotel.ru/api/client/register';

    try {
      final Map<String, dynamic> registrationData = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'guard': guard,
      };

      final Response response =
          await _dio.post(registerUrl, data: registrationData);

      return response;
    } catch (e) {
      print('Произошла ошибка: $e');
      rethrow; // Пробрасываем ошибку дальше
    }
  }

  // Метод для входа пользователя
  Future<Response> loginUser({
    required String email,
    required String password,
  }) async {
    const String loginUrl = 'https://app.successhotel.ru/api/client/login';

    try {
      final Map<String, dynamic> loginData = {
        'email': email,
        'password': password,
      };

      final Response response = await _dio.post(loginUrl, data: loginData);
      print('Response from server: ${response.data}'); // Полный ответ

      // Проверка успешности логина
      if (response.data['success'] == true) {
        String token = response.data['token']; // Извлекаем токен
        await TokenStorage().saveToken(token); // Сохраняем токен
        print('Token saved: $token'); // Выводим в консоль
      } else {
        print('Login failed: ${response.data['message']}'); // В случае ошибки
      }

      return response;
    } catch (e) {
      print('Произошла ошибка: $e');
      rethrow; // Пробрасываем ошибку дальше
    }
  }
}

// Тут сохраним токен.
class TokenStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _key = 'token'; // Ключ для хранения токена

  // Метод для сохранения токена
  Future<void> saveToken(String token) async {
    await _storage.write(key: _key, value: token);
  }

  // Метод для получения токена
  Future<String?> getToken() async {
    return await _storage.read(key: _key);
  }

  // Метод для удаления токена
  Future<void> deleteToken() async {
    await _storage.delete(key: _key);
  }

  // Новый метод для вывода токена в консоль
  Future<void> printToken() async {
    String? token = await getToken();
    if (token != null) {
      print('Токен: $token');
    } else {
      print('Токен не найден.');
    }
  }
}
