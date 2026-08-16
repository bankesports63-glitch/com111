import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/shop_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscure = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final service = context.read<ShopService>();
    try {
      if (_isLogin) {
        await service.signIn(_emailController.text.trim(), _passwordController.text.trim());
      } else {
        await service.register(_emailController.text.trim(), _passwordController.text.trim());
      }
    } catch (e) {
      if (mounted) {
        final errStr = e.toString();
        if (errStr.contains('email-already-in-use')) {
          _showError('อีเมลนี้ถูกลงทะเบียนไปแล้ว กรุณากดเข้าสู่ระบบ');
        } else if (errStr.contains('weak-password')) {
          _showError('รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร');
        } else if (errStr.contains('invalid-credential') || errStr.contains('wrong-password') || errStr.contains('user-not-found')) {
          _showError('อีเมลหรือรหัสผ่านไม่ถูกต้อง');
        } else if (errStr.contains('invalid-email')) {
          _showError('รูปแบบอีเมลไม่ถูกต้อง');
        } else {
          _showError('เกิดข้อผิดพลาด: โปรดตรวจสอบการเชื่อมต่อ หรือข้อมูลอีเมล');
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.rajdhani(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Tech Grid / Neon Accent
          Positioned(
            top: -150,
            right: -150,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C3FF).withValues(alpha: 0.15),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF88).withValues(alpha: 0.15),
                    blurRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          // Main Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand / Logo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF12121E),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF00FF88).withValues(alpha: 0.5), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00FF88).withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.sports_esports_rounded,
                        color: Color(0xFF00FF88),
                        size: 54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'NEON TECH',
                      style: GoogleFonts.orbitron(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      'GAMING & COMPUTER SHOP',
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF00C3FF),
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Form Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF12121E).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _isLogin ? 'เข้าสู่ระบบ' : 'สร้างบัญชีผู้ใช้',
                              style: GoogleFonts.rajdhani(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            // Email
                            TextFormField(
                              controller: _emailController,
                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'อีเมล',
                                labelStyle: GoogleFonts.rajdhani(color: Colors.grey),
                                prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF00C3FF)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF00C3FF)),
                                ),
                                filled: true,
                                fillColor: const Color(0xFF0A0A10),
                              ),
                              validator: (val) => val == null || !val.contains('@') ? 'อีเมลไม่ถูกต้อง' : null,
                            ),
                            const SizedBox(height: 16),
                            // Password
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscure,
                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'รหัสผ่าน',
                                labelStyle: GoogleFonts.rajdhani(color: Colors.grey),
                                prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF00FF88)),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: Color(0xFF00FF88)),
                                ),
                                filled: true,
                                fillColor: const Color(0xFF0A0A10),
                              ),
                              validator: (val) => val == null || val.length < 6 ? 'รหัสผ่านต้องมี 6 ตัวขึ้นไป' : null,
                            ),
                            const SizedBox(height: 24),
                            // Action Button
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF00FF88), Color(0xFF00C3FF)],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00FF88).withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? const CircularProgressIndicator(color: Colors.black)
                                        : Text(
                                            _isLogin ? 'CONNECT START' : 'CREATE USER',
                                            style: GoogleFonts.orbitron(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.black,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Toggle Auth Mode
                    TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(
                        _isLogin ? 'ยังไม่มีบัญชี? สมัครที่นี่' : 'มีบัญชีแล้ว? เข้าสู่ระบบ',
                        style: GoogleFonts.rajdhani(
                          color: const Color(0xFF00C3FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
