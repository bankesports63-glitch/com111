import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/computer_product.dart';
import '../models/cart_item.dart';
import '../models/order_model.dart';
import '../models/user_profile.dart';

class ShopService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  ShopService() {
    _initProductsStream();
  }

  // ========== CART ==========
  final List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  int get cartCount => _cartItems.fold(0, (acc, i) => acc + i.quantity);
  double get cartTotal => _cartItems.fold(0.0, (acc, i) => acc + i.totalPrice);

  void addToCart(ComputerProduct product, {int quantity = 1}) {
    final existing = _cartItems.where((i) => i.productId == product.id).toList();
    if (existing.isNotEmpty) {
      existing.first.quantity += quantity;
    } else {
      _cartItems.add(CartItem(
        productId: product.id,
        name: product.name,
        price: product.price,
        emoji: product.emoji,
        quantity: quantity,
      ));
    }
    notifyListeners();
  }

  void updateQuantity(String productId, int qty) {
    final item = _cartItems.where((i) => i.productId == productId).toList();
    if (item.isNotEmpty) {
      if (qty <= 0) {
        _cartItems.removeWhere((i) => i.productId == productId);
      } else {
        item.first.quantity = qty;
      }
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((i) => i.productId == productId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // ========== AUTH ==========
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    notifyListeners();
  }

  Future<void> register(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
    notifyListeners();
  }

  Future<void> signInAnonymously() async {
    await _auth.signInAnonymously();
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    clearCart();
    notifyListeners();
  }

  // ========== USER PROFILE ==========
  Stream<UserProfile?> getUserProfileStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _db.collection('computer_users').doc(user.uid).snapshots().map((doc) {
      if (!doc.exists) {
        return UserProfile(uid: user.uid, email: user.email ?? 'gamer@neontech.com');
      }
      return UserProfile.fromFirestore(doc);
    });
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('computer_users').doc(user.uid).set(profile.toFirestore(), SetOptions(merge: true));
  }

  // ========== PRODUCTS (FIREBASE SYNCED) ==========
  List<ComputerProduct> _firestoreProducts = [];

  void _initProductsStream() {
    _db.collection('computer_products').snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        _firestoreProducts = snapshot.docs.map((doc) => ComputerProduct.fromFirestore(doc)).toList();
        notifyListeners();
      } else {
        // Seeding initial products to Firebase if collection is empty
        seedProductsToFirestore();
      }
    }, onError: (e) {
      debugPrint('Firestore products error: $e');
    });
  }

  Future<void> seedProductsToFirestore() async {
    try {
      final batch = _db.batch();
      for (var product in _demoProducts) {
        final docRef = _db.collection('computer_products').doc(product.id);
        batch.set(docRef, product.toFirestore(), SetOptions(merge: true));
      }
      await batch.commit();
      debugPrint('Products uploaded to Firebase Firestore successfully!');
    } catch (e) {
      debugPrint('Error uploading products to Firebase: $e');
    }
  }

  static final List<ComputerProduct> _demoProducts = [
    ComputerProduct(
      id: 'cpu_1',
      name: 'AMD Ryzen 9 9950X',
      description: 'ซีพียูระดับ High-End สำหรับ Gaming และ Content Creation ประสิทธิภาพสูงสุด 16 Core 32 Thread',
      price: 22900,
      originalPrice: 25500,
      category: 'CPU',
      brand: 'AMD',
      emoji: '🖥️',
      imagePath: 'assets/images/cpu_amd.png',
      colorHex: const Color(0xFF00FF88),
      specs: {'Cores': '16C / 32T', 'Clock': '4.3GHz - 5.7GHz', 'Socket': 'AM5', 'TDP': '170W'},
      isFeatured: true,
    ),
    ComputerProduct(
      id: 'cpu_2',
      name: 'Intel Core i9-14900K',
      description: 'ซีพียูแฝด P-Core + E-Core ที่ทรงพลัง เหมาะสำหรับ Gaming และ Streaming ความเร็วสูงสุด 6.0GHz',
      price: 16900,
      originalPrice: 19990,
      category: 'CPU',
      brand: 'Intel',
      emoji: '💻',
      imagePath: 'assets/images/cpu_intel.png',
      colorHex: const Color(0xFF00C3FF),
      specs: {'Cores': '24C (8P+16E) / 32T', 'Clock': '3.2GHz - 6.0GHz', 'Socket': 'LGA1700', 'TDP': '125W'},
    ),
    ComputerProduct(
      id: 'gpu_1',
      name: 'NVIDIA GeForce RTX 5080',
      description: 'การ์ดจอ GeForce RTX 5080 สำหรับ 4K Gaming และ AI Rendering DLSS 4 Multi-Frame Generation',
      price: 45900,
      originalPrice: 49900,
      category: 'GPU',
      brand: 'NVIDIA',
      emoji: '🎮',
      imagePath: 'assets/images/gpu_rtx5080.png',
      colorHex: const Color(0xFF76B900),
      specs: {'VRAM': '16GB GDDR7', 'CUDA Cores': '10752', 'TDP': '320W', 'Connector': 'PCIe 5.0 x16'},
      isFeatured: true,
    ),
    ComputerProduct(
      id: 'gpu_2',
      name: 'AMD Radeon RX 9070 XT',
      description: 'การ์ดจอ AMD RDNA 4 ระดับ Mid-High สำหรับ 1440p Gaming ราคาคุ้มค่า FSR 4 Support',
      price: 19900,
      originalPrice: 22500,
      category: 'GPU',
      brand: 'AMD',
      emoji: '🕹️',
      imagePath: 'assets/images/gpu_rx9070.png',
      colorHex: const Color(0xFFED1C24),
      specs: {'VRAM': '16GB GDDR6', 'Compute Units': '64', 'TDP': '304W', 'Connector': 'PCIe 5.0 x16'},
    ),
    ComputerProduct(
      id: 'ram_1',
      name: 'Corsair Vengeance DDR5 32GB',
      description: 'RAM DDR5 ความเร็วสูง 6400MHz RGB พร้อม XMP 3.0 Profile รองรับ Intel & AMD',
      price: 3990,
      originalPrice: 4990,
      category: 'RAM',
      brand: 'Corsair',
      emoji: '🔧',
      imagePath: 'assets/images/ram_corsair.png',
      colorHex: const Color(0xFFFF6B35),
      specs: {'Capacity': '32GB (2x16GB)', 'Speed': 'DDR5-6400', 'Latency': 'CL32', 'RGB': 'Yes'},
    ),
    ComputerProduct(
      id: 'ram_2',
      name: 'G.Skill Trident Z5 64GB',
      description: 'RAM DDR5 ความจุสูง 64GB สำหรับ Workstation และ Content Creator DDR5-6000 CL30',
      price: 8490,
      originalPrice: 9990,
      category: 'RAM',
      brand: 'G.Skill',
      emoji: '💾',
      imagePath: 'assets/images/ram_gskill.png',
      colorHex: const Color(0xFF9B59B6),
      specs: {'Capacity': '64GB (2x32GB)', 'Speed': 'DDR5-6000', 'Latency': 'CL30', 'RGB': 'Yes'},
    ),
    ComputerProduct(
      id: 'ssd_1',
      name: 'Samsung 990 Pro 2TB',
      description: 'SSD NVMe PCIe 4.0 ความเร็วอ่าน 7450MB/s เขียน 6900MB/s เหมาะสำหรับ Gaming & Content Creator',
      price: 3290,
      originalPrice: 3990,
      category: 'SSD',
      brand: 'Samsung',
      emoji: '💿',
      imagePath: 'assets/images/ssd_samsung.png',
      colorHex: const Color(0xFF1A73E8),
      specs: {'Capacity': '2TB', 'Interface': 'NVMe PCIe 4.0', 'Read': '7450 MB/s', 'Write': '6900 MB/s'},
      isFeatured: true,
    ),
    ComputerProduct(
      id: 'ssd_2',
      name: 'WD Black SN850X 1TB',
      description: 'SSD Gaming โดยเฉพาะ รองรับ PS5 Expansion ความเร็วอ่าน 7300MB/s Game Mode 2.0',
      price: 2190,
      originalPrice: 2690,
      category: 'SSD',
      brand: 'Western Digital',
      emoji: '🗃️',
      imagePath: 'assets/images/ssd_wd.png',
      colorHex: const Color(0xFF555555),
      specs: {'Capacity': '1TB', 'Interface': 'NVMe PCIe 4.0', 'Read': '7300 MB/s', 'Write': '6600 MB/s'},
    ),
    ComputerProduct(
      id: 'monitor_1',
      name: 'ASUS ROG Swift 4K 240Hz',
      description: 'จอ Gaming 4K 240Hz OLED เบลอน้อยสุด Response Time 0.03ms สีสดใส รองรับ HDR1000',
      price: 34900,
      originalPrice: 39900,
      category: 'Monitor',
      brand: 'ASUS ROG',
      emoji: '🖥️',
      imagePath: 'assets/images/monitor_asus.png',
      colorHex: const Color(0xFFFF0040),
      specs: {'Size': '27 inch', 'Panel': 'OLED', 'Resolution': '4K (3840x2160)', 'Refresh': '240Hz'},
      isFeatured: true,
    ),
    ComputerProduct(
      id: 'keyboard_1',
      name: 'Keychron Q1 Pro Wireless',
      description: 'Mechanical Keyboard ไร้สาย 75% Layout สวิตช์ Gateron G Pro Red RGB รองรับ Bluetooth 5.1',
      price: 5490,
      originalPrice: 6290,
      category: 'Keyboard',
      brand: 'Keychron',
      emoji: '⌨️',
      imagePath: 'assets/images/keyboard_keychron.png',
      colorHex: const Color(0xFFFF8C00),
      specs: {'Layout': '75% (84 Keys)', 'Switch': 'Gateron G Pro Red', 'Connectivity': 'BT 5.1 / USB-C', 'RGB': 'Yes'},
    ),
    ComputerProduct(
      id: 'mouse_1',
      name: 'Logitech G Pro X Superlight 2',
      description: 'เม้าส์ Gaming น้ำหนักเบาเพียง 60g เซนเซอร์ HERO 2 25600 DPI ไร้สาย LIGHTSPEED',
      price: 3490,
      originalPrice: 4290,
      category: 'Mouse',
      brand: 'Logitech',
      emoji: '🖱️',
      imagePath: 'assets/images/mouse_logitech.png',
      colorHex: const Color(0xFF00D4AA),
      specs: {'Sensor': 'HERO 2', 'DPI': 'Up to 25600', 'Weight': '60g', 'Buttons': '5'},
    ),
    ComputerProduct(
      id: 'headset_1',
      name: 'HyperX Cloud Alpha Wireless',
      description: 'หูฟัง Gaming ไร้สาย แบตเตอรี่ 300 ชั่วโมง เสียง DTS 7.1 Surround ชัดใส ไดร์เวอร์ 50mm',
      price: 4290,
      originalPrice: 5290,
      category: 'Headset',
      brand: 'HyperX',
      emoji: '🎧',
      imagePath: 'assets/images/headset_hyperx.png',
      colorHex: const Color(0xFFFF3232),
      specs: {'Driver': '50mm Dual Chamber', 'Frequency': '15Hz-21kHz', 'Battery': '300 hours', 'Surround': 'DTS 7.1'},
    ),
  ];

  List<ComputerProduct> get allProducts => _firestoreProducts.isNotEmpty ? _firestoreProducts : _demoProducts;

  List<ComputerProduct> getProductsByCategory(String category) {
    final list = allProducts;
    if (category == 'ทั้งหมด') return list;
    return list.where((p) => p.category == category).toList();
  }

  List<ComputerProduct> getFeaturedProducts() {
    return allProducts.where((p) => p.isFeatured).toList();
  }

  List<ComputerProduct> searchProducts(String query) {
    final list = allProducts;
    if (query.isEmpty) return list;
    
    final q = query.toLowerCase();
    return list.where((p) {
      final nameMatch = p.name.toLowerCase().contains(q);
      final brandMatch = p.brand.toLowerCase().contains(q);
      final catMatch = p.category.toLowerCase().contains(q);
      final descMatch = p.description.toLowerCase().contains(q);
      
      // Thai Keyword mappings
      final isThaiCpu = (q.contains('ซีพียู') || q.contains('cpu')) && p.category == 'CPU';
      final isThaiGpu = (q.contains('การ์ดจอ') || q.contains('vga') || q.contains('gpu')) && p.category == 'GPU';
      final isThaiMonitor = (q.contains('จอ') || q.contains('monitor')) && p.category == 'Monitor';
      final isThaiKeyboard = (q.contains('คีย์บอร์ด') || q.contains('แป้นพิมพ์')) && p.category == 'Keyboard';
      final isThaiMouse = (q.contains('เมาส์') || q.contains('เม้าส์')) && p.category == 'Mouse';
      final isThaiHeadset = (q.contains('หูฟัง')) && p.category == 'Headset';
      final isThaiRam = (q.contains('แรม')) && p.category == 'RAM';

      return nameMatch || brandMatch || catMatch || descMatch || 
             isThaiCpu || isThaiGpu || isThaiMonitor || isThaiKeyboard || 
             isThaiMouse || isThaiHeadset || isThaiRam;
    }).toList();
  }

  // ========== ORDERS ==========
  Future<String> placeOrder(String address) async {
    final user = _auth.currentUser;
    final items = _cartItems.map((i) => {
      'productId': i.productId,
      'name': i.name,
      'price': i.price,
      'quantity': i.quantity,
      'emoji': i.emoji,
    }).toList();

    final docRef = await _db.collection('computer_orders').add({
      'userId': user?.uid ?? 'anonymous',
      'items': items,
      'total': cartTotal + 50,
      'address': address,
      'status': 'รอดำเนินการ',
      'createdAt': FieldValue.serverTimestamp(),
    });

    clearCart();
    return docRef.id;
  }

  Stream<List<OrderModel>> getOrdersStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    
    // Fallback to local memory sort to avoid Firestore Composite Index requirement
    return _db
        .collection('computer_orders')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) => OrderModel.fromFirestore(d)).toList();
          // Sort descending by date (newest first)
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }
}
