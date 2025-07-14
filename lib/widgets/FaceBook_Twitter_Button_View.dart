import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FaceBookTwitterButtonView extends StatelessWidget {
  const FaceBookTwitterButtonView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // Thêm logic đăng nhập bằng Facebook
            print("Đăng nhập bằng Facebook");
          },
          icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.white),
          label: const Text(
            "Đăng nhập bằng Facebook",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3b5998),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            // Thêm logic đăng nhập bằng Twitter
            print("Đăng nhập bằng Twitter");
          },
          icon: const FaIcon(FontAwesomeIcons.twitter, color: Colors.white),
          label: const Text(
            "Đăng nhập bằng Twitter",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1DA1F2),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
