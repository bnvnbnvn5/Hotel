import 'package:flutter/material.dart';

class HotelCard extends StatelessWidget {
  final String name;
  final String address;
  final String image;
  final double rating;
  final int reviews;
  final int price;
  final int? originalPrice;
  final String? district;
  final String? badge;
  final String? discountLabel;
  final String? timeLabel;
  final VoidCallback? onTap;
  final double cardHeight;

  const HotelCard({
    super.key,
    required this.name,
    required this.address,
    required this.image,
    required this.rating,
    required this.reviews,
    required this.price,
    this.originalPrice,
    this.district,
    this.badge,
    this.discountLabel,
    this.timeLabel,
    this.onTap,
    this.cardHeight = 210,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: SizedBox(
            height: cardHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.asset(
                        image,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 100,
                          color: Colors.grey[300],
                          child: const Center(child: Icon(Icons.broken_image)),
                        ),
                      ),
                    ),
                    if (badge != null)
                      Positioned(
                        left: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 16),
                            Text(rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(' ($reviews)', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            if (district != null) ...[
                              const Text(' • ', style: TextStyle(color: Colors.grey, fontSize: 13)),
                              Flexible(
                                child: Text(
                                  district!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (discountLabel != null)
                          Container(
                            margin: const EdgeInsets.only(top: 2, bottom: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              discountLabel!,
                              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        Row(
                          children: [
                            if (originalPrice != null && originalPrice! > price)
                              FittedBox(
                                child: Text(
                                  originalPrice!.toString() + 'đ',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            if (originalPrice != null && originalPrice! > price)
                              const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Chỉ từ ${price}đ',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (timeLabel != null) ...[
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(timeLabel!, style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 