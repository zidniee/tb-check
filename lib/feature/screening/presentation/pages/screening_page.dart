import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/screening_provider.dart';
import '../widgets/medical_disclaimer_banner.dart';
import '../widgets/questionnaire_step.dart';
import '../widgets/recording_step.dart';
import '../widgets/screening_bottom_actions.dart';
import '../widgets/screening_stepper_header.dart';

class ScreeningPage extends StatefulWidget {
  const ScreeningPage({super.key});

  @override
  State<ScreeningPage> createState() => _ScreeningPageState();
}

class _ScreeningPageState extends State<ScreeningPage> {
  final TextEditingController _ageController = TextEditingController();

  final List<String> _questions = [
    'Apakah Anda batuk terus-menerus selama ≥ 2 minggu?',
    'Apakah batuk Anda pernah disertai dahak berdarah?',
    'Apakah Anda mengalami demam lama/berulang tanpa sebab jelas?',
    'Apakah berat badan Anda turun signifikan dalam 2 bulan terakhir?',
    'Apakah Anda sering berkeringat di malam hari tanpa aktivitas fisik?',
    'Apakah Anda mengalami sesak napas atau nyeri dada?',
    'Apakah Anda kehilangan nafsu makan secara terus-menerus?',
    'Apakah Anda merasa lemas, lesu, atau mudah lelah secara kronis?',
    'Apakah Anda tinggal/kontak dekat dengan penderita TBC aktif?',
    'Apakah Anda memiliki riwayat merokok aktif?',
  ];

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScreeningProvider(),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Navigator.of(context).canPop()
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null,
            title: Text(
              'Skrining Multimodal TBC',
              style: AppTextStyles.labelLarge.copyWith(fontSize: 20),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Consumer<ScreeningProvider>(
              builder: (context, provider, child) {
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    top: 12.0,
                    bottom: 100.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Wizard Stepper Header
                      ScreeningStepperHeader(currentStep: provider.currentStep),
                      const SizedBox(height: 16),
                      
                      // Medical Disclaimer Banner (always visible at top of page)
                      const MedicalDisclaimerBanner(),
                      const SizedBox(height: 16),
                      
                      // Main Wizard Step Body
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.border, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.textPrimary.withOpacity(0.03),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: provider.currentStep == 0
                              ? QuestionnaireStep(
                                  provider: provider,
                                  ageController: _ageController,
                                  questions: _questions,
                                )
                              : RecordingStep(provider: provider),
                        ),
                      ),
                      
                      // Action Buttons at the Bottom
                      const SizedBox(height: 16),
                      ScreeningBottomActions(provider: provider),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
