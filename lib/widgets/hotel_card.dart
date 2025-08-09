import 'package:flutter/material.dart';
import '../language/appLocalizations.dart';

class HotelCard extends StatefulWidget {
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
  final bool isFavorite;
  final Function(bool)? onFavoriteChanged;

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
    this.isFavorite = false,
    this.onFavoriteChanged,
  });

  @override
  State<HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<HotelCard> {

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: widget.onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          child: SizedBox(
            height: widget.cardHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.asset(
                        widget.image,
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
                    if (widget.badge != null)
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
                            widget.badge!,
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
                          widget.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDarkMode ? Colors.white : Colors.black),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 16),
                            Text(widget.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(' (${widget.reviews})', style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey, fontSize: 13)),
                            if (widget.district != null) ...[
                              Text(' • ', style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey, fontSize: 13)),
                              Flexible(
                                child: Text(
                                  widget.district!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey, fontSize: 13),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (widget.discountLabel != null)
                          Container(
                            margin: const EdgeInsets.only(top: 2, bottom: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.discountLabel!,
                              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        Row(
                          children: [
                            if (widget.originalPrice != null && widget.originalPrice! > widget.price)
                              FittedBox(
                                child: Text(
                                  widget.originalPrice!.toString() + 'đ',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            if (widget.originalPrice != null && widget.originalPrice! > widget.price)
                              const SizedBox(width: 6),
                            Flexible(
                              child: Text(
'${AppLocalizations(context).of('from_price')} ${widget.price}đ',
                                style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black, fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.timeLabel != null) ...[
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(widget.timeLabel!, style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
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