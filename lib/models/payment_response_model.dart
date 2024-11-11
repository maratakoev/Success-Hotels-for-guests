class PaymentResponse {
  final bool success;
  final String confirmationUrl;

  PaymentResponse({required this.success, required this.confirmationUrl});

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      success: json['success'],
      confirmationUrl: json['confirmation_url'],
    );
  }
}
