import 'package:flutter/material.dart';
import 'package:myapp/language/appLocalizations.dart';
import 'package:myapp/widgets/common_appbar_view.dart';
import 'package:myapp/widgets/common_textfield_view.dart';
import 'package:myapp/widgets/remove_Foucuse.dart';
import 'package:myapp/widgets/common_button.dart';
import 'package:myapp/utils/validator.dart';
import 'package:myapp/routes/route_names.dart';
import 'package:myapp/db_helper.dart';
import 'package:myapp/services/email_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'facebook_twitter_button_view.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _errorEmail = '';
  TextEditingController _emailController = TextEditingController();
  String _errorPassword = '';
  TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Hàm validate email
  String _validateEmail(String email) {
    if (email.isEmpty) {
      return AppLocalizations(context).of("email_cannot_empty");
    }
    if (!EmailService.isValidEmail(email)) {
      return AppLocalizations(context).of("enter_valid_email");
    }
    return '';
  }

  // Hàm validate password
  String _validatePassword(String password) {
    if (password.isEmpty) {
      return AppLocalizations(context).of("password_cannot_empty");
    }
    if (password.length < 6) {
      return AppLocalizations(context).of("valid_password");
    }
    return '';
  }

  // Hàm validate form
  bool _validateForm() {
    String emailError = _validateEmail(_emailController.text.trim());
    String passwordError = _validatePassword(_passwordController.text);

    setState(() {
      _errorEmail = emailError;
      _errorPassword = passwordError;
    });

    return emailError.isEmpty && passwordError.isEmpty;
  }

  // Hàm xử lý login
  Future<void> _handleLogin() async {
    if (!_validateForm()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Validate user với database
      final isValid = await DBHelper.validateUser(email, password);
      
      if (isValid) {
        // Lấy thông tin user
        final user = await DBHelper.getUserByEmail(email);
        
        if (user != null) {
          // Lưu thông tin user vào shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('current_user_id', user['id']);
          await prefs.setString('user_email', user['email']);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đăng nhập thành công!'),
              backgroundColor: Colors.green,
            ),
          );

          // Chuyển đến trang Home sau khi login thành công
          NavigationServies(context).gotoHomeScreen();
        }
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email hoặc mật khẩu không đúng'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        body: RemoveFocus(
          onClick: (){
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonAppBarView(
                  iconData: Icons.arrow_back_ios_new,
                  titleText: AppLocalizations(context).of("login"),
                  onBackClick: (){
                    Navigator.pop(context);
                  }),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top:32,left: 16,right: 16,bottom: 16),
                        child: FaceBookTwitterButtonView(),
                      ),
                      CommonTextFieldView(
                        controller: _emailController,
                        errorText: _errorEmail,
                        titleText: AppLocalizations(context).of("your_mail"),
                        padding: EdgeInsets.only(
                          left: 24,
                          right: 24,
                        ),
                        hintText: AppLocalizations(context).of("enter_your_email"),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (String txt){
                          // Clear error khi user bắt đầu nhập
                          if (_errorEmail.isNotEmpty) {
                            setState(() {
                              _errorEmail = '';
                            });
                          }
                        },
                      ),
                      CommonTextFieldView(
                        controller: _passwordController,
                        errorText: _errorPassword,
                        titleText: AppLocalizations(context).of("password"),
                        padding: EdgeInsets.only(
                          left: 24,
                          right: 24,
                        ),
                        hintText: AppLocalizations(context).of("enter_password"),
                        onChanged: (String txt){
                          // Clear error khi user bắt đầu nhập
                          if (_errorPassword.isNotEmpty) {
                            setState(() {
                              _errorPassword = '';
                            });
                          }
                        },
                        keyboardType: TextInputType.text,
                        isObsecureText: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8, top: 32), // Khớp padding với IntroductionScreen
                        child: CommonButton(
                          onTap: _isLoading ? null : _handleLogin,
                          buttonText: _isLoading ? "Đang đăng nhập..." : AppLocalizations(context).of("login"),
                          radius: 24, // Khớp góc bo tròn
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 24, right: 24, top: 8),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                            );
                          },
                          child: Text(
                            AppLocalizations(context).of("forgot_your_Password"),
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        )
    );
  }
}