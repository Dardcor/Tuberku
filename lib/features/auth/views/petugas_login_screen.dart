import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../app/config/app_colors.dart';
import '../../../app/config/app_text_styles.dart';
import '../../../app/config/app_constants.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/user_model.dart';

class PetugasLoginScreen extends StatefulWidget {
  const PetugasLoginScreen({super.key});

  @override
  State<PetugasLoginScreen> createState() => _PetugasLoginScreenState();
}

class _PetugasLoginScreenState extends State<PetugasLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isObscure = true;
  bool _isLoading = false;
  bool _isRegisterMode = false;

  // Register fields
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isConfirmObscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Email dan password wajib diisi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Get.find<SupabaseService>();

      final response = await supabase.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final profile = await supabase.getProfile(response.user!.id);

        if (mounted) {
          if (profile?.role != 'petugas') {
            await supabase.signOut();
            Get.snackbar(
              'Akses Ditolak',
              'Akun ini bukan akun Petugas Kesehatan.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange.shade100,
            );
            return;
          }

          Get.snackbar(
            'Berhasil!',
            'Selamat bertugas, ${profile?.fullName ?? 'Petugas'}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade900,
          );

          Get.offAllNamed(AppRoutes.adminDashboard);
        }
      }
    } catch (e) {
      String errorMessage = 'Email atau password salah';
      if (e.toString().contains('Invalid login credentials')) {
        errorMessage = 'Email atau password salah.';
      } else if (e.toString().contains('network_error') || e.toString().contains('SocketException')) {
        errorMessage = 'Koneksi internet bermasalah.';
      } else {
        errorMessage = e.toString().replaceAll('AuthApiException:', '').replaceAll('message:', '').split(', statusCode:')[0].trim();
      }
      Get.snackbar(
        'Gagal Masuk',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Semua field wajib diisi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100);
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Error', 'Format email tidak valid',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100);
      return;
    }

    if (password.length < 6) {
      Get.snackbar('Error', 'Password minimal 6 karakter',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100);
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar('Error', 'Konfirmasi password tidak cocok',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Get.find<SupabaseService>();

      final response = await supabase.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );

      if (response.user != null) {
        // Set role sebagai petugas
        await supabase.upsertProfile(UserModel(
          id: response.user!.id,
          role: AppConstants.rolePetugas,
          fullName: name,
          email: email,
          phone: phone,
          createdAt: DateTime.now(),
        ));

        if (mounted) {
          Get.snackbar(
            'Berhasil!',
            'Akun petugas berhasil dibuat. Silakan masuk.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade900,
            duration: const Duration(seconds: 3),
          );

          // Reset ke mode login
          setState(() {
            _isRegisterMode = false;
            _nameController.clear();
            _phoneController.clear();
            _passwordController.clear();
            _confirmPasswordController.clear();
          });
        }
      }
    } catch (e) {
      String errorMessage = 'Terjadi kesalahan tidak terduga';

      if (e.toString().contains('user_already_exists')) {
        errorMessage = 'Email ini sudah terdaftar. Silakan masuk.';
      } else if (e.toString().contains('over_email_send_rate_limit')) {
        errorMessage = 'Terlalu banyak permintaan. Tunggu 1 menit lalu coba lagi.';
      } else {
        errorMessage = e.toString().replaceAll('AuthApiException:', '').replaceAll('message:', '').split(', statusCode:')[0].trim();
      }

      Get.snackbar(
        'Pendaftaran Gagal',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 40,
              left: 24,
              right: 24,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back, color: AppColors.white),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 16),
                SvgPicture.asset(
                  AppConstants.logoPath,
                  height: 60,
                ),
                const SizedBox(height: 12),
                Text(
                  _isRegisterMode ? 'Daftar Petugas' : 'Panel Petugas',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.white,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isRegisterMode
                      ? 'Daftarkan akun petugas kesehatan baru'
                      : 'Masuk sebagai petugas kesehatan Tuberku',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  if (_isRegisterMode) ...[
                    _buildField(
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama lengkap',
                      icon: Icons.person_outline,
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 20),
                  ],
                  _buildField(
                    label: _isRegisterMode ? 'Email' : 'ID / Email Petugas',
                    hint: _isRegisterMode ? 'contoh@email.com' : 'Masukkan email Petugas',
                    icon: Icons.badge_outlined,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  if (_isRegisterMode) ...[
                    const SizedBox(height: 20),
                    _buildField(
                      label: 'Nomor WhatsApp',
                      hint: 'Contoh: 08123456789',
                      icon: Icons.phone_outlined,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _isObscure,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: _isRegisterMode ? 'Minimal 6 karakter' : 'Masukkan password',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary, size: 22),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textHint,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _isObscure = !_isObscure),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_isRegisterMode) ...[
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Konfirmasi Password',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: _isConfirmObscure,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Ulangi password',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary, size: 22),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: AppColors.textHint,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _isConfirmObscure = !_isConfirmObscure),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 48),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : (_isRegisterMode ? _register : _login),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(_isRegisterMode ? 'DAFTAR AKUN PETUGAS' : 'MASUK KE PANEL'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isRegisterMode = !_isRegisterMode;
                          _passwordController.clear();
                          _confirmPasswordController.clear();
                        });
                      },
                      child: RichText(
                        text: TextSpan(
                          text: _isRegisterMode ? 'Sudah punya akun? ' : 'Belum punya akun petugas? ',
                          style: AppTextStyles.bodyMedium,
                          children: [
                            TextSpan(
                              text: _isRegisterMode ? 'Masuk di sini' : 'Daftar di sini',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
          ),
        ),
      ],
    );
  }
}
