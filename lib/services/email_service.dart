import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class EmailService {
  // Sử dụng EmailJS hoặc SendGrid API
  static const String _apiKey = 'YOUR_API_KEY'; // Thay bằng API key thực
  static const String _serviceId = 'YOUR_SERVICE_ID';
  static const String _templateId = 'YOUR_TEMPLATE_ID';
  
  // Tạo reset token
  static String _generateResetToken() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return base64.encode(utf8.encode(random)).substring(0, 16);
  }

  // Gửi email reset password
  static Future<bool> sendResetPasswordEmail(String email, String resetToken) async {
    try {
      // Sử dụng EmailJS
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _apiKey,
          'template_params': {
            'to_email': email,
            'reset_link': 'https://yourapp.com/reset-password?token=$resetToken',
            'reset_token': resetToken,
          },
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Email send failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Email service error: $e');
      return false;
    }
  }

  // Mock function cho development (không cần API key)
  static Future<bool> sendResetPasswordEmailMock(String email) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 2));
    
    // Trong thực tế, bạn sẽ gửi email thật
    // Ở đây chỉ mock thành công
    print('Mock: Reset password email sent to $email');
    return true;
  }

  // Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Validate phone format (Vietnam)
  static bool isValidPhone(String phone) {
    // Format: 0xxxxxxxxx hoặc +84xxxxxxxxx
    final phoneRegex = RegExp(r'^(0|\+84)[0-9]{9}$');
    return phoneRegex.hasMatch(phone);
  }

  // Validate password strength
  static String validatePassword(String password) {
    if (password.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Mật khẩu phải có ít nhất 1 chữ hoa';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Mật khẩu phải có ít nhất 1 số';
    }
    return '';
  }
} 