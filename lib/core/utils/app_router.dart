import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/activation_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/consent_page.dart';
import '../../features/patient/presentation/pages/patient_main_page.dart';
import '../../features/admin/presentation/pages/admin_main_page.dart';
import '../../features/admin/presentation/pages/admin_add_patient_page.dart';
import '../../features/admin/presentation/pages/admin_mark_zone_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/activation',
        name: 'activation',
        builder: (context, state) => const ActivationPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/consent',
        name: 'consent',
        builder: (context, state) => const ConsentPage(),
      ),
      GoRoute(
        path: '/patient-dashboard',
        name: 'patientDashboard',
        builder: (context, state) => const PatientMainPage(),
      ),
      GoRoute(
        path: '/admin-dashboard',
        name: 'adminDashboard',
        builder: (context, state) => const AdminMainPage(),
      ),
      GoRoute(
        path: '/admin/add-patient',
        name: 'adminAddPatient',
        builder: (context, state) => const AdminAddPatientPage(),
      ),
      GoRoute(
        path: '/admin/mark-zone',
        name: 'adminMarkZone',
        builder: (context, state) => const AdminMarkZonePage(),
      ),
    ],
  );
}
