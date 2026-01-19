import 'dart:convert';

import 'package:http/http.dart' as http;

class StripeService {
  static const String _paymentIntentUrl =
      'https://us-central1-clayamour04.cloudfunctions.net/createPaymentIntent';

  static Future<String> createPaymentIntent({
    required int amount,
    required String currency,
  }) async {
    final response = await http.post(
      Uri.parse(_paymentIntentUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amount,
        'currency': currency,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create payment intent: ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final clientSecret = payload['clientSecret'] as String?;
    if (clientSecret == null || clientSecret.isEmpty) {
      throw Exception('Missing client secret from Stripe response.');
    }
    return clientSecret;
  }
}
