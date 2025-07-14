import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:myapp/language/appLocalizations.dart';
import 'hotel_list_by_area_screen.dart';
import 'hotel_search_bar.dart';
import 'hotel_search_screen.dart';

// Thêm custom ScrollBehavior để tắt overscroll glow
class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

final Map<String, List<String>> cityDistricts = {
  "Hà Nội": ["Ba Đình", "Đống Đa"],
  "Hồ Chí Minh": ["Quận 1", "Quận 3"],
  "Đà Nẵng": ["Hải Châu", "Sơn Trà"],
  "Cần Thơ": ["Ninh Kiều", "Bình Thủy"],
  "Huế": ["Phú Hội", "Thuận Thành"],
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  bool _isOvernight = false; // State to toggle between hourly and overnight
  bool _isLoading = false;   // State for loading effect
  String selectedCity = "Hà Nội";
  String selectedDistrict = "Ba Đình";

  final List<String> _slideImages = [
    'assets/images/Sapa.jpg',
    'assets/images/DaLatt.jpg',
    'assets/images/explore_2.jpg',
  ];

  final List<Map<String, String>> destinations = [
    {"city": "Hà Nội", "image": "assets/images/city_6.jpg"},
    {"city": "Hồ Chí Minh", "image": "assets/images/city_5.jpg"},
    {"city": "Huế", "image": "assets/images/city_4.jpg"},
  ];

  final List<Map<String, dynamic>> flashSaleHotels = [
    {
      "name": "Honeymoon Hotel 2",
      "city": "Hà Nội",
      "district": "Ba Đình",
      "rating": 4.7,
      "reviews": 392,
      "location": "Ba Đình",
      "price": 449999,
      "originalPrice": 450000,
      "rooms": 2,
      "time": "23:00 12/07 - 12:00 13/07",
      "image": "assets/images/hotel_1.jpg"
    },
    {
      "name": "Le Grand Hanoi Hotel",
      "city": "Hà Nội",
      "district": "Đống Đa",
      "rating": 4.6,
      "reviews": 149,
      "location": "Đống Đa",
      "price": 399000,
      "originalPrice": 600000,
      "rooms": 4,
      "time": "23:00 12/07 - 10:00 13/07",
      "image": "assets/images/hotel_2.png"
    },
  ];

  final List<Map<String, dynamic>> popularHotels = [
    {
      "name": "Melon Hotel & Lemon Spa",
      "city": "Hồ Chí Minh",
      "district": "Quận 1",
      "rating": 4.9,
      "reviews": 27,
      "location": "Quận 1",
      "price": 200000,
      "discount": 20,
      "image": "assets/images/hotel_3.png"
    },
    {
      "name": "Ocd Love Hotel",
      "city": "Hồ Chí Minh",
      "district": "Quận 3",
      "rating": 4.7,
      "reviews": 1278,
      "location": "Quận 3",
      "price": 245000,
      "new": true,
      "image": "assets/images/hotel_4.png"
    },
  ];

  final List<Map<String, dynamic>> newHotels = [
    {
      "name": "Trần Gia 2",
      "city": "Đà Nẵng",
      "district": "Hải Châu",
      "rating": 4.8,
      "reviews": 2563,
      "location": "Hải Châu",
      "price": 200000,
      "discount": 25,
      "image": "assets/images/hotel_5.png"
    },
    {
      "name": "Hoa Nam Hotel",
      "city": "Đà Nẵng",
      "district": "Sơn Trà",
      "rating": 5.0,
      "reviews": 3,
      "location": "Sơn Trà",
      "price": 280000,
      "image": "assets/images/hotel_2.png"
    },
    {
      "name": "Nguyễn Anh",
      "city": "Cần Thơ",
      "district": "Ninh Kiều",
      "rating": 4.9,
      "reviews": 3337,
      "location": "Ninh Kiều",
      "price": 200000,
      "image": "assets/images/hotel_4.png"
    },
  ];

  void _toggleBookingType(bool isOvernight) {
    setState(() {
      _isLoading = true;
      _isOvernight = isOvernight;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _showAreaPicker() async {
    String tempCity = selectedCity;
    String tempDistrict = selectedDistrict;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final districts = cityDistricts[tempCity] ?? [];
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Vui lòng chọn khu vực", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedCity = tempCity;
                            selectedDistrict = tempDistrict;
                          });
                          Navigator.pop(context);
                          // Chuyển sang trang danh sách khách sạn
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HotelListByAreaScreen(
                                city: selectedCity,
                                district: selectedDistrict,
                                allHotels: [...flashSaleHotels, ...popularHotels, ...newHotels],
                              ),
                            ),
                          );
                        },
                        child: Text("Xác nhận", style: TextStyle(color: Colors.teal)),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: Row(
                      children: [
                        // Cột tỉnh/thành
                        Expanded(
                          flex: 1,
                          child: ListView(
                            children: cityDistricts.keys.map((city) {
                              final isSelected = city == tempCity;
                              return ListTile(
                                title: Text(city, style: TextStyle(color: isSelected ? Colors.orange : Colors.black)),
                                selected: isSelected,
                                onTap: () {
                                  setModalState(() {
                                    tempCity = city;
                                    tempDistrict = cityDistricts[city]![0];
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        // Cột quận/huyện
                        Expanded(
                          flex: 2,
                          child: ListView(
                            children: districts.map((district) {
                              final isSelected = district == tempDistrict;
                              return ListTile(
                                title: Text(district, style: TextStyle(color: isSelected ? Colors.orange : Colors.black)),
                                selected: isSelected,
                                onTap: () {
                                  setModalState(() {
                                    tempDistrict = district;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: NoGlowScrollBehavior(),
          child: CustomScrollView(
            slivers: [
              // 1. Trên cùng: chọn khu vực
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: GestureDetector(
                    onTap: _showAreaPicker,
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          "${selectedCity}, ${selectedDistrict}",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                        ),
                        Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
              // 2. Banner/slider ảnh (SliverAppBar)
              SliverAppBar(
                expandedHeight: 220.0,
                pinned: true,
                backgroundColor: Colors.white,
                stretch: true,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                    StretchMode.fadeTitle,
                  ],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Lớp nền trắng phủ kín
                      Container(color: Colors.white),
                      // Slide ảnh
                      PageView.builder(
                        controller: _pageController,
                        itemCount: _slideImages.length,
                        itemBuilder: (context, index) {
                          return SlideCard(imagePath: _slideImages[index]);
                        },
                      ),
                      // Indicator
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SmoothPageIndicator(
                            controller: _pageController,
                            count: _slideImages.length,
                            effect: WormEffect(
                              activeDotColor: Colors.teal,
                              dotHeight: 10,
                              dotWidth: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 3. Thanh tìm kiếm duy nhất dưới banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => HotelSearchScreen()),
                      );
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: AppLocalizations(context).of("where_are_you_going"),
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Xóa thanh tìm kiếm thứ hai ở đây
                    const SizedBox(height: 24),
                    // Flash Sale Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.flash_on, color: Colors.orange, size: 20),
                              SizedBox(width: 4),
                              Text("Flash Sale", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text("Xem tất cả", style: TextStyle(color: Colors.teal)),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _toggleBookingType(false),
                            child: Column(
                              children: [
                                Text("Theo giờ", style: TextStyle(color: !_isOvernight ? Colors.orange : Colors.black, fontWeight: FontWeight.bold)),
                                if (!_isOvernight)
                                  Container(height: 2, width: 40, color: Colors.orange, margin: EdgeInsets.only(top: 2)),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => _toggleBookingType(true),
                            child: Column(
                              children: [
                                Text("Qua đêm", style: TextStyle(color: _isOvernight ? Colors.orange : Colors.black, fontWeight: FontWeight.bold)),
                                if (_isOvernight)
                                  Container(height: 2, width: 40, color: Colors.orange, margin: EdgeInsets.only(top: 2)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isLoading
                        ? Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                        : SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 16),
                        itemCount: flashSaleHotels.length,
                        itemBuilder: (context, index) {
                          final hotel = flashSaleHotels[index];
                          final price = (hotel["price"] ?? 0) as int;
                          final originalPrice = (hotel["originalPrice"] ?? price) as int;
                          final rooms = hotel["rooms"] ?? 1;
                          final time = hotel["time"] ?? "";
                          final name = hotel["name"] ?? "";
                          final rating = hotel["rating"] ?? "";
                          final reviews = hotel["reviews"] ?? "";
                          final location = hotel["location"] ?? "";
                          final image = hotel["image"] ?? "assets/images/hotel_1.jpg";
                          final displayPrice = _isOvernight ? price * 2 : price;
                          final displayOriginalPrice = _isOvernight ? originalPrice * 2 : originalPrice;
                          final discountPercent = displayOriginalPrice > 0
                              ? ((1 - displayPrice / displayOriginalPrice) * 100).round()
                              : 0;
                          return Container(
                            width: 180,
                            margin: const EdgeInsets.only(right: 16),
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Image.asset(image, height: 90, width: double.infinity, fit: BoxFit.cover),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold)),
                                        Row(
                                          children: [
                                            Icon(Icons.star, size: 14, color: Colors.amber),
                                            Text("$rating ($reviews)", style: TextStyle(fontSize: 12)),
                                            Expanded(child: Text(" • $location", style: TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                          ],
                                        ),
                                        Text(time, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12)),
                                        Row(
                                          children: [
                                            Text(
                                              "${displayPrice.toString()}đ",
                                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              "${displayOriginalPrice.toString()}đ",
                                              style: TextStyle(
                                                decoration: TextDecoration.lineThrough,
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            if (discountPercent > 0)
                                              Text("-$discountPercent%", style: TextStyle(color: Colors.red, fontSize: 12)),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        TapEffect(
                                          onClick: () {},
                                          child: Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.orange,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text("Đặt ngay", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Popular Destinations
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        AppLocalizations(context).of("popular_destination"),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 16),
                        itemCount: destinations.length,
                        itemBuilder: (context, index) {
                          final item = destinations[index];
                          return DestinationCard(
                            city: item["city"]!,
                            imagePath: item["image"]!,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Popular Hotels
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Lựa chọn phổ biến", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () {},
                            child: Text(AppLocalizations(context).of("view_all")),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 16),
                        itemCount: popularHotels.length,
                        itemBuilder: (context, index) {
                          final hotel = popularHotels[index];
                          final price = (hotel["price"] ?? 0) as int;
                          final name = hotel["name"] ?? "";
                          final rating = hotel["rating"] ?? "";
                          final reviews = hotel["reviews"] ?? "";
                          final location = hotel["location"] ?? "";
                          final image = hotel["image"] ?? "assets/images/hotel_1.jpg";
                          final discount = hotel["discount"] ?? 0;
                          final isNew = hotel["new"] == true;
                          return Container(
                            width: 180,
                            margin: const EdgeInsets.only(right: 16),
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Image.asset(image, height: 90, width: double.infinity, fit: BoxFit.cover),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold)),
                                        Row(
                                          children: [
                                            Icon(Icons.star, size: 14, color: Colors.amber),
                                            Text("$rating ($reviews)", style: TextStyle(fontSize: 12)),
                                            Expanded(child: Text(" • $location", style: TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                          ],
                                        ),
                                        Text("${price.toString()}đ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                                        if (discount != 0)
                                          Text("Mã giảm $discount%", style: TextStyle(color: Colors.orange, fontSize: 12)),
                                        if (isNew)
                                          Text("Mới mở", style: TextStyle(color: Colors.blue, fontSize: 12)),
                                        SizedBox(height: 4),
                                        TapEffect(
                                          onClick: () {},
                                          child: Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.orange,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text("Đặt ngay", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // New Hotels
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Khách sạn mới", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () {},
                            child: Text(AppLocalizations(context).of("view_all")),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 16),
                        itemCount: newHotels.length,
                        itemBuilder: (context, index) {
                          final hotel = newHotels[index];
                          final price = (hotel["price"] ?? 0) as int;
                          final name = hotel["name"] ?? "";
                          final rating = hotel["rating"] ?? "";
                          final reviews = hotel["reviews"] ?? "";
                          final location = hotel["location"] ?? "";
                          final image = hotel["image"] ?? "assets/images/hotel_1.jpg";
                          final discount = hotel["discount"] ?? 0;
                          return Container(
                            width: 180,
                            margin: const EdgeInsets.only(right: 16),
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Image.asset(image, height: 90, width: double.infinity, fit: BoxFit.cover),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold)),
                                        Row(
                                          children: [
                                            Icon(Icons.star, size: 14, color: Colors.amber),
                                            Text("$rating ($reviews)", style: TextStyle(fontSize: 12)),
                                            Expanded(child: Text(" • $location", style: TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                          ],
                                        ),
                                        Text("${price.toString()}đ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                                        if (discount != 0)
                                          Text("Mã giảm $discount%", style: TextStyle(color: Colors.orange, fontSize: 12)),
                                        SizedBox(height: 4),
                                        TapEffect(
                                          onClick: () {},
                                          child: Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.orange,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text("Đặt ngay", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SlideCard extends StatelessWidget {
  final String imagePath;
  const SlideCard({required this.imagePath});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class DestinationCard extends StatelessWidget {
  final String city;
  final String imagePath;
  const DestinationCard({required this.city, required this.imagePath});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(8),
      child: Text(
        city,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
    );
  }
}

class TapEffect extends StatefulWidget {
  const TapEffect({Key? key, this.isClickable = true, required this.onClick, required this.child}) : super(key: key);
  final bool isClickable;
  final VoidCallback onClick;
  final Widget child;
  @override
  _TapEffectState createState() => _TapEffectState();
}

class _TapEffectState extends State<TapEffect> with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  DateTime tapTime = DateTime.now();
  bool isProgress = false;
  @override
  void initState() {
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    animationController!.animateTo(1.0,
        duration: const Duration(milliseconds: 0), curve: Curves.fastOutSlowIn);
    super.initState();
  }
  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }
  Future<void> onTapCancel() async {
    if (widget.isClickable) {
      await _onDelayed();
      animationController!.animateTo(1.0,
          duration: const Duration(milliseconds: 240),
          curve: Curves.fastOutSlowIn);
    }
    isProgress = false;
  }
  Future<void> _onDelayed() async {
    if (widget.isClickable) {
      final int tapDuration = DateTime.now().millisecondsSinceEpoch -
          tapTime.millisecondsSinceEpoch;
      if (tapDuration < 120) {
        await Future<dynamic>.delayed(
            Duration(milliseconds: 120 - tapDuration));
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (widget.isClickable) {
          await Future<dynamic>.delayed(const Duration(milliseconds: 180));
          try {
            if (!isProgress) {
              widget.onClick();
              isProgress = true;
            }
          } catch (_) {}
        }
      },
      onTapDown: (TapDownDetails details) {
        if (widget.isClickable) {
          tapTime = DateTime.now();
          animationController!.animateTo(0.9,
              duration: const Duration(microseconds: 120),
              curve: Curves.fastOutSlowIn);
        }
        isProgress = true;
      },
      onTapUp: (TapUpDetails details) {
        onTapCancel();
      },
      onTapCancel: () {
        onTapCancel();
      },
      child: AnimatedBuilder(
        animation: animationController!,
        builder: (BuildContext context, Widget? child) {
          return Transform.scale(
            scale: animationController!.value,
            origin: const Offset(0.0, 0.0),
            child: widget.child,
          );
        },
      ),
    );
  }
}