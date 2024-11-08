import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'styles.dart';

class Payment extends StatefulWidget {
  final String confirmationUrl; // Добавляем параметр

  const Payment({super.key, required this.confirmationUrl});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  late WebViewController controller = WebViewController()
    ..loadRequest(Uri.parse(widget.confirmationUrl));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).scaffoldBackgroundColor, // Установка фона из темы

        title: const Text(
          'Оплата',
          style: commonTextStyle,
        ),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
