import 'package:flutter/material.dart';
import 'package:myapp/db_helper.dart';
import 'package:myapp/services/email_service.dart';
import 'login_Screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String resetToken;
  
  const ResetPasswordScreen({
    Key? key, 
    required this.email, 
    required this.resetToken
  }) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  
  String _newPasswordError = '';
  String _confirmPasswordError = '';

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateNewPassword() {
    final password = _newPasswordController.text;
    final error = EmailService.validatePassword(password);
    setState(() => _newPasswordError = error);
  }

  void _validateConfirmPassword() {
    final password = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;
    if (confirmPassword.isEmpty) {
      setState(() => _confirmPasswordError = 'Xác nhận mật khẩu không được để trống');
    } else if (password != confirmPassword) {
      setState(() => _confirmPasswordError = 'Mật khẩu không khớp');
    } else {
      setState(() => _confirmPasswordError = '');
    }
  }

  bool _validateForm() {
    _validateNewPassword();
    _validateConfirmPassword();
    
    return _newPasswordError.isEmpty && _confirmPasswordError.isEmpty;
  }

  Future<void> _resetPassword() async {
    if (!_validateForm()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Cập nhật mật khẩu mới trong database
      await DBHelper.updatePassword(widget.email, _newPasswordController.text);
      
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đặt lại mật khẩu thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      // Chuyển về màn hình đăng nhập
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Đặt lại mật khẩu',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            
            // Icon và tiêu đề
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.lock_open,
                  size: 40,
                  color: Colors.green,
                ),
              ),
            ),
            SizedBox(height: 24),
            
            Text(
              'Tạo mật khẩu mới',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            
            Text(
              'Nhập mật khẩu mới cho tài khoản ${widget.email}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),

            // Mật khẩu mới
            Text(
              'Mật khẩu mới *',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              decoration: InputDecoration(
                hintText: 'Nhập mật khẩu mới',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _newPasswordError.isNotEmpty ? _newPasswordError : null,
                prefixIcon: Icon(Icons.lock, color: Colors.green),
                suffixIcon: IconButton(
                  icon: Icon(_obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() => _obscureNewPassword = !_obscureNewPassword);
                  },
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
              ),
              onChanged: (value) {
                if (_newPasswordError.isNotEmpty) _validateNewPassword();
              },
            ),
            SizedBox(height: 16),

            // Xác nhận mật khẩu mới
            Text(
              'Xác nhận mật khẩu mới *',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                hintText: 'Nhập lại mật khẩu mới',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: _confirmPasswordError.isNotEmpty ? _confirmPasswordError : null,
                prefixIcon: Icon(Icons.lock, color: Colors.green),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
              ),
              onChanged: (value) {
                if (_confirmPasswordError.isNotEmpty) _validateConfirmPassword();
              },
            ),
            SizedBox(height: 24),

            // Thông tin về mật khẩu
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Yêu cầu mật khẩu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Ít nhất 6 ký tự\n'
                    '• Có ít nhất 1 chữ hoa\n'
                    '• Có ít nhất 1 số',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Nút đặt lại mật khẩu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Đang cập nhật...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Đặt lại mật khẩu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 