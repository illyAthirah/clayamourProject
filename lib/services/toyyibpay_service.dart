import 'dart:convert';
import 'package:http/http.dart' as http;

class ToyyibPayService {
  // Get these from your toyyibPay account at https://toyyibpay.com/
  static const String _categoryCode = 's0jptyxe'; // e.g., 'abc123xyz'
  static const String _secretKey = 'g385duja-qt9p-ngyn-dg4v-x33aam2vbfam';
  
  // Sandbox URL for testing, use production URL when live
  //static const String _baseUrl = 'https://dev.toyyibpay.com'; // Sandbox
   static const String _baseUrl = 'https://toyyibpay.com'; // Production
  
  /// Creates a bill and returns the payment URL
  /// Returns null if bill creation fails
  static Future<String?> createBill({
    required String billName,
    required String billDescription,
    required int amountInRM,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String callbackUrl,
  }) async {
    try {
      print('Creating toyyibPay bill for RM$amountInRM...');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/index.php/api/createBill'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'userSecretKey': _secretKey,
          'categoryCode': _categoryCode,
          'billName': billName,
          'billDescription': billDescription,
          'billPriceSetting': '1', // Fixed price
          'billPayorInfo': '1', // Enable payer info
          'billAmount': (amountInRM * 100).toString(), // Convert RM to cents (RM210 = 21000 cents)
          'billReturnUrl': callbackUrl,
          'billCallbackUrl': callbackUrl,
          'billExternalReferenceNo': DateTime.now().millisecondsSinceEpoch.toString(),
          'billTo': customerName,
          'billEmail': customerEmail,
          'billPhone': customerPhone,
          'billSplitPayment': '0',
          'billSplitPaymentArgs': '',
          'billPaymentChannel': '0', // FPX
          'billContentEmail': 'Thank you for your order!',
          'billChargeToCustomer': '1', // Customer pays fee
        },
      );

      print('toyyibPay Response Status: ${response.statusCode}');
      print('toyyibPay Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        
        if (result is List && result.isNotEmpty) {
          final billData = result[0];
          final billCode = billData['BillCode'];
          
          if (billCode != null && billCode.toString().isNotEmpty) {
            // Return the payment URL
            print('Payment URL created: $_baseUrl/$billCode');
            return '$_baseUrl/$billCode';
          }
        } else if (result is Map) {
          // Check if there's an error message
          print('toyyibPay Error Response: $result');
        }
      }
      
      return null;
    } catch (e) {
      print('toyyibPay Error: $e');
      return null;
    }
  }
  
  /// Gets bill transactions for verification
  static Future<Map<String, dynamic>?> getBillTransactions(String billCode) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/index.php/api/getBillTransactions'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'billCode': billCode,
        },
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result is List && result.isNotEmpty) {
          return result[0] as Map<String, dynamic>;
        }
      }
      
      return null;
    } catch (e) {
      print('toyyibPay Error: $e');
      return null;
    }
  }
  
  /// Verifies if a payment was successful
  static Future<bool> verifyPayment(String billCode) async {
    final transaction = await getBillTransactions(billCode);
    
    if (transaction != null) {
      final status = transaction['billpaymentStatus'];
      // Status: 1 = Successful payment, 2 = Pending, 3 = Failed
      return status == '1';
    }
    
    return false;
  }
}
