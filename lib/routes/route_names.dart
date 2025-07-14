import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/modules/login/login_Screen.dart';
import 'package:myapp/modules/home/home_screen.dart';
import 'package:myapp/routes/routes.dart';

class NavigationServies {
  final BuildContext context;

  NavigationServies(this.context);

  Future<dynamic> _pushMaterialPageRoute(Widget widget,
      {bool fullscreenDialog = false}) async {
    return await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => widget,fullscreenDialog: fullscreenDialog
        )
    );
  }
  void goToSplashScreen(){
    Navigator.pushNamedAndRemoveUntil(context,RoutesName.Splash,(Route<dynamic> route) => false);
  }
  void gotoIntroductionScreen() {
    Navigator.pushNamedAndRemoveUntil(context, RoutesName.IntroductionScreen,
            (Route<dynamic> route) => false);
  }
  Future<dynamic> gotoLoginScreen() async {
    return await _pushMaterialPageRoute(LoginScreen());
  }
  
  void gotoHomeScreen() {
    Navigator.pushNamedAndRemoveUntil(context, RoutesName.Home,
        (Route<dynamic> route) => false);
  }
}