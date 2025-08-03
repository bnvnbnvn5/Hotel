import 'package:flutter/material.dart';
import 'package:myapp/language/appLocalizations.dart';
import 'package:myapp/db_helper.dart';
import 'package:myapp/services/email_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_Screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    final local = AppLocalizations(context);
    
    // Validate email
    if (!EmailService.isValidEmail(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email không đúng định dạng")),
      );
      return;
    }

    // Validate phone
    if (!EmailService.isValidPhone(_phoneController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Số điện thoại không đúng định dạng")),
      );
      return;
    }

    // Validate password
    final passwordError = EmailService.validatePassword(_passwordController.text);
    if (passwordError.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(passwordError)),
      );
      return;
    }

    if (_agreedToTerms) {
      setState(() => _isLoading = true);

      try {
        // Kiểm tra email đã tồn tại chưa
        final emailExists = await DBHelper.emailExists(_emailController.text.trim());
        if (emailExists) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Email đã được sử dụng")),
          );
          return;
        }

        // Tạo user mới
        final userId = await DBHelper.insertUser({
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'password': _passwordController.text,
          'name': 'User', // Default name
        });

        setState(() => _isLoading = false);

        if (userId > 0) {
          // Lưu thông tin user vào shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('current_user_id', userId);
          await prefs.setString('user_email', _emailController.text.trim());
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Account created successfully!")),
          );
          
          // Chuyển sang màn đăng nhập sau khi tạo tài khoản thành công
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Có lỗi xảy ra, vui lòng thử lại")),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Có lỗi xảy ra: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please accept the terms")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(local.of('create_account')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(local.of('mail_text')),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: local.of('enter_your_email'),
              ),
            ),
            const SizedBox(height: 16),
            Text(local.of('phone')),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: local.of('phone'),
              ),
            ),
            const SizedBox(height: 16),
            Text(local.of('password')),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: local.of('enter_password'),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _agreedToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreedToTerms = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(local.of('terms_agreed')),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _createAccount,
              child: _isLoading ? CircularProgressIndicator() : Text(local.of('create_account')),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(local.of('already_have_account')),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: Text(local.of('login')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}