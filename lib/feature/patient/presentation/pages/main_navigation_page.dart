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
import '../../../education/presentation/providers/education_provider.dart';
import '../../../../core/service/fcm_service.dart';
import '../widgets/patient_bottom_navigation_bar.dart';
import 'home_page.dart';
import '../providers/dashboard_provider.dart';
import '../providers/care_provider.dart';
import '../../../doctor/presentation/providers/doctor_dashboard_provider.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => MainNavigationPageState();
}

class MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FCMService().initialize(context);
    });
  }

  void onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bool isDoctor = authProvider.userRole == UserRole.doctor;
      
      if (isDoctor) {
        if (index == 0) {
          Provider.of<DoctorDashboardProvider>(context, listen: false).fetchDashboard();
        }
      } else {
        if (index == 0) {
          Provider.of<DashboardProvider>(context, listen: false).fetchDashboard();
          Provider.of<CareProvider>(context, listen: false).loadCareData();
        } else if (index == 2) {
          Provider.of<EducationProvider>(context, listen: false).fetchContents();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isDoctor = authProvider.userRole == UserRole.doctor;

    final List<Widget> patientPages = [
      HomePage(onStartScreeningTap: () => onTabSelected(1)),
      const ScreeningPage(),
      const EducationListPage(),
      const ProfilePage(),
    ];

    final List<Widget> doctorPages = [
      DoctorDashboardPage(
        onPatientsTabTap: () => onTabSelected(1),
        onConsultationsTabTap: () => onTabSelected(2),
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
                    onTabSelected: onTabSelected,
                  )
                : PatientBottomNavigationBar(
                    selectedIndex: _selectedIndex,
                    onTabSelected: onTabSelected,
                  ),
          ),
        ],
      ),
    );
  }
}
