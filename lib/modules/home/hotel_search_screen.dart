import 'package:flutter/material.dart';
import 'hotel_search_bar.dart';

class HotelSearchScreen extends StatelessWidget {
  const HotelSearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tìm kiếm khách sạn'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: HotelSearchBar(),
        ),
      ),
    );
  }
} 