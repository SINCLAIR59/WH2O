import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4F67FF),
      body: Column(
        children: [
          const SizedBox(height: 60),
          // Section Logo และ Title
          Center(
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
                    Icons.water_drop_outlined,
                    size: 40,
                    color: Color(0xFF4A6FFF),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'WH2O LOGIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  'Environmental Monitoring System',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // ส่วนเนื้อหาที่เป็นสีขาว
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'เข้าสู่ระบบ',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'เข้าสู่บัญชีของคุณเพื่อเริ่มต้นใช้งาน',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),

                    // Input: อีเมล
                    const Text('อีเมล', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hint: 'กรุณากรอกอีเมลของคุณ',
                      icon: Icons.email_outlined,
                    ),

                    const SizedBox(height: 20),

                    // Input: รหัสผ่าน
                    const Text('รหัสผ่าน', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hint: 'กรุณากรอกรหัสผ่านของคุณ',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),

                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('ลืมรหัสผ่าน?', style: TextStyle(color: Color(0xFF4F67FF))),
                      ),
                    ),

                    const SizedBox(height: 10),
                    // ปุ่มเข้าสู่ระบบ
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5856D6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          // ✅ นำทางไปหน้า Home หลังเข้าสู่ระบบสำเร็จ
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        child: const Text(
                          'เข้าสู่ระบบ',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    // ปุ่ม Social Login
                    Row(
                      children: [
                        Expanded(child: _buildSocialButton('Google', 'assets/google_logo.png')),
                        const SizedBox(width: 15),
                        Expanded(child: _buildSocialButton('Facebook', Icons.facebook, color: Colors.blue)),
                      ],
                    ),

                    const SizedBox(height: 30),
                    // ลิงก์ไปหน้าลงทะเบียน
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('ยังไม่มีบัญชีใช่ไหม? '),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/register'),  // ✅ แก้ไขเป็น pushNamed
                            child: const Text(
                              'ลงทะเบียนที่นี่',
                              style: TextStyle(
                                color: Color(0xFF4F67FF),
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
          ),
        ],
      ),
    );
  }

  // Widget สำหรับสร้างช่องกรอกข้อมูล
  static Widget _buildTextField({required String hint, required IconData icon, bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: isPassword ? const Icon(Icons.visibility_outlined, color: Colors.grey) : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  // Widget สำหรับสร้างปุ่ม Social
  static Widget _buildSocialButton(String label, dynamic icon, {Color? color}) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onPressed: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon is IconData) Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}