import 'package:flutter/material.dart';
import 'package:hotels_clients_app/services.dart';
import 'package:hotels_clients_app/my_profile.dart';
import 'package:hotels_clients_app/my_orders.dart';
import './styles.dart';
import 'dart:math' as math;

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    Orders(),
    Services(),
    MyProfile(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      // Проверка на изменение индекса
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 253, 255, 1),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _selectedIndex == 1
            ? null // Оставляем фон градиентом
            : Colors.white, // Фон белый при других индексах
        shape: const CircleBorder(),
        onPressed: () => _onItemTapped(1),
        child: Container(
          width: 60,
          height: 60,
          decoration: _selectedIndex == 1
              ? const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(83, 232, 139, 1),
                      Color.fromRGBO(21, 190, 119, 1),
                    ],
                  ),
                )
              : const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // Фон белый
                ),
          child: _selectedIndex == 1
              ? Image.asset(
                  'assets/images/service.png') // Иконка для выбранного индекса 1
              : SizedBox(
                  width: 20,
                  child: Image.asset('assets/images/service_black.png'),
                ), // Другая иконка для остальных случаев
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(right: 30.0, bottom: 0, left: 30),
        child: SafeArea(
          bottom: true,
          child: Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(0.2), // Цвет тени с прозрачностью
                spreadRadius: 0.1, // Насколько далеко распространяется тень
                blurRadius: 12, // Размытие тени
                offset: Offset(0, 4), // Смещение тени (x, y)
              ),
            ]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: BottomAppBar(
                color: Colors.white,
                padding: EdgeInsets.all(0),
                height: 70,
                shape: CustomCircularNotchedRectangle(
                  notchOffset: Offset(-30, 0),
                ),
                notchMargin: 10.0, // Расстояние между FAB и вырезом
                child: CustomMultiChildLayout(
                  delegate: OwnMultiChildLayoutDelegate(),
                  children: <Widget>[
                    LayoutId(
                      id: 1,
                      child: TextButton(
                        onPressed: () => _onItemTapped(0),
                        style: ButtonStyle(
                          overlayColor:
                              WidgetStateProperty.all(Colors.transparent),
                        ),
                        child: SizedBox(
                          width: 96,
                          height: 50,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/request.png',
                                color: _selectedIndex == 0
                                    ? Colors.green
                                    : Colors.black, // Изменение цвета иконки
                              ),
                              const SizedBox(height: 11),
                              Text(
                                'Мои запросы',
                                style: clientsNavBar.copyWith(
                                  color: _selectedIndex == 0
                                      ? Colors.green
                                      : Colors.black, // Изменение цвета иконки
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    LayoutId(
                      id: 2,
                      child: TextButton(
                        onPressed: () => _onItemTapped(1),
                        style: ButtonStyle(
                          overlayColor:
                              WidgetStateProperty.all(Colors.transparent),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              height: 34,
                            ),
                            Text(
                              'Сервисы',
                              style: clientsNavBar.copyWith(
                                color: _selectedIndex == 1
                                    ? Colors.green
                                    : Colors.black, // Изменение цвета иконки
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    LayoutId(
                        id: 3,
                        child: TextButton(
                            onPressed: () => _onItemTapped(2),
                            style: ButtonStyle(
                              overlayColor:
                                  WidgetStateProperty.all(Colors.transparent),
                            ),
                            child: SizedBox(
                              width: 65,
                              height: 50,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/profile.png',
                                    color: _selectedIndex == 2
                                        ? Colors.green
                                        : Colors.black,
                                  ),
                                  const SizedBox(height: 11),
                                  Text(
                                    'Профиль',
                                    style: clientsNavBar.copyWith(
                                      color: _selectedIndex == 2
                                          ? Colors.green
                                          : Colors
                                              .black, // Изменение цвета иконки
                                    ),
                                  ),
                                ],
                              ),
                            ))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomCircularNotchedRectangle extends NotchedShape {
  CustomCircularNotchedRectangle({
    this.notchOffset = const Offset(0, 0),
  });
  final Offset notchOffset;

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null || !host.overlaps(guest)) return Path()..addRect(host);
    // The guest's shape is a circle bounded by the guest rectangle.
    // So the guest's radius is half the guest width.
    final double notchRadius = guest.width / 2.0;
    // We build a path for the notch from 3 segments:
    // Segment A - a Bezier curve from the host's top edge to segment B.
    // Segment B - an arc with radius notchRadius.
    // Segment C - a Bezier curve from segment B back to the host's top edge.
    //
    // A detailed explanation and the derivation of the formulas below is
    // available at: goo.gl/Ufzrqn

    const double s1 = 30.0;
    const double s2 = 1.0;

    final double r = notchRadius;
    final double a = -1.0 * r - s2;
    final double b = host.top - guest.center.dy;

    final double n2 = math.sqrt(b * b * r * r * (a * a + b * b - r * r));
    final double p2xA = ((a * r * r) - n2) / (a * a + b * b);
    final double p2xB = ((a * r * r) + n2) / (a * a + b * b);
    final double p2yA = math.sqrt(r * r - p2xA * p2xA);
    final double p2yB = math.sqrt(r * r - p2xB * p2xB);

    final List<Offset?> p = List<Offset?>.filled(6, null);

    // p0, p1, and p2 are the control points for segment A.
    p[0] = Offset(a - s1, b);
    p[1] = Offset(a, b);
    final double cmp = b < 0 ? -1.0 : 1.0;
    p[2] = cmp * p2yA > cmp * p2yB ? Offset(p2xA, p2yA) : Offset(p2xB, p2yB);

    // p3, p4, and p5 are the control points for segment B, which is a mirror
    // of segment A around the y axis.
    p[3] = Offset(-1.0 * p[2]!.dx, p[2]!.dy);
    p[4] = Offset(-1.0 * p[1]!.dx, p[1]!.dy);
    p[5] = Offset(-1.0 * p[0]!.dx, p[0]!.dy);

    // translate all points back to the absolute coordinate system.
    for (int i = 0; i < p.length; i += 1) {
      p[i] = p[i]! + guest.center + notchOffset;
    }

    return Path()
      ..moveTo(host.left, host.top)
      ..lineTo(p[0]!.dx, p[0]!.dy)
      ..quadraticBezierTo(p[1]!.dx, p[1]!.dy, p[2]!.dx, p[2]!.dy)
      ..arcToPoint(
        p[3]!,
        radius: Radius.circular(notchRadius),
        clockwise: false,
      )
      ..quadraticBezierTo(p[4]!.dx, p[4]!.dy, p[5]!.dx, p[5]!.dy)
      ..lineTo(host.right, host.top)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();
  }
}

class OwnMultiChildLayoutDelegate extends MultiChildLayoutDelegate {
  @override
  Size getSize(BoxConstraints constraints) =>
      Size(constraints.biggest.width, 100);

  @override
  void performLayout(Size size) {
    if (hasChild(1) && hasChild(2) && hasChild(3)) {
      const double margin = 8.0;

      // Размеры для каждого элемента (например, они могут быть одинаковыми)
      final firstElementSize = layoutChild(
        1,
        BoxConstraints.loose(Size(size.width / 3, size.height)),
      );
      final secondElementSize = layoutChild(
        2,
        BoxConstraints.loose(Size(size.width / 3, size.height)),
      );
      final thirdElementSize = layoutChild(
        3,
        BoxConstraints.loose(Size(size.width / 3, size.height)),
      );

      // Позиционируем первый элемент (левый), отступая от левого края на 8 пикселей
      final firstElementYOffset = size.height / 2 - firstElementSize.height / 2;
      positionChild(1, Offset(margin, firstElementYOffset));

      // Позиционируем второй элемент (центральный) по центру контейнера
      final secondElementXOffset =
          (size.width / 2) - (secondElementSize.width / 2);
      final secondElementYOffset =
          size.height / 2 - secondElementSize.height / 2;
      positionChild(2, Offset(secondElementXOffset, secondElementYOffset));

      // Позиционируем третий элемент (правый), отступая от правого края на 8 пикселей
      final thirdElementYOffset = size.height / 2 - thirdElementSize.height / 2;
      positionChild(
          3,
          Offset(size.width - thirdElementSize.width - margin,
              thirdElementYOffset));
    }
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return true;
  }
}






// class CustomBottomAppBar extends StatelessWidget {
//   const CustomBottomAppBar({
//     super.key,
//     required this.notchMargin,
//     required this.onItemTapped,
//     required this.selectedIndex,
//   });

//   final double notchMargin;
//   final ValueChanged<int> onItemTapped;
//   final int selectedIndex;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 70,
//       decoration: BoxDecoration(
//         borderRadius: const BorderRadius.all(Radius.circular(20)),
//         color: const Color.fromARGB(255, 255, 255, 255),
//         border: Border.all(color: const Color.fromRGBO(217, 217, 217, 1)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           TextButton(
//             onPressed: () => onItemTapped(0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Image.asset('assets/images/request.png'),
//                 const SizedBox(height: 11),
//                 const Text('Мои запросы', style: clientsNavBar),
//               ],
//             ),
//           ),
//           TextButton(
//             onPressed: () => onItemTapped(1),
//             child: const Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SizedBox(height: 34),
//                 Text('Сервисы', style: clientsNavBar),
//               ],
//             ),
//           ),
//           TextButton(
//             onPressed: () => onItemTapped(2),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Image.asset('assets/images/profile.png'),
//                 const SizedBox(height: 11),
//                 const Text('Профиль', style: clientsNavBar),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// class CustomClipperWithFab extends CustomClipper<Path> {
//   CustomClipperWithFab({
//     required this.notchMargin,
//     required this.fabSize,
//   });

//   final double notchMargin;
//   final double fabSize;

//   @override
//   Path getClip(Size size) {
//     final double notchRadius = fabSize / 2.0;
//     final double center = size.width / 2.0;

//     return Path()
//       ..lineTo(center - notchRadius - notchMargin, 0)
//       ..arcToPoint(
//         Offset(center + notchRadius + notchMargin, 0),
//         radius: Radius.circular(notchRadius + notchMargin),
//         clockwise: false,
//       )
//       ..lineTo(size.width, 0)
//       ..lineTo(size.width, size.height)
//       ..lineTo(0, size.height)
//       ..close();
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }






// import 'package:flutter/material.dart';
// import 'package:hotels_clients_app/services.dart';
// import 'package:hotels_clients_app/my_profile.dart';
// import 'package:hotels_clients_app/my_orders.dart';
// import './styles.dart';

// class NavBar extends StatefulWidget {
//   const NavBar({super.key});

//   @override
//   State<NavBar> createState() => _NavBarState();
// }

// class _NavBarState extends State<NavBar> {
//   int _selectedIndex = 0;

//   static final List<Widget> _widgetOptions = <Widget>[
//     // Экран "Мои запросы"
//     Orders(),

//     // Экран "Сервисы"
//     Services(),

//     // Экран "Профиль"
//     MyProfile()
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromRGBO(250, 253, 255, 1),
//       body: SingleChildScrollView(
//         child: Align(
//           alignment: Alignment.topCenter,
//           child: Column(
//             children: [
//               const SizedBox(height: 54),
//               _widgetOptions.elementAt(_selectedIndex),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         elevation: 0,
//         shape: const CircleBorder(),
//         onPressed: () {},
//         tooltip: 'Increment',
//         child: Container(
//           width: 60,
//           height: 60,
//           decoration: const BoxDecoration(
//             shape: BoxShape.circle,
//             gradient: LinearGradient(
//               colors: [
//                 Color.fromRGBO(83, 232, 139, 1),
//                 Color.fromRGBO(21, 190, 119, 1),
//               ],
//             ),
//           ),
//           child: Image.asset('assets/images/service.png'),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
//         child: CustomBottomAppBar(
//           notchMargin: 8.0,
//           fabSize: 56.0,
//           onItemTapped: _onItemTapped,
//           selectedIndex: _selectedIndex,
//         ),
//       ),
//     );
//   }
// }

// class CustomBottomAppBar extends StatelessWidget {
//   const CustomBottomAppBar({
//     super.key,
//     required this.notchMargin,
//     required this.fabSize,
//     required this.onItemTapped,
//     required this.selectedIndex,
//   });

//   final double notchMargin;
//   final double fabSize;
//   final ValueChanged<int> onItemTapped;
//   final int selectedIndex;

//   @override
//   Widget build(BuildContext context) {
//     return ClipPath(
//       clipper: CustomClipperWithFab(
//         notchMargin: notchMargin,
//         fabSize: fabSize,
//       ),
//       child: CustomPaint(
//         child: Container(
//           height: 70,
//           decoration: BoxDecoration(
//             borderRadius: const BorderRadius.all(Radius.circular(20)),
//             color: const Color.fromARGB(255, 255, 255, 255),
//             border: Border.all(color: const Color.fromRGBO(217, 217, 217, 1)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1), // Цвет тени
//                 blurRadius: 10, // Размытие тени
//                 offset: Offset(0, 4), // Смещение тени по оси Y
//               ),
//             ],
//           ),
//           child: CustomMultiChildLayout(
//             delegate: OwnMultiChildLayoutDelegate(),
//             children: <Widget>[
//               LayoutId(
//                 id: 1,
//                 child: TextButton(
//                   onPressed: () => onItemTapped(0),
//                   child: SizedBox(
//                     width: 96,
//                     height: 50,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Image.asset('assets/images/request.png'),
//                         const SizedBox(height: 11),
//                         const Text('Мои запросы', style: clientsNavBar),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               LayoutId(
//                 id: 2,
//                 child: TextButton(
//                   onPressed: () => onItemTapped(1),
//                   child: const Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       SizedBox(
//                         height: 34,
//                       ),
//                       Text('Сервисы', style: clientsNavBar),
//                     ],
//                   ),
//                 ),
//               ),
//               LayoutId(
//                 id: 3,
//                 child: TextButton(
//                   onPressed: () => onItemTapped(2),
//                   child: SizedBox(
//                     width: 65,
//                     height: 50,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Image.asset('assets/images/profile.png'),
//                         const SizedBox(height: 11),
//                         const Text('Профиль', style: clientsNavBar),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class OwnMultiChildLayoutDelegate extends MultiChildLayoutDelegate {
//   @override
//   Size getSize(BoxConstraints constraints) =>
//       Size(constraints.biggest.width, 100);

//   @override
//   void performLayout(Size size) {
//     if (hasChild(1) && hasChild(2) && hasChild(3)) {
//       const double margin = 8.0;

//       // Размеры для каждого элемента (например, они могут быть одинаковыми)
//       final firstElementSize = layoutChild(
//         1,
//         BoxConstraints.loose(Size(size.width / 3, size.height)),
//       );
//       final secondElementSize = layoutChild(
//         2,
//         BoxConstraints.loose(Size(size.width / 3, size.height)),
//       );
//       final thirdElementSize = layoutChild(
//         3,
//         BoxConstraints.loose(Size(size.width / 3, size.height)),
//       );

//       // Позиционируем первый элемент (левый), отступая от левого края на 8 пикселей
//       final firstElementYOffset = size.height / 2 - firstElementSize.height / 2;
//       positionChild(1, Offset(margin, firstElementYOffset));

//       // Позиционируем второй элемент (центральный) по центру контейнера
//       final secondElementXOffset =
//           (size.width / 2) - (secondElementSize.width / 2);
//       final secondElementYOffset =
//           size.height / 2 - secondElementSize.height / 2;
//       positionChild(2, Offset(secondElementXOffset, secondElementYOffset));

//       // Позиционируем третий элемент (правый), отступая от правого края на 8 пикселей
//       final thirdElementYOffset = size.height / 2 - thirdElementSize.height / 2;
//       positionChild(
//           3,
//           Offset(size.width - thirdElementSize.width - margin,
//               thirdElementYOffset));
//     }
//   }

//   @override
//   bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
//     return true;
//   }
// }

// class CustomClipperWithFab extends CustomClipper<Path> {
//   CustomClipperWithFab({
//     required this.notchMargin,
//     required this.fabSize,
//   });

//   final double notchMargin;
//   final double fabSize;

//   @override
//   Path getClip(Size size) {
//     final double notchRadius = fabSize / 2.0;
//     final double center = size.width / 2.0;

//     return Path()
//       ..lineTo(center - notchRadius - notchMargin, 0)
//       ..arcToPoint(
//         Offset(center + notchRadius + notchMargin, 0),
//         radius: Radius.circular(notchRadius + notchMargin),
//         clockwise: false,
//       )
//       ..lineTo(size.width, 0)
//       ..lineTo(size.width, size.height)
//       ..lineTo(0, size.height)
//       ..close();
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }
