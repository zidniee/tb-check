import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../screening/presentation/pages/screening_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../doctor/presentation/widgets/doctor_bottom_navigation_bar.dart';
import '../../../doctor/presentation/pages/doctor_dashboard_page.dart';
import '../../../doctor/presentation/pages/doctor_patients_page.dart';
import '../../../doctor/presentation/pages/doctor_consultations_page.dart';
import '../../../education/presentation/pages/education_list_page.dart';
import '../../../../core/service/fcm_service.dart';
import '../widgets/patient_bottom_navigation_bar.dart';
import 'home_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FCMService().initialize(context);
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isDoctor = authProvider.userRole == UserRole.doctor;

    final List<Widget> patientPages = [
      HomePage(onStartScreeningTap: () => _onTabSelected(1)),
      const ScreeningPage(),
      const EducationListPage(),
      const ProfilePage(),
    ];

    final List<Widget> doctorPages = [
      DoctorDashboardPage(
        onPatientsTabTap: () => _onTabSelected(1),
        onConsultationsTabTap: () => _onTabSelected(2),
      ),
      const DoctorPatientsPage(),
      const DoctorConsultationsPage(),
      const ProfilePage(),
    ];

    final List<Widget> activePages = isDoctor ? doctorPages : patientPages;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: activePages,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: isDoctor
                ? DoctorBottomNavigationBar(
                    selectedIndex: _selectedIndex,
                    onTabSelected: _onTabSelected,
                  )
                : PatientBottomNavigationBar(
                    selectedIndex: _selectedIndex,
                    onTabSelected: _onTabSelected,
                  ),
          ),
        ],
      ),
    );
  }
}
