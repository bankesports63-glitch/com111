import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/shop_service.dart';
import '../models/user_profile.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _addNewAddress(UserProfile profile) {
    String tag = 'บ้าน';
    String fullAddress = '';
    String phone = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF12121F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF00FF88), width: 1.5),
          ),
          title: Text('เพิ่มที่อยู่ใหม่', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'ป้ายกำกับ (เช่น บ้าน, ที่ทำงาน)',
                  labelStyle: GoogleFonts.rajdhani(color: Colors.grey),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FF88))),
                ),
                onChanged: (val) => tag = val,
              ),
              const SizedBox(height: 12),
              TextField(
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'ที่อยู่จัดส่ง',
                  labelStyle: GoogleFonts.rajdhani(color: Colors.grey),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FF88))),
                ),
                onChanged: (val) => fullAddress = val,
              ),
              const SizedBox(height: 12),
              TextField(
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'เบอร์โทรศัพท์',
                  labelStyle: GoogleFonts.rajdhani(color: Colors.grey),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FF88))),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (val) => phone = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ยกเลิก', style: GoogleFonts.rajdhani(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                if (fullAddress.isNotEmpty && phone.isNotEmpty) {
                  final newAddress = UserAddress(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    tag: tag.isEmpty ? 'ที่อยู่' : tag,
                    fullAddress: fullAddress,
                    phone: phone,
                    isDefault: profile.addresses.isEmpty,
                  );
                  profile.addresses.add(newAddress);
                  context.read<ShopService>().saveUserProfile(profile);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF88),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('บันทึก', style: GoogleFonts.orbitron(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ShopService>();

    return Scaffold(
      body: StreamBuilder<UserProfile?>(
        stream: service.getUserProfileStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = snapshot.data;
          final user = service.currentUser;

          if (user == null || profile == null) {
            return Center(
              child: Text('กรุณาเข้าสู่ระบบ', style: GoogleFonts.rajdhani(color: Colors.white)),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220.0,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF08080E),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00C3FF), Color(0xFF08080E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          child: const Icon(Icons.person_rounded, size: 48, color: Color(0xFF00FF88)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          profile.email,
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                    onPressed: () async {
                      await service.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
                      }
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ที่อยู่คลังจัดส่งสินค้า',
                            style: GoogleFonts.rajdhani(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _addNewAddress(profile),
                            icon: const Icon(Icons.add_location_alt_rounded, size: 18, color: Color(0xFF00FF88)),
                            label: Text(
                              'เพิ่มที่อยู่',
                              style: GoogleFonts.rajdhani(color: const Color(0xFF00FF88), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (profile.addresses.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                Icon(Icons.location_off_rounded, size: 48, color: Colors.grey.shade700),
                                const SizedBox(height: 12),
                                Text('ยังไม่มีที่อยู่จัดส่ง', style: GoogleFonts.rajdhani(color: Colors.grey, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        )
                      else
                        ...profile.addresses.map((addr) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF12121F),
                            borderRadius: BorderRadius.circular(20),
                            border: addr.isDefault ? Border.all(color: const Color(0xFF00FF88), width: 1.5) : null,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF08080E),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.location_on_rounded, color: Color(0xFF00FF88)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          addr.tag,
                                          style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                                        ),
                                        if (addr.isDefault) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: const Color(0xFF00FF88), borderRadius: BorderRadius.circular(4)),
                                            child: Text('ค่าเริ่มต้น', style: GoogleFonts.orbitron(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(addr.fullAddress, style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Text('โทร: ${addr.phone}', style: GoogleFonts.orbitron(color: Colors.grey, fontSize: 11)),
                                  ],
                                ),
                              ),
                              if (!addr.isDefault)
                                IconButton(
                                  icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.grey),
                                  tooltip: 'ตั้งเป็นค่าเริ่มต้น',
                                  onPressed: () {
                                    for (var a in profile.addresses) {
                                      a.isDefault = false;
                                    }
                                    addr.isDefault = true;
                                    context.read<ShopService>().saveUserProfile(profile);
                                  },
                                ),
                            ],
                          ),
                        )),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await service.seedProductsToFirestore();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('อัปเดตสินค้าทั้งหมด 12 ชิ้นลง Firebase Firestore เรียบร้อย!',
                                      style: GoogleFonts.rajdhani(color: Colors.black, fontWeight: FontWeight.bold)),
                                  backgroundColor: const Color(0xFF00FF88),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.cloud_upload_rounded, color: Colors.black),
                          label: Text(
                            'อัปเดตราคาสินค้าลง Firebase',
                            style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C3FF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
