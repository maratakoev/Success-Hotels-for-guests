import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:hotels_clients_app/07_nav_bar.dart';
import 'package:hotels_clients_app/06_qr_scanner.dart';
import 'styles.dart';
import './repository/api_service.dart';
import './models/organization.dart'; // Не забудь импортировать модель Organization
import './models/rooms.dart';
import 'package:flutter/cupertino.dart';

// поковыряйся в пабдев бропдаун бат2, там есть примеры с разделитями вместо подчеркивания, может можно делать вместо

class AuthScreenSecond extends StatefulWidget {
  const AuthScreenSecond({super.key});

  @override
  State<AuthScreenSecond> createState() => _AuthScreenSecondState();
}

class _AuthScreenSecondState extends State<AuthScreenSecond> {
  late ApiService apiService;
  List<Organization> organizations = []; // Список объектов организаций
  Organization? selectedOrganization; // Переменная для выбранной организации
  int? hotelId; // Новая переменная для хранения ID выбранной организации
  List<Rooms> roomsList = []; // Список номеров
  Rooms? selectedRoom; // Объявляем переменную для выбранного номера

  bool isSecondDropdownSelected = false; // Состояние выбора второго дропдауна
  bool isFirstDropdownSelected = false; // Состояние выбора первого дропдауна
  bool isThirdDropdownSelected = false; // Состояние выбора третьего дропдауна
  DateTime? selectedDate; // Переменная для хранения выбранной даты
  TimeOfDay? selectedTime; // Переменная для хранения выбранного времени

  @override
  void initState() {
    super.initState();
    apiService = ApiService(); // Создаем экземпляр класса ApiService
    _loadHotels(); // Вызов метода при загрузке страницы
  }

  Future<void> _loadHotels() async {
    try {
      final response = await apiService.getHotels(); // Вызов метода getHotels
      setState(() {
        organizations = response.organizations; // Извлекаем объекты организаций
      });
      // ignore: avoid_print
      print('Список отелей: ${organizations.map((org) => org.title).toList()}');
    } catch (e) {
      // ignore: avoid_print
      print('Ошибка при получении списка отелей: $e');
    }
  }

  Future<void> onFirstDropdownChanged(Organization? organization) async {
    setState(() {
      selectedOrganization = organization; // Обновляем состояние
      isFirstDropdownSelected =
          organization != null; // Проверяем, выбран ли отель

      // Сохраняем ID в переменную hotelId
      hotelId = organization?.id;
      // Выводим информацию в консоль
      print(
          'Выбрана организация: ${organization?.title}, isFirstDropdownSelected: $isFirstDropdownSelected');
    });

    // Выводим ID в консоль
    if (hotelId != null) {
      print("ID выбранного отеля: $hotelId");

      try {
        // Вызов метода для получения номеров по ID отеля
        final rooms = await apiService.getRoomsByHotelId(hotelId!);
        setState(() {
          roomsList = rooms; // Обновляем список номеров
        });
        print('Список номеров: ${rooms.map((room) => room.name).toList()}');
      } catch (e) {
        print('Ошибка при получении номеров: $e');
      }
    }
  }

  Future<void> onSecondDropdownChanged(Rooms? room) async {
    setState(() {
      selectedRoom = room; // Сохраняем выбранный номер

      // Проверяем, выбран ли номер
      isSecondDropdownSelected = room != null; // Проверяем, выбран ли номер
    });
    // Выводим информацию в консоль
    print(
        'Выбран номер: ${room?.name}, isSecondDropdownSelected: $isSecondDropdownSelected');
  }

  Future<void> onThirdDropdownChanged(DateTime date, TimeOfDay time) async {
    setState(() {
      // Шаг 2: Проверяем, выбраны ли дата и время
      isThirdDropdownSelected = (selectedDate != null && selectedTime != null);
      selectedDate = date;
      selectedTime = time;
    });
    // Выводим информацию в консоль
    print(
        'Выбрана дата: $selectedDate, время: $selectedTime, isThirdDropdownSelected: $isThirdDropdownSelected');
  }

  // Метод для отправки запроса на бронирование
  Future<void> sendBookingRequest() async {
    // Проверяем, выбраны ли все необходимые значения
    if (hotelId != null &&
        selectedRoom != null &&
        selectedRoom!.id !=
            null && // Убедитесь, что id выбранной комнаты не null
        selectedDate != null &&
        selectedTime != null) {
      // Создаем объект DateTime для даты и времени заезда
      DateTime checkInDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      try {
        // Вызываем метод bookRoom с id выбранной комнаты
        final response = await apiService.bookRoom(hotelId!, checkInDateTime);

        // Проверяем статус ответа
        if (response.statusCode == 200) {
          print('Забронировано успешно: ${response.data}');
          // Здесь можно добавить уведомление для пользователя о успешном бронировании
        } else {
          print('Ошибка при бронировании: ${response.data}');
          // Здесь можно обработать ошибку
        }
      } catch (e) {
        print('Ошибка при отправке запроса: $e');
      }
    } else {
      print('Пожалуйста, выберите комнату, дату и время.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 253, 255, 1),
      body: Column(
        children: [
          const SizedBox(height: 87),
          // Передаем список объектов организаций в DropDownButtonFirst
          DropDownButtonFirst(
            items: organizations,
            onChanged: onFirstDropdownChanged, // Передаем коллбек
          ),
          const SizedBox(height: 18),
          DropDownButtonSecond(
            isEnabled:
                isFirstDropdownSelected, // Проверка заполнен ли перввый долпдаун
            onChanged:
                onSecondDropdownChanged, // Передаем коллбек для второго дропдауна
            hotelId: hotelId ?? 0, // Передаем ID отеля (или 0, если не выбран)
            rooms: roomsList, // Передаем список номеров
          ),
          const SizedBox(height: 18),
          DropDownButtonThird(
            onDateTimeSelected:
                (DateTime selectedDate, TimeOfDay selectedTime) {
              // Здесь обрабатываем выбранные дату и время
              print('Выбранная дата: $selectedDate, время: $selectedTime');
              // Допустим, обновляем состояние родительского виджета
              setState(() {
                this.selectedDate = selectedDate;
                this.selectedTime = selectedTime;
                isThirdDropdownSelected =
                    true; // Указываем, что третий дропдаун заполнен
              });
            },
          ),
          const SizedBox(height: 24),
          ButtonNext(
            isEnabled: isFirstDropdownSelected &&
                isSecondDropdownSelected &&
                isThirdDropdownSelected,
            onPressed: () async {
              await sendBookingRequest(); // Вызов функции бронирования
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NavBar()),
              );
            },
          ),
          // Проверяем три дропдауна

          const SizedBox(height: 32),
          const Text('или'),
          const SizedBox(height: 32),
          Button(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class DropDownButtonFirst extends StatefulWidget {
  final List<Organization> items; // Изменяем тип на List<Organization>
  final ValueChanged<Organization?> onChanged; // Обновляем тип коллбека

  const DropDownButtonFirst({
    super.key,
    required this.items,
    required this.onChanged,
  });

  @override
  State<DropDownButtonFirst> createState() => _DropDownButtonFirst();
}

class _DropDownButtonFirst extends State<DropDownButtonFirst> {
  Organization? selectedValue; // Изменяем тип на Organization

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<Organization>(
          isExpanded: true,
          hint: Row(
            children: [
              Image.asset('assets/images/room.png'),
              const SizedBox(
                width: 4,
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text(
                    'Ваш отель',
                    style: dropDownButtonText,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          items: widget.items
              .map((Organization organization) =>
                  DropdownMenuItem<Organization>(
                    value: organization,
                    child: Container(
                      decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Color.fromRGBO(244, 244, 244, 1)))),
                      child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: Text(
                            organization.title ??
                                'Без названия', // Отображаем название отеля
                            style: dropDownButtonText,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
          value: selectedValue,
          onChanged: (Organization? value) {
            setState(() {
              selectedValue = value; // Сохраняем выбранное значение
            });
            widget.onChanged(value); // Вызываем коллбек
          },
          buttonStyleData: ButtonStyleData(
            height: 57,
            width: 325,
            padding: const EdgeInsets.only(left: 14, right: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color.fromRGBO(244, 244, 244, 1),
              ),
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
            elevation: 0,
          ),
          iconStyleData: IconStyleData(
            icon: Image.asset('assets/images/arrow_down.png'),
            iconSize: 14,
            iconEnabledColor: Colors.yellow,
            iconDisabledColor: Colors.grey,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            width: 325,
            elevation: 0,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              border: Border(
                left: BorderSide(color: Color.fromRGBO(244, 244, 244, 1)),
                right: BorderSide(color: Color.fromRGBO(244, 244, 244, 1)),
                bottom: BorderSide(color: Color.fromRGBO(244, 244, 244, 1)),
              ),
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            offset: const Offset(0, 12),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(40),
              thickness: WidgetStateProperty.all<double>(6),
              thumbVisibility: WidgetStateProperty.all<bool>(true),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
            padding: EdgeInsets.only(left: 14, right: 14),
          ),
        ),
      ),
    );
  }
}

class DropDownButtonSecond extends StatefulWidget {
  final bool isEnabled; // Флаг для активации/деактивации
  final int hotelId; // ID выбранного отеля
  final List<Rooms> rooms; // Список номеров
  final ValueChanged<Rooms?>
      onChanged; // Функция обратного вызова для передачи выбранной комнаты

  const DropDownButtonSecond({
    super.key,
    required this.isEnabled,
    required this.hotelId,
    required this.rooms,
    required this.onChanged,
  });

  @override
  State<DropDownButtonSecond> createState() => _DropDownButtonSecondState();
}

class _DropDownButtonSecondState extends State<DropDownButtonSecond> {
  Rooms? selectedRoom; // Переменная для хранения выбранной комнаты

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<Rooms>(
          isExpanded: true,
          hint: Row(
            children: [
              Image.asset(
                widget.isEnabled
                    ? 'assets/images/search.png'
                    : 'assets/images/search_disabled.png',
              ),
              const SizedBox(width: 4),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text(
                    'Ваш номер',
                    style: dropDownButtonText,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          items: widget.rooms
              .map((room) => DropdownMenuItem<Rooms>(
                    value: room,
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color.fromRGBO(244, 244, 244, 1),
                          ),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: Text(
                            room.name ?? 'Без названия',
                            style: dropDownButtonText,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
          value: selectedRoom,
          onChanged: widget.isEnabled
              ? (Rooms? room) {
                  setState(() {
                    selectedRoom = room; // Сохраняем выбранную комнату
                  });
                  widget.onChanged(
                      room); // Передаём выбранную комнату в родительский виджет
                }
              : null,
          buttonStyleData: ButtonStyleData(
            height: 57,
            width: 325,
            padding: const EdgeInsets.only(left: 14, right: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color.fromRGBO(244, 244, 244, 1),
              ),
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
            elevation: 0,
          ),
          iconStyleData: IconStyleData(
            icon: Image.asset(
              widget.isEnabled
                  ? 'assets/images/arrow_down.png'
                  : 'assets/images/arrow_down_disabled.png',
            ),
            iconSize: 14,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            width: 325,
            elevation: 0,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              border: Border(
                left: BorderSide(color: Color.fromRGBO(244, 244, 244, 1)),
                right: BorderSide(color: Color.fromRGBO(244, 244, 244, 1)),
                bottom: BorderSide(color: Color.fromRGBO(244, 244, 244, 1)),
              ),
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            offset: const Offset(0, 12),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(40),
              thickness: WidgetStateProperty.all<double>(6),
              thumbVisibility: WidgetStateProperty.all<bool>(true),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
            padding: EdgeInsets.only(left: 14, right: 14),
          ),
        ),
      ),
    );
  }
}

class DropDownButtonThird extends StatefulWidget {
  final Function(DateTime, TimeOfDay)
      onDateTimeSelected; // Коллбек для передачи даты и времени

  const DropDownButtonThird({super.key, required this.onDateTimeSelected});

  @override
  State<DropDownButtonThird> createState() => _DropDownButtonThird();
}

class _DropDownButtonThird extends State<DropDownButtonThird> {
  int selectedMonth = DateTime.now().month - 1; // Индекс месяца (0-11)
  int selectedDay = DateTime.now().day - 1; // Индекс дня (0-30)
  int selectedYear = DateTime.now().year; // Год
  int selectedHour = DateTime.now().hour; // Час
  int selectedMinute = DateTime.now().minute; // Минуты
  String? selectedValue;
  TimeOfDay? selectData;
  String? selectedTime; // Объявляем переменную selectedTime

  // Список месяцев на русском языке
  final List<String> monthsInRussian = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабя'
  ];

  // Метод для выбора даты
  Future<void> _selectDate(BuildContext context) async {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(color: Colors.white),
          height: 300, // Увеличиваем высоту контейнера
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Выбор дня
                  SizedBox(
                    width: 100, // Установите желаемую ширину
                    height: 200,
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: selectedDay,
                      ),
                      onSelectedItemChanged: (int value) {
                        setState(() {
                          selectedDay = value; // Обновляем выбранный день
                        });
                      },
                      itemExtent: 32.0,
                      children: List<Widget>.generate(31, (int index) {
                        return Center(
                          child: Text('${index + 1}'), // Дни месяца от 1 до 31
                        );
                      }),
                    ),
                  ),
                  // Выбор месяца
                  SizedBox(
                    width: 110, // Установите желаемую ширину
                    height: 200,
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: selectedMonth,
                      ),
                      onSelectedItemChanged: (int value) {
                        setState(() {
                          selectedMonth = value; // Обновляем выбранный месяц
                        });
                      },
                      itemExtent: 32.0,
                      children: monthsInRussian.map((month) {
                        return Center(
                          child: Text(month), // Месяцы на русском
                        );
                      }).toList(),
                    ),
                  ),
                  // Выбор года
                  SizedBox(
                    width: 100, // Установите желаемую ширину
                    height: 200,
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: selectedYear - 2015,
                      ),
                      onSelectedItemChanged: (int value) {
                        setState(() {
                          selectedYear =
                              2010 + value; // Обновляем выбранный год
                        });
                      },
                      itemExtent: 32.0,
                      children: List<Widget>.generate(15, (int index) {
                        return Center(
                          child:
                              Text('${2015 + index}'), // Года от 2015 до 2029
                        );
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16), // Отступ между выбором даты и кнопкой
              Container(
                decoration: commonButtonStyle,
                child: TextButton(
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 30)),
                  onPressed: () {
                    Navigator.pop(context); // Закрываем модальное окно
                    _selectTime(context); // Открываем выбор времени
                  },
                  child: const Text(style: dataClockTextStyle, 'Далее'),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      // Установка выбранной даты после закрытия модального окна
      setState(() {
        selectedValue =
            '${selectedDay + 1}/${selectedMonth + 1}/$selectedYear'; // +1, так как индексы начинаются с 0
      });
    });
  }

  // Метод для выбора времени
  Future<void> _selectTime(BuildContext context) async {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(color: Colors.white),
          height: 290,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Выбор часов
                  SizedBox(
                    width: 100,
                    height: 200,
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: selectedHour,
                      ),
                      onSelectedItemChanged: (int value) {
                        setState(() {
                          selectedHour = value; // Обновляем выбранный час
                        });
                      },
                      itemExtent: 32.0,
                      children: List<Widget>.generate(24, (int index) {
                        return Center(
                          child: Text('$index'), // Часы от 0 до 23
                        );
                      }),
                    ),
                  ),
                  // Выбор минут
                  SizedBox(
                      width: 100,
                      height: 200,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedMinute ~/ 5,
                        ),
                        onSelectedItemChanged: (int value) {
                          setState(() {
                            selectedMinute = value == 12
                                ? 59
                                : value *
                                    5; // Если выбрано 12, устанавливаем 59
                          });
                        },
                        itemExtent: 32.0,
                        children: List<Widget>.generate(12, (int index) {
                          if (index == 0) {
                            return const Center(
                                child: Text('00')); // Первое значение "00"
                          } else if (index == 1) {
                            return const Center(
                                child: Text('05')); // Второе значение "05"
                          } else {
                            return Center(
                                child:
                                    Text('${index * 5}')); // Остальные значения
                          }
                        })
                          ..add(const Center(
                              child: Text('59'))), // Добавляем 59 в конец
                      )),
                ],
              ),
              Container(
                decoration: commonButtonStyle,
                child: TextButton(
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 30)),
                  onPressed: () {
                    Navigator.pop(context); // Закрываем модальное окно
                    setState(() {
                      selectedTime =
                          '$selectedHour:${selectedMinute.toString().padLeft(2, '0')}'; // Установка времени
                    });
                    // Вызов колбека с выбранными датой и временем
                    widget.onDateTimeSelected(
                      DateTime(selectedYear, selectedMonth + 1,
                          selectedDay + 1), // Выбранная дата
                      TimeOfDay(
                          hour: selectedHour,
                          minute: selectedMinute), // Выбранное время
                    );
                  },
                  child: const Text(style: dataClockTextStyle, 'Выбрать время'),
                ),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => _selectDate(context), // Обработчик нажатия
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          height: 57,
          width: 325,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color.fromRGBO(244, 244, 244, 1),
            ),
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
          child: Row(
            children: [
              Image.asset('assets/images/data.png'),
              const SizedBox(width: 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    selectedValue != null && selectedTime != null
                        ? '$selectedValue $selectedTime' // Текст с выбранной датой и временем
                        : 'Дата и время заезда', // Текст по умолчанию
                    style: dropDownButtonText,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Image.asset(
                'assets/images/arrow_down.png',
                width: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Button extends StatefulWidget {
  const Button({super.key});

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 325,
      height: 57,
      decoration: commonButtonStyle,
      child: TextButton(
        style: const ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
          ),
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const BarcodeScannerSimple()));
        },
        child: const Text(
          'Сканировать QR',
          style: buttonTextStyle,
        ),
      ),
    );
  }
}

class ButtonNext extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onPressed; // Тип для коллбека

  const ButtonNext({
    super.key,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 325,
      height: 57,
      decoration: commonButtonStyle,
      child: TextButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return Colors.grey; // Цвет для неактивной кнопки
              }
              return null; // Цвет по умолчанию, если кнопка активна
            },
          ),
        ),
        onPressed: isEnabled ? onPressed : null, // Вызов переданного метода
        child: const Text(
          'Войти',
          style: buttonTextStyle,
        ),
      ),
    );
  }
}
