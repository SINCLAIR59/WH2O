import 'package:flutter/material.dart';
import 'package:wh2o/services/auth_service.dart'; // ✅ Import Service

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State Variables
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  bool _isLoading = false; // ✅ เพิ่มตัวแปรเช็คสถานะโหลด

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // แก้ไขฟังก์ชันนี้
  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('กรุณายอมรับข้อกำหนดและเงื่อนไข'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      // 1. เรียก API สมัครสมาชิก
      final registerResult = await AuthService.register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!context.mounted) return;

      if (registerResult['status'] == 'ok') {
        // 2. สมัครสำเร็จ -> สั่ง Login ต่อทันที!
        final loginResult = await AuthService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (!context.mounted) return;
        setState(() => _isLoading = false);

        if (loginResult['status'] == 'ok') {
          // 3. Login สำเร็จ -> ไปหน้า Home เลย (และลบประวัติย้อนหลังออกให้หมด)
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } else {
          // กรณีแปลกๆ (สมัครได้ แต่ Login ไม่ได้) -> ส่งไปหน้า Login ปกติ
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        // สมัครไม่สำเร็จ
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(registerResult['message'] ?? 'เกิดข้อผิดพลาด'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A6FFF), Color(0xFF5B7FFF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),

                // --- Logo and Title ---
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.water_drop,
                          size: 40,
                          color: Color(0xFF4A6FFF),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'WH2O REGISTER',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'สร้างบัญชีใหม่',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- Form Container ---
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Username
                        const Text(
                          'ชื่อผู้ใช้',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: 'กรอกชื่อผู้ใช้',
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) => value?.isEmpty ?? true
                              ? 'กรุณากรอกชื่อผู้ใช้'
                              : null,
                        ),

                        const SizedBox(height: 16),

                        // 2. Email
                        const Text(
                          'อีเมล',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'กรอกอีเมล',
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'กรุณากรอกอีเมล';
                            if (!value!.contains('@')) return 'อีเมลไม่ถูกต้อง';
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // 3. Password
                        const Text(
                          'รหัสผ่าน',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'กรอกรหัสผ่าน',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Colors.grey,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () => setState(
                                () => _isPasswordVisible = !_isPasswordVisible,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true)
                              return 'กรุณากรอกรหัสผ่าน';
                            if (value!.length < 6)
                              return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // 4. Confirm Password
                        const Text(
                          'ยืนยันรหัสผ่าน',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'กรอกรหัสผ่านอีกครั้ง',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Colors.grey,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () => setState(
                                () => _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true)
                              return 'กรุณายืนยันรหัสผ่าน';
                            if (value != _passwordController.text)
                              return 'รหัสผ่านไม่ตรงกัน';
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // 5. Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptTerms,
                              onChanged: (value) =>
                                  setState(() => _acceptTerms = value ?? false),
                            ),
                            const Expanded(
                              child: Text(
                                'ยอมรับข้อกำหนดและเงื่อนไข',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // 6. Register Button (แก้ไขให้มี Loading)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A6FFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            // ถ้าโหลดอยู่ ให้กดไม่ได้ (null)
                            onPressed: _isLoading ? null : _handleRegister,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'ลงทะเบียน',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 7. Login Link
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('มีบัญชีอยู่แล้ว? '),
                              GestureDetector(
                                // เปลี่ยน Navigator.pushNamed เป็น pop เพื่อกลับหน้าเดิมถ้ามาจาก Login
                                onTap: () => Navigator.pop(context),
                                child: const Text(
                                  'เข้าสู่ระบบ',
                                  style: TextStyle(
                                    color: Color(0xFF4A6FFF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
