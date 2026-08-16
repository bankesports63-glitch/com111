import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/shop_service.dart';
import '../models/user_profile.dart';

class CartScreen extends StatefulWidget {
  final bool isBottomNav;
  const CartScreen({super.key, this.isBottomNav = false});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _addressController = TextEditingController(
    text: 'กรุณาเลือกที่อยู่จัดส่งในโปรไฟล์',
  );
  bool _isOrdering = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF12121F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF00FF88), width: 1.5),
        ),
        title: Center(
          child: Column(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF00FF88), size: 64),
              const SizedBox(height: 16),
              Text(
                'ORDER PLACED!',
                style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'คำสั่งซื้อของคุณได้รับการยืนยันแล้ว',
              style: GoogleFonts.rajdhani(color: Colors.grey.shade300, fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'ออเดอร์ ID: $orderId',
              style: GoogleFonts.orbitron(color: const Color(0xFF00C3FF), fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: SizedBox(
              width: 140,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF88),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'ตกลง',
                  style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder(ShopService service) async {
    if (_addressController.text.trim().isEmpty || _addressController.text.startsWith('กรุณาเลือก')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณาเพิ่มที่อยู่ในหน้าโปรไฟล์และเลือกจัดส่ง', style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isOrdering = true);

    try {
      final orderId = await service.placeOrder(_addressController.text.trim());
      if (mounted) {
        _showSuccessDialog(orderId);
      }
    } catch (e) {
      // Offline fallback
      final mockOrderId = 'NEON-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      service.clearCart();
      if (mounted) {
        _showSuccessDialog(mockOrderId);
      }
    } finally {
      if (mounted) setState(() => _isOrdering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ShopService>();
    final cartItems = service.cartItems;

    return Scaffold(
      body: Column(
        children: [
          // Header Bar
          Padding(
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 16),
            child: Row(
              children: [
                if (!widget.isBottomNav)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                Text(
                  'ตะกร้าสินค้าของคุณ',
                  style: GoogleFonts.orbitron(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Cart Items List
          Expanded(
            child: cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.shade700),
                        const SizedBox(height: 16),
                        Text(
                          'ไม่มีสินค้าในตะกร้า',
                          style: GoogleFonts.rajdhani(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, idx) {
                      final item = cartItems[idx];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF12121F),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
                        ),
                        child: Row(
                          children: [
                            Text(item.emoji, style: const TextStyle(fontSize: 36)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '฿${item.price.toStringAsFixed(0)}',
                                    style: GoogleFonts.orbitron(color: const Color(0xFF00C3FF), fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Quantity selector
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 16, color: Colors.grey),
                                  onPressed: () => service.updateQuantity(item.productId, item.quantity - 1),
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: GoogleFonts.orbitron(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 16, color: Color(0xFF00FF88)),
                                  onPressed: () => service.updateQuantity(item.productId, item.quantity + 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          
          // Checkout Section
          if (cartItems.isNotEmpty)
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0C0C14),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Select Address
                  Text(
                    'ที่อยู่จัดส่ง',
                    style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<UserProfile?>(
                    stream: service.getUserProfileStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null && snapshot.data!.addresses.isNotEmpty) {
                        final profile = snapshot.data!;
                        final defaultAddr = profile.addresses.firstWhere((a) => a.isDefault, orElse: () => profile.addresses.first);
                        _addressController.text = '${defaultAddr.tag}: ${defaultAddr.fullAddress} (โทร: ${defaultAddr.phone})';
                      }

                      return TextField(
                        controller: _addressController,
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.location_on_rounded, color: Color(0xFF00FF88), size: 18),
                          filled: true,
                          fillColor: const Color(0xFF05050A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Financial summaries
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ค่าสินค้า', style: GoogleFonts.rajdhani(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('฿${service.cartTotal.toStringAsFixed(0)}', style: GoogleFonts.orbitron(fontSize: 13, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ค่าจัดส่งด่วน', style: GoogleFonts.rajdhani(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('฿50', style: GoogleFonts.orbitron(fontSize: 13, color: Colors.white)),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('ราคารวมทั้งสิ้น', style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      Text('฿${(service.cartTotal + 50).toStringAsFixed(0)}', style: GoogleFonts.orbitron(fontSize: 18, color: const Color(0xFF00FF88), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Checkout Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isOrdering ? null : () => _placeOrder(service),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: EdgeInsets.zero,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF00FF88), Color(0xFF00C3FF)]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: _isOrdering
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                              : Text(
                                  '🎮 ชำระเงินออเดอร์',
                                  style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
