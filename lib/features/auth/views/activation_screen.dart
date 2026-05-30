import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../app/config/app_colors.dart';
import '../../../app/config/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/auth_controller.dart';

class ActivationScreen extends GetView<AuthController> {
  const ActivationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktivasi Akun Pasien'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text(
              'Masukkan Kode Aktivasi',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Masukkan 6 digit kode yang diberikan oleh petugas kesehatan Anda.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 32),
             // OTP-style input
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: List.generate(6, (index) {
                 return SizedBox(
                   width: 45,
                   height: 50,
                   child: TextFormField(
                     controller: controller.codeControllers[index],
                     keyboardType: TextInputType.number,
                     textAlign: TextAlign.center,
                     maxLength: 1,
                     style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                     inputFormatters: [
                       FilteringTextInputFormatter.digitsOnly,
                     ],
                     decoration: InputDecoration(
                       counterText: '',
                       filled: true,
                       fillColor: AppColors.cardBg,
                       contentPadding: EdgeInsets.zero,
                       enabledBorder: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(8),
                         borderSide: const BorderSide(color: AppColors.border),
                       ),
                       focusedBorder: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(8),
                         borderSide: const BorderSide(
                           color: AppColors.primary,
                           width: 2,
                         ),
                       ),
                     ),
                     onChanged: (value) {
                       if (value.isNotEmpty && index < 5) {
                         FocusScope.of(context).nextFocus();
                       }
                       if (value.isEmpty && index > 0) {
                         FocusScope.of(context).previousFocus();
                       }
                     },
                   ),
                 );
               }),
             ),
             const SizedBox(height: 24),
             // Email
             TextFormField(
               controller: controller.emailController,
               keyboardType: TextInputType.emailAddress,
               decoration: const InputDecoration(
                 labelText: 'Alamat Email',
                 hintText: 'Contoh: email@anda.com',
                 prefixIcon: Icon(Icons.email_outlined),
               ),
             ),
             const SizedBox(height: 16),
             // Password
             Obx(() => TextFormField(
                   controller: controller.passwordController,
                   obscureText: controller.isObscure.value,
                   decoration: InputDecoration(
                     labelText: 'Buat Password Baru',
                     hintText: 'Minimal 6 karakter',
                     prefixIcon: const Icon(Icons.lock_outline),
                     suffixIcon: IconButton(
                       icon: Icon(
                         controller.isObscure.value
                             ? Icons.visibility_off_outlined
                             : Icons.visibility_outlined,
                       ),
                       onPressed: () => controller.isObscure.toggle(),
                     ),
                   ),
                 )),
             const SizedBox(height: 16),
             // Confirm Password
             Obx(() => TextFormField(
                   controller: controller.confirmPasswordController,
                   obscureText: controller.isObscureConfirm.value,
                   decoration: InputDecoration(
                     labelText: 'Konfirmasi Password',
                     hintText: 'Masukkan ulang password',
                     prefixIcon: const Icon(Icons.lock_outline),
                     suffixIcon: IconButton(
                       icon: Icon(
                         controller.isObscureConfirm.value
                             ? Icons.visibility_off_outlined
                             : Icons.visibility_outlined,
                       ),
                       onPressed: () => controller.isObscureConfirm.toggle(),
                     ),
                   ),
                 )),
             const SizedBox(height: 32),
             Obx(() => AppButton(
                   text: 'AKTIVASI & BUAT AKUN',
                   onPressed: controller.activateAccount,
                   isLoading: controller.isActivating.value,
                   icon: Icons.verified_user_outlined,
                 )),
          ],
        ),
      ),
    );
  }
}
