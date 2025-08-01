import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:myapp/language/appLocalizations.dart';
import 'hotel_list_by_area_screen.dart';
import 'hotel_search_bar.dart';
import 'hotel_search_screen.dart';
import 'booking_screen.dart';
import 'package:myapp/db_helper.dart';
import 'package:myapp/seed_data.dart';
import 'package:myapp/widgets/hotel_card.dart';

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

  int _selectedIndex = 0;
  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home, label: 'Home'),
    _NavItem(icon: Icons.hotel, label: 'Phòng đã đặt'),
    _NavItem(icon: Icons.person, label: 'Tài khoản'),
  ];

  @override
  void initState() {
    super.initState();
    // seedData(); // Đã seed trong DBHelper, không cần gọi nữa
  }

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
                          Navigator.pop(context); // Đóng modal
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HotelListByAreaScreen(
                                city: tempCity,
                                district: tempDistrict,
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
              // 4. Danh sách khách sạn lấy từ SQLite
              SliverToBoxAdapter(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: DBHelper.getHotels(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Lỗi dữ liệu: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData) return Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
                    final hotels = snapshot.data!;
                    final filteredHotels = hotels.where((h) => h['city'] == selectedCity && h['district'] == selectedDistrict).toList();
                    final showHotels = filteredHotels.isNotEmpty ? filteredHotels : hotels;
                    final flashSaleHotels = hotels.where((h) => h['isFlashSale'] == true).toList();
                    final newHotels = hotels.where((h) => h['isNew'] == true).toList();
                    final topRatedHotels = hotels.where((h) => h['isTopRated'] == true).toList();
                    if (showHotels.isEmpty) return Center(child: Text('Không có khách sạn nào trong hệ thống.'));
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Flash Sale (nếu có)
                        if (flashSaleHotels.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Ưu đãi đặc biệt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                TextButton(onPressed: () {}, child: Text('Xem tất cả')),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(left: 16),
                              itemCount: flashSaleHotels.length,
                              itemBuilder: (context, index) {
                                final hotel = flashSaleHotels[index];
                                return HotelCard(
                                  name: hotel['name'] ?? '',
                                  address: hotel['address'] ?? '',
                                  image: hotel['image'] ?? 'assets/images/hotel_1.jpg',
                                  rating: hotel['rating']?.toDouble() ?? 0,
                                  reviews: hotel['reviews'] ?? 0,
                                  price: hotel['price'] ?? 0,
                                  originalPrice: hotel['originalPrice'],
                                  district: hotel['district'],
                                  badge: hotel['isFlashSale'] == true ? 'Nổi bật' : null,
                                  discountLabel: hotel['discountLabel'],
                                  timeLabel: hotel['timeLabel'] ?? '/ 2 giờ',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BookingScreen(hotel: hotel),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                        // Popular Destination (chỉ 1 lần)
                        const SizedBox(height: 16),
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
                        // Thêm nút 'Xem tất cả' và truyền selectedCity/selectedDistrict sang HotelListByAreaScreen
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Khách sạn nổi bật', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => HotelListByAreaScreen(
                                        city: selectedCity,
                                        district: selectedDistrict,
                                      ),
                                    ),
                                  );
                                },
                                child: Text('Xem tất cả'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(left: 16),
                            itemCount: showHotels.length,
                            itemBuilder: (context, index) {
                              final hotel = showHotels[index];
                              return HotelCard(
                                name: hotel['name'] ?? '',
                                address: hotel['address'] ?? '',
                                image: hotel['image'] ?? 'assets/images/hotel_1.jpg',
                                rating: hotel['rating']?.toDouble() ?? 0,
                                reviews: hotel['reviews'] ?? 0,
                                price: hotel['price'] ?? 0,
                                originalPrice: hotel['originalPrice'],
                                district: hotel['district'],
                                badge: hotel['isFlashSale'] == true ? 'Nổi bật' : null,
                                discountLabel: hotel['discountLabel'],
                                timeLabel: hotel['timeLabel'] ?? '/ 2 giờ',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BookingScreen(hotel: hotel),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        // Top được bình chọn
                        if (topRatedHotels.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Top được bình chọn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                TextButton(onPressed: () {}, child: Text('Xem tất cả')),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(left: 16),
                              itemCount: topRatedHotels.length,
                              itemBuilder: (context, index) {
                                final hotel = topRatedHotels[index];
                                return HotelCard(
                                  name: hotel['name'] ?? '',
                                  address: hotel['address'] ?? '',
                                  image: hotel['image'] ?? 'assets/images/hotel_1.jpg',
                                  rating: hotel['rating']?.toDouble() ?? 0,
                                  reviews: hotel['reviews'] ?? 0,
                                  price: hotel['price'] ?? 0,
                                  originalPrice: hotel['originalPrice'],
                                  district: hotel['district'],
                                  badge: null, // No specific badge for top rated
                                  discountLabel: null,
                                  timeLabel: null,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BookingScreen(hotel: hotel),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                        // Khách sạn mới
                        if (newHotels.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Khách sạn mới', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                TextButton(onPressed: () {}, child: Text('Xem tất cả')),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(left: 16),
                              itemCount: newHotels.length,
                              itemBuilder: (context, index) {
                                final hotel = newHotels[index];
                                return HotelCard(
                                  name: hotel['name'] ?? '',
                                  address: hotel['address'] ?? '',
                                  image: hotel['image'] ?? 'assets/images/hotel_1.jpg',
                                  rating: hotel['rating']?.toDouble() ?? 0,
                                  reviews: hotel['reviews'] ?? 0,
                                  price: hotel['price'] ?? 0,
                                  originalPrice: hotel['originalPrice'],
                                  district: hotel['district'],
                                  badge: null, // No specific badge for new hotels
                                  discountLabel: null,
                                  timeLabel: null,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BookingScreen(hotel: hotel),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      extendBody: true,
      bottomNavigationBar: _buildFloatingNavBar(),
    );
  }

  Widget _buildFloatingNavBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(32),
        color: Colors.transparent,
        child: Container(
          height: 76, // tăng chiều cao bar
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final selected = _selectedIndex == index;
              return Flexible(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                    decoration: BoxDecoration(
                      color: selected ? Colors.teal.withOpacity(0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          width: selected ? 32 : 26,
                          height: selected ? 32 : 26,
                          child: Icon(_navItems[index].icon,
                              color: selected ? Colors.teal : Colors.grey,
                              size: selected ? 30 : 24),
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: Duration(milliseconds: 200),
                          style: TextStyle(
                            color: selected ? Colors.teal : Colors.grey,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            fontSize: selected ? 14 : 12,
                          ),
                          child: Text(_navItems[index].label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
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