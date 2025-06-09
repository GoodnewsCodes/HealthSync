import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:url_launcher/url_launcher.dart';

class SmsService {
  Future<void> sendPatientRegistrationSms({
    required String phoneNumber,
    required String patientName,
    BuildContext? context, // Optional for web dialogs
  }) async {
    try {
      final patientId = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '')
          .substring(phoneNumber.length - 10);

      final message = '''
HealthSync Registration Complete!
Patient: $patientName
ID: $patientId
Keep this ID for future reference.
''';

      // WEB MOCK IMPLEMENTATION
      if (kIsWeb) {
        debugPrint('[WEB MOCK] SMS would be sent to: $phoneNumber');
        debugPrint('[WEB MOCK] Message content:\n$message');
        
        // Show dialog if context is available
        if (context != null && context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('SMS Simulation (Web)'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('On a real device, this would send:'),
                  const SizedBox(height: 10),
                  Text('To: $phoneNumber', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(message),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // MOBILE IMPLEMENTATION
      // Try direct SMS first
      if (await canSendSMS()) {
        final result = await sendSMS(
          message: message,
          recipients: [phoneNumber],
        );
        if (result != "SMS Sent!") {
          throw Exception('Failed to send SMS: $result');
        }
        return;
      }
      
      // Fallback to SMS URL
      final uri = Uri.parse(
        'sms:$phoneNumber?body=${Uri.encodeComponent(message)}'
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return;
      }
      
      throw Exception('No SMS capability available');
    } catch (e) {
      String errorMessage = 'An unexpected error occurred while sending the SMS.';
      if (e.toString().contains('No SMS capability available')) {
        errorMessage = 'Your device does not support SMS functionality.';
      } else if (e.toString().contains('Failed to send SMS')) {
        errorMessage = 'Unable to send SMS. Please check your network or try again later.';
      }

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}