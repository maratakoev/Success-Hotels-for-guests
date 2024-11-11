// ignore_for_file: avoid_print, use_build_context_synchronously, library_private_types_in_public_api, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:hotels_clients_app/09_payment.dart';
import './styles.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import './models/services.dart';
import './models/services_response.dart';
import './repository/api_service.dart';

class ServiceDetailPage extends StatefulWidget {
  final String title;
  final String imagePath;
  final String price;
  final String description;
  final Service service;
  final int id;

  const ServiceDetailPage({
    super.key,
    required this.title,
    required this.imagePath,
    required this.price,
    required String currency,
    required this.description,
    required this.service,
    required this.id,
  });

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false; // Переменная для отслеживания состояния загрузки
  late TextEditingController _controller;
  late List<bool> _checkListItems;
  int _numberInputValue = 0;
  String _inputText = '';
  String? _selectedDropDownValue;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    int itemCount = widget.service.options
            ?.firstWhere((option) => option.type == 3,
                orElse: () => Option(type: 0, name: '', values: []))
            .values
            ?.length ??
        0;

    // Инициализируем _checkListItems на основе длины списка опций
    _checkListItems = List.generate(itemCount,
        (index) => false); // тут высчитываем количество строк в чеклисте
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('ID услуги:  ${widget.id}');
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), color: Colors.white),
        width: MediaQuery.of(context).size.width *
            0.99, // Установите ширину на 90% от ширины экрана
        padding: const EdgeInsets.all(20),

        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize
                .min, // Заставляем диалог занимать минимально возможное пространство
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Дополнительные услуги',
                      // widget.title[0].toUpperCase() + widget.title.substring(1),
                      style: scannerTextStyle,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.description.isNotEmpty) Text(widget.description),
                ],
              ),
              DialogCheckList(
                service: widget.service,
                buttonType: 3,
                checkListItems: _checkListItems,
                onChanged: (index, value) {
                  setState(() {
                    _checkListItems[index] = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                child: DialogDropDownButton(
                  onSelected: (value) {
                    setState(() {
                      _selectedDropDownValue = value; // Обновляем значение
                    });
                    // ignore:
                    print(
                        'Выбранное ввв значение: $value'); // Проверка в консоли
                  },
                  buttonType: 4,
                  service: widget.service,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: 'Выбрать',
                controller: _controller,
                buttonType: 1,
                service: widget.service,
                onChanged: (value) {
                  setState(() {
                    _inputText = value; // Обновляем значение текста
                  });
                },
              ),
              const SizedBox(height: 16),
              NumberInputField(
                buttonType: 2,
                service: widget.service,
                onValueChanged: (value) {
                  setState(() {
                    _numberInputValue =
                        value; // Обновляем значение при изменении
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 310,
                    height: 57,
                    decoration: commonButtonStyle,
                    child: TextButton(
                      style: const ButtonStyle(),
                      onPressed: () async {
                        if (_isLoading)
                          return; // Предотвращаем повторное нажатие

                        setState(() {
                          _isLoading = true; // Начинаем загрузку
                        });

                        // Логика отправки заказа
                        print('ID услуги:  ${widget.id}');
                        print('Выбранный элемент: $_checkListItems');
                        print(
                            'Выбранный элемент: $_selectedDropDownValue'); // Выводим финальный выбор
                        print(
                            "Выбранное количество: $_numberInputValue"); // Выводим значение _numberInputValue в консоль
                        print(
                            'Bведенный текст: $_inputText'); // Выводим значение _inputText в консоль

                        // Собираем responseOptions из чек-листа
                        List<ResponseOption> responseOptions = [];

                        // Проверяем, есть ли опции в услуге
                        if (widget.service.options != null) {
                          for (var option in widget.service.options!) {
                            // Для типа 3 (чек-лист) собираем выбранные значения
                            if (option.type == 3) {
                              String values =
                                  ''; // Строка для хранения выбранных значений

                              for (int i = 0; i < _checkListItems.length; i++) {
                                if (_checkListItems[i]) {
                                  if (values.isNotEmpty) {
                                    values +=
                                        ','; // Добавляем запятую между значениями
                                  }
                                  values += option
                                      .values![i]; // Добавляем текущее значение
                                }
                              }

                              // Добавляем объект ResponseOption для типа 3
                              responseOptions.add(
                                ResponseOption(
                                  type: option.type,
                                  name: option.name,
                                  values: values.isNotEmpty ? values : null,
                                ),
                              );
                            } else {
                              // Для других типов (1 и 2) значения null
                              responseOptions.add(
                                ResponseOption(
                                  type: option.type,
                                  name: option.name,
                                  values: null, // Нет значений для этих типов
                                ),
                              );
                            }
                          }
                        }

                        // Создаем объект ServiceRequest с нужным форматированием
                        ServiceRequest request = ServiceRequest(
                          responseServiceId: widget.id,
                          responseOptions: responseOptions.isNotEmpty
                              ? responseOptions
                              : null,
                        );

                        // Вызываем метод отправки
                        try {
                          final response = await _apiService.sendServiceRequest(
                              request); // Используйте экземпляр ApiService
                          if (response.data != null) {
                            print('Ответ сервера: ${response.data}');
                            // Обработка ответа, например, если есть confirmation_url
                            final confirmationUrl =
                                response.data['confirmation_url'];
                            if (confirmationUrl != null) {
                              Navigator.of(context).pop(); // Закрыть диалог

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => Payment(
                                        confirmationUrl: confirmationUrl)),
                              );
                              // Здесь вы можете сделать что-то с confirmationUrl
                            } else {
                              print('Ошибка: confirmation_url равен null');
                            }
                          } else {
                            print('Ошибка: ответ равен null');
                          }
                        } catch (e) {
                          print('Ошибка при отправке запроса: $e');
                        } finally {
                          setState(() {
                            _isLoading = false; // Завершаем загрузку
                          });
                        }
                      },
                      child:
                          _isLoading // Если идет загрузка, показываем крутилку
                              ? const Center(
                                  child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ))
                              : const Text(
                                  'Готово',
                                  style: buttonTextStyle,
                                ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DialogCheckList extends StatelessWidget {
  final int buttonType; // Добавлено поле для buttonType
  final Service service; // Добавлено поле для сервиса

  final List<bool>
      checkListItems; //это булевый список выбранных выбран/не выбран
  final Function(int, bool)
      onChanged; //это обновление состояния после выбора пользователем элемента

  const DialogCheckList({
    super.key,
    required this.checkListItems,
    required this.onChanged,
    required this.buttonType,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    // Проверяем, существует ли хотя бы одна опция с нужным типом
    bool isOptionAvailable =
        service.options!.any((option) => option.type == buttonType);

    // Получаем имя первой опции с нужным типом, если такая существует
    String? optionName = service.options!
        .firstWhere((option) => option.type == buttonType,
            orElse: () => Option(
                type: 0,
                name: '',
                values:
                    null) // Поставьте здесь значения по умолчанию, если опция не найдена
            )
        .name;

    // Получаем опцию с нужным типом
    Option matchedOption = service.options!.firstWhere(
      (option) => option.type == buttonType,
      orElse: () => Option(
        type: 0,
        name: '',
        values: [],
      ),
    );

    // Получаем список строк для чек-листа (values)
    List<String> optionValues = matchedOption.values ?? [];

    return Offstage(
      offstage: !isOptionAvailable,
      child: Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(optionName, style: scannerTextStyle),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white, // Убедитесь, что цвет фона непрозрачный
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(90, 108, 234, 0.1), // Цвет тени
                spreadRadius: 0, // Расстояние распространения
                blurRadius: 50, // Размытие тени
                offset: Offset(12, 26), // Смещение тени (по оси X и Y)
              ),
            ],
            border: Border.all(color: const Color.fromRGBO(244, 244, 244, 1)),
            // color: Colors.amberAccent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              // Генерируем CheckboxListTile для каждого элемента в values
              ...List.generate(optionValues.length, (index) {
                return CheckboxListTile(
                  title: Text(
                    optionValues[index],
                    style: scannerTextStyle,
                  ),
                  // Используем значения из списка
                  value: checkListItems[index],
                  onChanged: (bool? value) {
                    onChanged(index, value ?? false);
                  },
                );
              }),
            ],
          ),
        )
      ]),
    );
  }
}

class DialogDropDownButton extends StatefulWidget {
  final List<String> items = [
    'Item1',
    'Item2',
    'Item3',
    'Item4',
  ];
  final int buttonType;
  final Service service;
  final ValueChanged<String> onSelected;

  DialogDropDownButton({
    super.key,
    required this.buttonType,
    required this.service,
    required this.onSelected,
  });

  @override
  State<DialogDropDownButton> createState() => _DialogDropDownButtonState();
}

class _DialogDropDownButtonState extends State<DialogDropDownButton> {
  String? selectedItem;

  @override
  void initState() {
    super.initState();
    selectedItem = widget.items.isNotEmpty ? widget.items.first : null;
  }

  @override
  Widget build(BuildContext context) {
    bool shouldShowDropdown = widget.service.options != null &&
        widget.service.options!.isNotEmpty &&
        widget.service.options!
            .any((option) => option.type == widget.buttonType);

    String? optionName = widget.service.options?.isNotEmpty == true
        ? widget.service.options!
            .firstWhere(
              (option) => option.type == widget.buttonType,
              orElse: () => Option(type: 0, name: '', values: null),
            )
            .name
        : null;

    return Offstage(
      offstage: !shouldShowDropdown,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(optionName ?? 'Не выбрано', style: scannerTextStyle),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(90, 108, 234, 0.1),
                  spreadRadius: 0,
                  blurRadius: 50,
                  offset: Offset(12, 26),
                ),
              ],
              border: Border.all(color: const Color.fromRGBO(244, 244, 244, 1)),
              borderRadius: BorderRadius.circular(15),
            ),
            height: 50,
            child: Center(
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  iconStyleData: IconStyleData(
                    icon: Image.asset('assets/images/arrow_down.png'),
                  ),
                  isExpanded: true,
                  hint: const Text('Выбрать', style: scannerTextStyle),
                  items: widget.items.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  value: selectedItem,
                  onChanged: (value) {
                    setState(() {
                      selectedItem = value;
                    });
                    widget.onSelected(value!);
                  },
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.only(left: 24, right: 24),
                    height: 40,
                    width: 350,
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                    padding: EdgeInsets.zero,
                  ),
                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    maxHeight: 300,
                    width: 350,
                    elevation: 8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final int buttonType; // Добавлено поле для buttonType
  final Service service; // Добавлено поле для model сервиса
  final ValueChanged<String> onChanged; // Коллбэк для передачи значения

  const CustomTextField(
      {super.key,
      required this.hintText,
      required this.controller,
      required this.buttonType,
      required this.service,
      required this.onChanged});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    // Проверяем, что options не пустое и есть хотя бы одна опция с нужным типом
    bool shouldShowDropdown = widget.service.options != null &&
        widget.service.options!.isNotEmpty &&
        widget.service.options!
            .any((option) => option.type == widget.buttonType);

    // // Получаем имя первой опции с нужным типом, если такая существует
    // String? optionName = widget.service.options!.isNotEmpty
    //     ? widget.service.options!
    //         .firstWhere(
    //           (option) => option.type == widget.buttonType,
    //           orElse: () => Option(
    //               type: 0,
    //               name: '',
    //               values: null), // Поставьте здесь значения по умолчанию
    //         )
    //         .name
    //     : null;
    return Offstage(
      offstage: !shouldShowDropdown,
      child: Column(
        children: [
          const Align(
              alignment: Alignment.centerLeft,
              child: Text('Комментарий',
                  // optionName!,
                  // Текст, если имя опции отсутствует
                  style: scannerTextStyle)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white, // Цвет фона текстового поля
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(90, 108, 234, 0.1), // Цвет тени
                  spreadRadius: 0,
                  blurRadius: 50,
                  offset: Offset(12, 26),
                ),
              ],
              border: Border.all(
                  color:
                      const Color.fromRGBO(244, 244, 244, 1)), // Цвет границы
              borderRadius: BorderRadius.circular(15), // Радиус границ
            ),
            height: 50, // Высота текстового поля
            child: TextField(
              controller: widget.controller,
              onChanged: (value) {
                // Вызываем коллбэк при изменении текста
                widget.onChanged(value);
              },
              decoration: InputDecoration(
                hintText: 'Введите текст',
                hintStyle:
                    TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
                border: InputBorder.none, // Убираем стандартную рамку
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16.0), // Отступы
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NumberInputField extends StatefulWidget {
  final int buttonType;
  final Service service;
  final ValueChanged<int> onValueChanged; // Коллбек для передачи значения

  const NumberInputField(
      {super.key,
      required this.buttonType,
      required this.service,
      required this.onValueChanged}); // Добавлено поле для buttonType

  @override
  _NumberInputFieldState createState() => _NumberInputFieldState();
}

class _NumberInputFieldState extends State<NumberInputField> {
  int _value = 0; // Начальное значение

  void _increase() {
    setState(() {
      if (_value < 22) {
        // 19 - ваше максимальное значение

        _value++; // Увеличиваем значение
        widget
            .onValueChanged(_value); // Вызываем коллбек при изменении значения
      }
    });
  }

  void _decrease() {
    setState(() {
      if (_value > 0) {
        _value--; // Уменьшаем значение, не ниже 0
        widget
            .onValueChanged(_value); // Вызываем коллбек при изменении значения
      }
    });
  }

  @override
  Widget build(BuildContext context) {
// Переменная для хранения текущего значения

    // Проверяем, что options не пустое и есть хотя бы одна опция с нужным типом
    bool shouldShowDropdown = widget.service.options != null &&
        widget.service.options!.isNotEmpty &&
        widget.service.options!
            .any((option) => option.type == widget.buttonType);

    // Получаем имя первой опции с нужным типом, если такая существует
    String? optionName = widget.service.options!.isNotEmpty
        ? widget.service.options!
            .firstWhere(
              (option) => option.type == widget.buttonType,
              orElse: () => Option(
                  type: 0,
                  name: '',
                  values: null), // Поставьте здесь значения по умолчанию
            )
            .name
        : null;
    return Offstage(
      offstage: !shouldShowDropdown,
      child: Row(
        mainAxisSize: MainAxisSize.min, // Задайте минимальный размер
        children: [
          Text(optionName!, style: scannerTextStyle),
          const Expanded(child: SizedBox()),
          IconButton(
            icon:
                Image.asset('assets/images/decrease.png'), // Кнопка уменьшения
            onPressed: _decrease,
          ),
          SizedBox(
            width: 25, // Установите фиксированную ширину
            child: TextField(
              textAlign: TextAlign.center,
              readOnly: true, // Поле только для чтения, чтобы избежать ввода
              decoration: InputDecoration(
                border: InputBorder.none, // Без рамки
                hintText: '$_value', // Отображаемое значение
              ),
            ),
          ),
          IconButton(
            icon:
                Image.asset('assets/images/increase.png'), // Кнопка увеличения
            onPressed: _increase,
          ),
        ],
      ),
    );
  }
}
