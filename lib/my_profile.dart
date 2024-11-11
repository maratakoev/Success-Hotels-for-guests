import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hotels_clients_app/05_login_form.dart';
import './styles.dart';
import './repository/api_service.dart';
import './models/user_info.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage =
      FlutterSecureStorage(); // Инициализация хранилища

  Profile? _profile;
  bool _isLoading = true; // Флаг для отслеживания состояния загрузки

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  void fetchProfileData() async {
    final profile = await _apiService.fetchProfile();
    setState(() {
      _profile = profile;
      _isLoading =
          false; // Останавливаем индикатор загрузки после загрузки данных
    });
    if (profile != null) {
      print('Profile data: ${profile.firstName}');
    } else {
      print('Failed to fetch profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 50, left: 20.0, right: 20),
      height: 800,
      width: 370,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset('assets/images/logo.png'),
          const SizedBox(height: 24),
          const Text(
            'Мои профиль',
            style: navBarHeader,
          ),
          Expanded(
            child: _isLoading
                ? const Align(
                    alignment: Alignment
                        .topCenter, // Перемещает крутилку в верхнюю часть

                    child: Column(
                      children: [
                        SizedBox(
                          height: 16,
                        ),
                        CircularProgressIndicator(
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ) // Крутилка
                : ListView(
                    padding: EdgeInsets.zero, // Убирает внутренние отступы

                    children: [
                      const SizedBox(height: 16),
                      PersonalInfo(
                        profile: _profile,
                        storage: _storage,
                      ),
                      const SizedBox(height: 16),
                      const AccauntDelete(),
                      const SizedBox(height: 20),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class PersonalInfo extends StatelessWidget {
  final FlutterSecureStorage storage;

  final Profile? profile; // Добавляем поле для профиля

  const PersonalInfo({super.key, this.profile, required this.storage});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(90, 108, 234, 0.07), // Красный цвет
            // Цвет тени с прозрачностью
            spreadRadius: 0.1, // Насколько далеко тень распространяется
            blurRadius: 17, // Радиус размытия тени
            offset: Offset(2, 10), // Смещение тени по горизонтали и вертикали
          ),
        ],
        borderRadius: BorderRadius.all(Radius.circular(15)),
        color: Color.fromARGB(255, 255, 255, 255), // Красный цвет
      ),
      height: 172,
      width: 346,
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Stack(
            children: [
              Align(
                  alignment: Alignment.center,
                  child: Text(
                    profile?.fullName ?? 'Имя не найдено',
                    style: scannerTextStyle,
                  )),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: GestureDetector(
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                                'Вы уверены, что хотите выйти из аккаунта?'),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  // Очистка токена
                                  await storage.delete(key: 'token');
                                  // Сообщение об успешном удалении токена
                                  String? token = await storage.read(
                                      key:
                                          'token'); // Чтение токена после удаления
                                  print(
                                      'Token after deletion: $token'); // Вывод значения токена, должно быть null                      // Переход на экран авторизации

                                  // Закрыть диалог и перейти на страницу логина
                                  Navigator.pop(context); // Закрытие диалога
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginForm(),
                                    ),
                                  );
                                },
                                child: Text('Да'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Просто закрыть диалог
                                  Navigator.pop(context);
                                },
                                child: Text('Нет'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: SizedBox(
                      width: 25,
                      child: Image.asset('assets/images/logOut.png'),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            profile?.email ?? 'Почта не найденa',
            style: ordersHeaderText,
          ),
          const SizedBox(
            height: 26,
          ),
          const ButtonLogOut()
        ],
      ),
    );
  }
}

class ButtonLogOut extends StatefulWidget {
  const ButtonLogOut({super.key});

  @override
  State<ButtonLogOut> createState() => _ButtonLogOutState();
}

class _ButtonLogOutState extends State<ButtonLogOut> {
  final ApiService _apiService = ApiService(); // Инициализация ApiService
  late BuildContext _dialogContext; // Сохранение ссылки на контекст

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dialogContext = context; // Сохраняем ссылку на текущий контекст
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 47,
      decoration: logOutButtonStyle,
      child: TextButton(
        onPressed: () {
          showDialog(
            context: _dialogContext, // Используем сохранённый контекст
            builder: (BuildContext context) {
              return AlertDialog(
                title:
                    const Text('Вы уверены, что хотите выселиться из номера?'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(
                          _dialogContext); // Используем сохранённый контекст

                      try {
                        final response = await _apiService.checkOut();
                        print(
                            'Ответ сервера: ${response.data}'); // Добавлено для отладки

                        if (response.data['success'] == true) {
                          print('Вы успешно выселились.');

                          if (mounted) {
                            Navigator.pushReplacement(
                              _dialogContext,
                              MaterialPageRoute(
                                builder: (context) => const LoginForm(),
                              ),
                            );
                          }
                        } else {
                          print('Не удалось выселиться. Попробуйте снова.');
                          if (mounted) {
                            ScaffoldMessenger.of(_dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('Ошибка при выселении.'),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        print('Ошибка: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(_dialogContext).showSnackBar(
                            SnackBar(
                              content: Text('Произошла ошибка: $e'),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Да'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(_dialogContext);
                    },
                    child: const Text('Нет'),
                  ),
                ],
              );
            },
          );
        },
        child: const Text('Выселиться', style: logOutButtonTextStyle),
      ),
    );
  }
}

class AccauntDelete extends StatelessWidget {
  const AccauntDelete({super.key});

  Future<void> deleteAccount(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Вы уверены, что хотите удалить аккаунт?'),
          content: const Text('Это действие необратимо.'),
          actions: [
            TextButton(
              onPressed: () async {
                // Выполнение запроса на удаление аккаунта
                try {
                  final response = await ApiService()
                      .deleteAccount(); // Замените на ваш ApiService
                  if (response.data['success'] == true) {
                    print('Аккаунт успешно удален');

                    // Переход на экран авторизации
                    Navigator.pop(context); // Закрыть диалог
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginForm(),
                      ),
                    );
                  } else {
                    print('Ошибка при удалении аккаунта');
                    // Здесь можно добавить обработку ошибки, например, вывод сообщения пользователю
                  }
                } catch (e) {
                  print('Ошибка при выполнении запроса: $e');
                  // Обработка ошибки
                }
              },
              child: const Text('Да'),
            ),
            TextButton(
              onPressed: () {
                // Просто закрыть диалог
                Navigator.pop(context);
              },
              child: const Text('Нет'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => deleteAccount(context), // Вызов метода удаления аккаунта
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 25, child: Image.asset('assets/images/bin.png')),
          const SizedBox(width: 5),
          const Text('Удалить аккаунт', style: logOutButtonTextStyle),
        ],
      ),
    );
  }
}

// class PersonalPreference extends StatelessWidget {
//   const PersonalPreference({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             color: Color.fromRGBO(90, 108, 234, 0.07), // Красный цвет
//             // Цвет тени с прозрачностью
//             spreadRadius: 0.1, // Насколько далеко тень распространяется
//             blurRadius: 17, // Радиус размытия тени
//             offset: Offset(2, 10), // Смещение тени по горизонтали и вертикали
//           ),
//         ],
//         borderRadius: BorderRadius.all(Radius.circular(15)),
//         color: Color.fromARGB(255, 255, 255, 255), // Красный цвет
//       ),
//       height: 255,
//       width: 350,
//     );
//   }
// }
