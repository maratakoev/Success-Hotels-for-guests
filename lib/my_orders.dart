import 'package:flutter/material.dart';
import 'package:hotels_clients_app/models/orders.dart';
import 'package:hotels_clients_app/repository/api_orders.dart';
import './styles.dart';
import 'package:intl/intl.dart'; //это пакет для форматирования вермени

class Orders extends StatefulWidget {
  final ApiOrders apiOrders = ApiOrders();

  Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  List<Order>? orders; // Типизированный список заказов
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final fetchedOrders = await widget.apiOrders.fetchOrders();
    if (fetchedOrders != null) {
      setState(() {
        orders =
            fetchedOrders.orders; // Извлекаем список заказов из fetchedOrders
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
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
            'Мои запросы',
            style: navBarHeader,
          ),
          const SizedBox(height: 16),
          isLoading
              ? const CircularProgressIndicator(color: Colors.green)
              : Expanded(
                  child: RefreshIndicator(
                    color: Colors.green,
                    onRefresh:
                        fetchOrders, // Метод для обновления при свайпе вниз
                    child: OrdersList(orders: orders ?? []),
                  ),
                ),
        ],
      ),
    );
  }
}

class OrdersUnit extends StatelessWidget {
  final int orderUnitId;
  final String serviceName;
  final DateTime createdAt;
  final int status; // Добавлено поле статуса

  const OrdersUnit({
    super.key,
    required this.orderUnitId,
    required this.serviceName,
    required this.createdAt,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    String formattedTime = DateFormat('HH:mm').format(createdAt);

    // Определяем путь к изображению на основе статуса
    String imagePath;
    if (status == 1) {
      imagePath = 'assets/images/proceseeng.png';
    } else if (status == 2) {
      imagePath = 'assets/images/done.png';
    } else if (status == 3) {
      imagePath = 'assets/images/canceled.png';
    } else {
      imagePath =
          'assets/images/default.png'; // Опционально, изображение по умолчанию
    }
    // Определяем текст статуса на основе статуса

    Widget orderStatus;
    if (status == 1) {
      orderStatus = const Text(
        'в процессе',
        style: orderStatusTextStyle,
      );
    } else if (status == 2) {
      orderStatus = const Text(
        'выполнено',
        style: orderStatusDoneTextStyle,
      );
    } else if (status == 3) {
      orderStatus = const Text(
        'не принято',
        style: orderStatusTextStyle,
      );
    } else {
      orderStatus = const Text(
        'неизвестный статус',
        style: orderStatusTextStyle,
      ); // Значение по умолчанию
    }

    // Определяем кнопку "отмена" на основе статуса
    Widget orderCanceledButton(int status) {
      String canceledText;

      if (status == 1) {
        canceledText = 'отменить';
      } else if (status == 2) {
        canceledText = ''; // Пустой текст для статуса 2
      } else if (status == 3) {
        canceledText = 'отменить';
      } else {
        canceledText = 'Неизвестный статус';
      }

      // Проверяем, есть ли текст. Если да, то делаем его кликабельным.
      if (canceledText.isNotEmpty) {
        return GestureDetector(
          onTap: () {
            // Действие при нажатии
          },
          child: Text(
            canceledText,
            style: orderCanceledTextStyle,
          ),
        );
      } else {
        // Если текста нет, возвращаем просто пустой виджет или некликабельный элемент.
        return const SizedBox.shrink();
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        border: Border.all(color: const Color.fromRGBO(244, 244, 244, 1)),
      ),
      width: 350,
      height: 100,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 190,
                  child: Text(
                    serviceName
                        .capitalize(), // Применяем метод capitalize сам метод ниже виджета описан
                    style: scannerTextStyle,
                  ),
                ),
                const Expanded(child: SizedBox()),
                Row(
                  children: [
                    Image.asset(imagePath),
                    const SizedBox(width: 8),
                    Text(formattedTime),
                  ],
                ),
              ],
            ),
            const Expanded(child: SizedBox()),
            Column(
              children: [
                orderCanceledButton(status),
                const Expanded(child: SizedBox()),
                orderStatus,
              ],
            )
          ],
        ),
      ),
    );
  }
}

// Расширение для метода capitalize
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class OrdersList extends StatelessWidget {
  final List<Order> orders;

  OrdersList({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero, // Убирает внутренние отступы

      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Padding(
          padding: EdgeInsets.only(bottom: index == orders.length - 1 ? 0 : 16),
          child: OrdersUnit(
            orderUnitId: order.id, // Предположим, что у вас есть поле id
            serviceName: order.service.name,
            createdAt: order.createdAt,
            status: order.status, // Используйте название услуги из заказа
          ),
        );
      },
    );
  }
}
