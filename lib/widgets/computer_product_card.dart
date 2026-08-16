import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/computer_product.dart';

class ComputerProductCard extends StatefulWidget {
  final ComputerProduct product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const ComputerProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  State<ComputerProductCard> createState() => _ComputerProductCardState();
}

class _ComputerProductCardState extends State<ComputerProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0.0, _isHovered ? -6.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            color: const Color(0xFF12121F),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isHovered ? p.colorHex : Colors.white.withValues(alpha: 0.06),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? p.colorHex.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.4),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Showcase Image/Emoji Area
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF09090F),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                  ),
                  child: Stack(
                    children: [
                      // Product image or emoji fallback
                      if (p.imagePath.isNotEmpty)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                            child: Image.asset(
                              p.imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, _) => Center(
                                child: Text(p.emoji, style: const TextStyle(fontSize: 52)),
                              ),
                            ),
                          ),
                        )
                      else
                        Center(
                          child: Text(p.emoji, style: const TextStyle(fontSize: 52)),
                        ),
                      // Size/Brand badge
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            p.brand,
                            style: GoogleFonts.rajdhani(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: p.colorHex,
                            ),
                          ),
                        ),
                      ),
                      // Discount badge
                      if (p.hasDiscount)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF0055),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '-${p.discountPercent}%',
                              style: GoogleFonts.orbitron(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Product Info Area
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.category,
                      style: GoogleFonts.rajdhani(
                        color: Colors.grey.shade50,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.name,
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Price & Add to Cart
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (p.hasDiscount)
                              Text(
                                '฿${p.originalPrice!.toStringAsFixed(0)}',
                                style: GoogleFonts.rajdhani(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            Text(
                              '฿${p.price.toStringAsFixed(0)}',
                              style: GoogleFonts.orbitron(
                                color: p.colorHex,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Add to cart FAB
                        GestureDetector(
                          onTap: widget.onAddToCart,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [p.colorHex, p.colorHex.withValues(alpha: 0.7)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: p.colorHex.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
