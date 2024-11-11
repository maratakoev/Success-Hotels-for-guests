import 'package:flutter/material.dart';
import 'package:hotels_clients_app/09_payment.dart';
import 'package:hotels_clients_app/models/services_response.dart';
import './styles.dart';
import '08_dialog_window.dart';
import './repository/api_service.dart';
import './models/services.dart';

class Services extends StatefulWidget {
  final ApiService apiService = ApiService(); // Создаем экземпляр ApiService

  Services({super.key});

  @override
  State<Services> createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  List<Service>? services; // Переменная для хранения списка услуг
  bool isLoading = true; // Флаг для отображения загрузки

  @override
  void initState() {
    super.initState();
    fetchServices(); // Вызываем метод для загрузки услуг
  }

  Future<void> fetchServices() async {
    final fetchedServices = await widget.apiService.fetchServices();
    if (fetchedServices != null) {
      setState(() {
        services = fetchedServices; // Обновляем список услуг
        isLoading = false; // Снимаем флаг загрузки
      });
    } else {
      setState(() {
        isLoading = false; // В случае ошибки снимаем флаг загрузки
      });
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
            'Сервисы',
            style: navBarHeader,
          ),
          const SizedBox(height: 16),
          isLoading
              ? const CircularProgressIndicator(
                  color: Colors.green,
                )
              : Expanded(
                  child: RefreshIndicator(
                    color: Colors.green,
                    onRefresh: fetchServices, // Метод для обновления при свайпе
                    child: ServicesList(services: services!),
                  ),
                ),
          // Expanded(child: ServicesList()),
        ],
      ),
    );
  }
}

class ServicesUnit extends StatefulWidget {
  final int id;
  final String title;
  final String imagePath;
  final String price;
  final String currency;
  final String description;
  final Service
      service; // Передаем модель данных Service(список услуг от сервера)
  final ApiService apiService; // Добавляем ApiService

  const ServicesUnit({
    super.key,
    required this.title,
    required this.imagePath,
    required this.price,
    required this.currency,
    required this.description,
    required this.service,
    required this.id,
    required this.apiService,
  });

  @override
  State<ServicesUnit> createState() => _ServicesUnitState();
}

class _ServicesUnitState extends State<ServicesUnit> {
  String capitalize(String text) {
    return text.isNotEmpty
        ? text[0].toUpperCase() + text.substring(1).toLowerCase()
        : '';
  }

  // Метод для отображения сообщения об ошибке
  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xffeff1f3),
          title: Text('Ошибка'),
          content: Text(message),
          actions: <Widget>[],
        );
      },
    );
  }

  void _showServiceDetail() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: Duration(milliseconds: 600),
      pageBuilder: (context, animation1, animation2) {
        return ServiceDetailPage(
          title: widget.title,
          imagePath: widget.imagePath,
          price: widget.price,
          currency: widget.currency,
          description: widget.description,
          service: widget.service,
          id: widget.id,
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, -1), // Начальная позиция сверху
            end: Offset.zero, // Положение при появлении на экране
          ).animate(CurvedAnimation(
            parent: animation1,
            curve: Curves.bounceOut, // Подпрыгивание при появлении
            reverseCurve: Curves.linear, // Линейное движение при закрытии
          )),
          child: FadeTransition(
            opacity: animation1, // Плавное исчезновение
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (widget.service.options != null &&
            widget.service.options!.isNotEmpty) {
          // Если у услуги есть опции, показываем анимированное диалоговое окно
          _showServiceDetail();
        } else {
          // Логика для случаев, когда опций нет
          try {
            final serviceRequest = ServiceRequest(
              responseServiceId: widget.id,
              responseOptions: null,
            );
            final response =
                await widget.apiService.sendServiceRequest(serviceRequest);
            print('Ответ сервера: ${response.data}');

            if (response.data['success']) {
              final confirmationUrl = response.data['confirmation_url'];
              if (confirmationUrl != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Payment(confirmationUrl: confirmationUrl),
                  ),
                );
              } else {
                _showErrorMessage('Ошибка: confirmation_url равен null');
              }
            } else {
              _showErrorMessage(
                  'Ошибка при создании заказа: ${response.data['message']}');
            }
          } catch (e) {
            _showErrorMessage('Ошибка при создании заказа: $e');
          }
        }
      },
      child: Container(
        width: 326,
        height: 91,
        decoration: BoxDecoration(
            border: Border.all(color: const Color.fromRGBO(244, 244, 244, 1)),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
          child: Row(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                width: 240,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      capitalize(widget.title), // Применяем метод capitalize
                      style: dropDownButtonText,
                    )
                  ],
                ),
              ),
              const Expanded(child: SizedBox()),
              Container(
                width: 57,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 25, child: Image.asset(widget.imagePath)),
                    Row(
                      children: [
                        Text(
                          '${widget.price} ${widget.currency}',
                          style: clientsNavBar,
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ServicesList extends StatelessWidget {
  final List<Service> services;
  final ApiService apiService = ApiService(); // Создаем экземпляр ApiService

  ServicesList({
    super.key,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero, // Убирает внутренние отступы

      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index]; // Получаем конкретную услугу
        return Padding(
          padding:
              EdgeInsets.only(bottom: index == services.length - 1 ? 0 : 16),
          child: ServicesUnit(
            title: service.name,
            imagePath: 'assets/images/${service.icon}', // Путь к изображению
            price: service.price, // Цена услуги
            currency: service.currency,
            description: service.description, service: service, // Валюта
            id: service.id,
            apiService: apiService,
          ),
        );
      },
    );
  }
}
