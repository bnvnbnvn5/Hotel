
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../widgets/common_button.dart';

class FaceBookTwitterButtonView extends StatelessWidget {
  const FaceBookTwitterButtonView({Key? key}) : super(key: key);

  Widget buttonTextUI() {
    return Text(
      "Login",
      style: TextStyle(color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          SizedBox(
            width: 24,
          ),
          Expanded(
            child: CommonButton(
              padding: EdgeInsets.zero,
              backgroundColor: Color(0xFF3C5799), // Facebook blue
              buttonTextWidget: _buttonTextUI(),
            ),
          ),
          SizedBox(
            width: 24,
          ),
          Expanded(
            child: CommonButton(
              padding: EdgeInsets.zero,
              backgroundColor: Color(0xFF1DA1F2), // Twitter blue or same
              buttonTextWidget:_buttonTextUI(isFaceBook: false),
            ),
          ),
          SizedBox(
            width: 24,
          ),
        ],
      ),
    );
  }

  Widget _buttonTextUI({bool isFaceBook = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          isFaceBook ? FontAwesomeIcons.facebookF : FontAwesomeIcons.twitter,
          size: 20,
          color: Colors.white,
        ),
        SizedBox(
          width: 24,
        ),
        Text(
          isFaceBook ? "Facebook" : "Twitter",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.white,
          ),
        )
      ],
    );
  }
}

