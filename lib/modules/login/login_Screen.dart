import 'package:flutter/material.dart';
import 'package:myapp/language/appLocalizations.dart';
import 'package:myapp/widgets/common_appbar_view.dart';
import 'package:myapp/widgets/common_textfield_view.dart';
import 'package:myapp/widgets/remove_Foucuse.dart';
import 'package:myapp/widgets/common_button.dart'; // Thêm import cho CommonButton
import 'package:myapp/utils/validator.dart';
import 'package:myapp/routes/route_names.dart';

import 'facebook_twitter_button_view.dart';

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

  // Hàm validate email
  String _validateEmail(String email) {
    if (email.isEmpty) {
      return AppLocalizations(context).of("email_cannot_empty");
    }
    if (!Validator.validateEmail(email)) {
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
  void _handleLogin() {
    if (_validateForm()) {
      // Logic login ở đây
      print('Login with email: ${_emailController.text}');
      print('Login with password: ${_passwordController.text}');
      
      // TODO: Thêm logic gọi API login
      // Ví dụ: await authService.login(_emailController.text, _passwordController.text);
      
      // Chuyển đến trang Home sau khi login thành công
      NavigationServies(context).gotoHomeScreen();
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
                          onTap: _handleLogin,
                          buttonText: AppLocalizations(context).of("login"),
                          radius: 24, // Khớp góc bo tròn
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 24, right: 24, top: 8),
                        child: TextButton(
                          onPressed: () {
                            // Add forgot password logic here
                            print('Forgot Password pressed');
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