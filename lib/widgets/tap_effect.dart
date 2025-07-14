import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:myapp/language/appLocalizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();

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
    {"name": "Hoàng Gia Hotel - Đại Mỗ", "rating": 4.9, "reviews": 3913, "location": "Nam Từ Liêm", "price": 168000, "originalPrice": 200000, "rooms": 4, "time": "07:00 - 23:00"},
    {"name": "Lam Anh Hotel - Nạ", "rating": 4.8, "reviews": 357, "location": "Bắc Từ Liêm", "price": 190000, "originalPrice": 230000, "rooms": 2, "time": "12:00 - 21:00"},
  ];

  final List<Map<String, dynamic>> popularHotels = [
    {"name": "Trần Gia 2", "rating": 4.8, "reviews": 2563, "price": 200000, "discount": 25},
    {"name": "Hoa Nam Hotel - Việt", "rating": 5.0, "reviews": 3, "price": 280000},
    {"name": "Nguyễn Anh", "rating": 4.9, "reviews": 3337, "price": 200000},
  ];

  final List<Map<String, dynamic>> newHotels = [
    {"name": "New Apart Hotel", "rating": 5.0, "reviews": 10, "price": 350000, "discount": 10},
    {"name": "Cozy Oasis", "rating": 4.9, "reviews": 5, "price": 200000},
    {"name": "A25 Hotel", "rating": 5.0, "reviews": 1, "price": 245000, "new": true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: AppLocalizations(context).of("explore")),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: AppLocalizations(context).of("trips")),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: AppLocalizations(context).of("profile")),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: _slideImages.length,
                      itemBuilder: (context, index) {
                        return SlideCard(imagePath: _slideImages[index]);
                      },
                    ),
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
                    )
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: AppLocalizations(context).of("where_going"),
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      AppLocalizations(context).of("popular_destination"),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Flash Sale",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text("Xem tất cả"),
                        ),
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
                        return Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 16),
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset('assets/images/hotel_placeholder.jpg', height: 100, fit: BoxFit.cover),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(hotel["name"], style: TextStyle(fontWeight: FontWeight.bold)),
                                      Row(
                                        children: [
                                          Icon(Icons.star, size: 16, color: Colors.amber),
                                          Text("${hotel["rating"]} (${hotel["reviews"]})"),
                                          Text(" \u2022 ${hotel["location"]}", style: TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                      Text("${hotel["time"]} hôm nay"),
                                      Text("${hotel["price"].toStringAsFixed(0)}đ ${hotel["originalPrice"].toStringAsFixed(0)}đ / ${hotel["rooms"]} phòng",
                                          style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)),
                                      Text("-${((1 - hotel["price"] / hotel["originalPrice"]) * 100).round()}%"),
                                      TapEffect(
                                        onClick: () {
                                          // Navigate or handle overnight price (double the price)
                                          final overnightPrice = hotel["price"] * 2;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Overnight price: ${overnightPrice.toStringAsFixed(0)}đ")),
                                          );
                                        },
                                        child: ElevatedButton(
                                          onPressed: null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text("Chọn 4 phòng"),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Lựa chọn phổ biến",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text("Xem tất cả"),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 16),
                      itemCount: popularHotels.length,
                      itemBuilder: (context, index) {
                        final hotel = popularHotels[index];
                        return Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 16),
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset('assets/images/hotel_placeholder.jpg', height: 100, fit: BoxFit.cover),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(hotel["name"], style: TextStyle(fontWeight: FontWeight.bold)),
                                      Row(
                                        children: [
                                          Icon(Icons.star, size: 16, color: Colors.amber),
                                          Text("${hotel["rating"]} (${hotel["reviews"]})"),
                                        ],
                                      ),
                                      Text("${hotel["price"].toStringAsFixed(0)}đ"),
                                      if (hotel["discount"] != null)
                                        Text("Mã giảm ${hotel["discount"]}%", style: TextStyle(color: Colors.orange)),
                                      TapEffect(
                                        onClick: () {
                                          // Handle booking action
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Booked ${hotel["name"]}")),
                                          );
                                        },
                                        child: ElevatedButton(
                                          onPressed: null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.teal,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text("Đặt ngay"),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Khách sạn mới",
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text("Xem tất cả"),
                        ),
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
                        return Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 16),
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset('assets/images/hotel_placeholder.jpg', height: 100, fit: BoxFit.cover),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(hotel["name"], style: TextStyle(fontWeight: FontWeight.bold)),
                                      Row(
                                        children: [
                                          Icon(Icons.star, size: 16, color: Colors.amber),
                                          Text("${hotel["rating"]} (${hotel["reviews"]})"),
                                        ],
                                      ),
                                      Text("${hotel["price"].toStringAsFixed(0)}đ"),
                                      if (hotel["discount"] != null)
                                        Text("Mã giảm ${hotel["discount"]}%", style: TextStyle(color: Colors.orange)),
                                      if (hotel["new"] == true)
                                        Text("Mới mở", style: TextStyle(color: Colors.blue)),
                                      TapEffect(
                                        onClick: () {
                                          // Handle booking action
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Booked ${hotel["name"]}")),
                                          );
                                        },
                                        child: ElevatedButton(
                                          onPressed: null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.teal,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text("Đặt ngay"),
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
                ],
              ),
            )
          ],
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
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          left: 32,
          bottom: 32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cape Town",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Extraordinary five-star\noutdoor activites",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              TapEffect(
                onClick: () {},
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text("View Hotel"),
                ),
              )
            ],
          ),
        )
      ],
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
  const TapEffect(
      {Key? key,
        this.isClickable = true,
        required this.onClick,
        required this.child})
      : super(key: key);

  final bool isClickable;
  final VoidCallback onClick;
  final Widget child;

  @override
  _TapEffectState createState() => _TapEffectState();
}

class _TapEffectState extends State<TapEffect>
    with SingleTickerProviderStateMixin {
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
      //this logic creator like more press experience with some delay
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
          await Future<dynamic>.delayed(const Duration(milliseconds: 280));
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