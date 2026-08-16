import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/computer_product.dart';
import '../services/shop_service.dart';

class DetailScreen extends StatefulWidget {
  final ComputerProduct product;

  const DetailScreen({super.key, required this.product});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final totalPrice = p.price * _quantity;
    final service = context.watch<ShopService>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Elegant Header / Back button
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF08080E),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F0F1E), Color(0xFF08080E)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: p.imagePath.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Image.asset(
                            p.imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, _) => Text(p.emoji, style: const TextStyle(fontSize: 100)),
                          ),
                        )
                      : Text(p.emoji, style: const TextStyle(fontSize: 100)),
                ),
              ),
            ),
          ),
          
          // Specifications
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title / Brand
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF12121F),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: p.colorHex.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          p.brand,
                          style: GoogleFonts.orbitron(
                            color: p.colorHex,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        p.category,
                        style: GoogleFonts.rajdhani(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    p.name,
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Price Tag
                  Row(
                    children: [
                      Text(
                        '฿${p.price.toStringAsFixed(0)}',
                        style: GoogleFonts.orbitron(
                          color: p.colorHex,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (p.hasDiscount) ...[
                        const SizedBox(width: 12),
                        Text(
                          '฿${p.originalPrice!.toStringAsFixed(0)}',
                          style: GoogleFonts.orbitron(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Description
                  Text(
                    'รายละเอียดสินค้า',
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.description,
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Specs / Features list
                  if (p.specs.isNotEmpty) ...[
                    Text(
                      'ข้อมูลทางเทคนิค (Specifications)',
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...p.specs.entries.map((entry) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF12121F),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: GoogleFonts.rajdhani(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            entry.value,
                            style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 24),
                  ],
                  
                  // Quantity adjust row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'จำนวน',
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.grey),
                            onPressed: () {
                              if (_quantity > 1) {
                                setState(() => _quantity--);
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '$_quantity',
                              style: GoogleFonts.orbitron(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_circle_outline_rounded, color: p.colorHex),
                            onPressed: () => setState(() => _quantity++),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 100), // padding for checkout bar
                ],
              ),
            ),
          )
        ],
      ),
      bottomSheet: Container(
        color: const Color(0xFF0C0C14),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ยอดรวมชำระ',
                    style: GoogleFonts.rajdhani(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '฿${totalPrice.toStringAsFixed(0)}',
                    style: GoogleFonts.orbitron(color: p.colorHex, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    service.addToCart(p, quantity: _quantity);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('เพิ่ม ${p.name} ลงตะกร้าแล้ว!',
                            style: GoogleFonts.rajdhani(color: Colors.black, fontWeight: FontWeight.bold)),
                        backgroundColor: p.colorHex,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.colorHex,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'ใส่ตะกร้า',
                    style: GoogleFonts.orbitron(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
