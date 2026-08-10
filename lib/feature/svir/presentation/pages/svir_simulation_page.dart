import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/svir_models.dart';
import '../providers/svir_provider.dart';

class SvirSimulationPage extends StatefulWidget {
  const SvirSimulationPage({super.key});

  @override
  State<SvirSimulationPage> createState() => _SvirSimulationPageState();
}

class _SvirSimulationPageState extends State<SvirSimulationPage> {
  int _population = 100000;
  double _vaccinationRate = 0.3;
  double _contactRate = 0.4;
  double _recoveryRate = 0.15;
  double _vaccineEfficacy = 0.8;
  int _days = 180;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerSimulation();
    });
  }

  void _triggerSimulation() {
    final req = SimulationRequest(
      population: _population,
      vaccinationRate: _vaccinationRate,
      contactRate: _contactRate,
      recoveryRate: _recoveryRate,
      vaccineEfficacy: _vaccineEfficacy,
      days: _days,
    );
    context.read<SvirProvider>().runSimulation(req);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SvirProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Simulasi Penyebaran TBC',
          style: AppTextStyles.labelLarge.copyWith(fontSize: 18),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Chart Container
            Container(
              height: 340,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.simulationResponse == null
                      ? const Center(
                          child: Text(
                            'Memuat kalkulasi simulasi...',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Kurva Proyeksi Penyebaran Penyakit',
                              style: AppTextStyles.labelMedium.copyWith(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: CustomPaint(
                                painter: _SvirLineChartPainter(
                                  response: provider.simulationResponse!,
                                  population: _population.toDouble(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Custom legends with clear names
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildLegendItem('Rentan', Colors.blue),
                                _buildLegendItem('Divaksin', Colors.teal),
                                _buildLegendItem('Sakit (TBC)', Colors.redAccent),
                                _buildLegendItem('Sembuh', Colors.purple),
                              ],
                            ),
                          ],
                        ),
            ),
            const SizedBox(height: 24),

            // 2. Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Geser slider parameter di bawah untuk mensimulasikan penyebaran TBC secara real-time.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Parameters Title
            Text(
              'Parameter Simulasi',
              style: AppTextStyles.labelLarge.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),

            // 4. Sliders Section
            _buildSliderCard(
              title: 'Total Populasi',
              value: _population.toDouble(),
              min: 10000,
              max: 500000,
              divisions: 49,
              displayText: _population.toString(),
              icon: Icons.people_alt_rounded,
              iconColor: AppColors.primary,
              onChanged: (val) {
                setState(() {
                  _population = val.toInt();
                });
                _triggerSimulation();
              },
            ),
            const SizedBox(height: 12),

            _buildSliderCard(
              title: 'Laju Penularan (Contact Rate)',
              value: _contactRate,
              min: 0.1,
              max: 1.0,
              divisions: 18,
              displayText: _contactRate.toStringAsFixed(2),
              icon: Icons.insights_rounded,
              iconColor: Colors.redAccent,
              onChanged: (val) {
                setState(() {
                  _contactRate = val;
                });
                _triggerSimulation();
              },
            ),
            const SizedBox(height: 12),

            _buildSliderCard(
              title: 'Laju Vaksinasi Harian',
              value: _vaccinationRate,
              min: 0.0,
              max: 0.8,
              divisions: 16,
              displayText: _vaccinationRate.toStringAsFixed(2),
              icon: Icons.vaccines_rounded,
              iconColor: Colors.teal,
              onChanged: (val) {
                setState(() {
                  _vaccinationRate = val;
                });
                _triggerSimulation();
              },
            ),
            const SizedBox(height: 12),

            _buildSliderCard(
              title: 'Efikasi Vaksin (Efficacy)',
              value: _vaccineEfficacy,
              min: 0.1,
              max: 1.0,
              divisions: 18,
              displayText: _vaccineEfficacy.toStringAsFixed(2),
              icon: Icons.verified_user_rounded,
              iconColor: Colors.blueAccent,
              onChanged: (val) {
                setState(() {
                  _vaccineEfficacy = val;
                });
                _triggerSimulation();
              },
            ),
            const SizedBox(height: 12),

            _buildSliderCard(
              title: 'Laju Kesembuhan (Recovery Rate)',
              value: _recoveryRate,
              min: 0.05,
              max: 0.5,
              divisions: 9,
              displayText: _recoveryRate.toStringAsFixed(2),
              icon: Icons.healing_rounded,
              iconColor: Colors.orangeAccent,
              onChanged: (val) {
                setState(() {
                  _recoveryRate = val;
                });
                _triggerSimulation();
              },
            ),
            const SizedBox(height: 12),

            _buildSliderCard(
              title: 'Durasi Proyeksi',
              value: _days.toDouble(),
              min: 60,
              max: 360,
              divisions: 10,
              displayText: '$_days Hari',
              icon: Icons.date_range_rounded,
              iconColor: Colors.blueGrey,
              onChanged: (val) {
                setState(() {
                  _days = val.toInt();
                });
                _triggerSimulation();
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderCard({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayText,
    required IconData icon,
    required Color iconColor,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                displayText,
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 14,
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              activeTrackColor: iconColor,
              inactiveTrackColor: iconColor.withOpacity(0.12),
              thumbColor: iconColor,
              overlayColor: iconColor.withOpacity(0.16),
              valueIndicatorColor: iconColor,
              valueIndicatorTextStyle: const TextStyle(color: Colors.white),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: displayText,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 11,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SvirLineChartPainter extends CustomPainter {
  final SimulationResponse response;
  final double population;

  _SvirLineChartPainter({required this.response, required this.population});

  @override
  void paint(Canvas canvas, Size size) {
    const double leftPadding = 45.0;
    const double bottomPadding = 25.0;
    const double rightPadding = 8.0;
    const double topPadding = 8.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    final paintGrid = Paint()
      ..color = Colors.grey[100]!
      ..strokeWidth = 1.0;

    final paintAxis = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.5;

    // Draw grid lines and Y-axis labels
    const int gridCount = 4;
    for (int i = 0; i <= gridCount; i++) {
      final ratio = i / gridCount;
      final y = topPadding + chartHeight * (1.0 - ratio);

      // Draw grid line
      if (i > 0 && i < gridCount) {
        canvas.drawLine(
          Offset(leftPadding, y),
          Offset(size.width - rightPadding, y),
          paintGrid,
        );
      }

      // Draw Y label
      final val = population * ratio;
      _drawText(
        canvas,
        _formatNumber(val),
        Offset(leftPadding - 8, y),
        AppColors.textSecondary,
        isRightAligned: true,
      );
    }

    // Draw main axes
    // Y-axis
    canvas.drawLine(
      Offset(leftPadding, topPadding),
      Offset(leftPadding, topPadding + chartHeight),
      paintAxis,
    );
    // X-axis
    canvas.drawLine(
      Offset(leftPadding, topPadding + chartHeight),
      Offset(size.width - rightPadding, topPadding + chartHeight),
      paintAxis,
    );

    // Graph plotting logic
    final daysCount = response.days.length;
    if (daysCount < 2) return;

    final maxVal = population;

    _drawSvirLine(canvas, response.susceptible, leftPadding, topPadding, chartWidth, chartHeight, maxVal, Colors.blue);
    _drawSvirLine(canvas, response.vaccinated, leftPadding, topPadding, chartWidth, chartHeight, maxVal, Colors.teal);
    _drawSvirLine(canvas, response.infected, leftPadding, topPadding, chartWidth, chartHeight, maxVal, Colors.redAccent);
    _drawSvirLine(canvas, response.recovered, leftPadding, topPadding, chartWidth, chartHeight, maxVal, Colors.purple);

    // Draw X-axis labels at Day 0, Day middle, Day end
    final daysLimit = daysCount - 1;
    final xDays = [0, daysLimit ~/ 2, daysLimit];
    for (final day in xDays) {
      final ratio = day / daysLimit;
      final x = leftPadding + chartWidth * ratio;
      final y = topPadding + chartHeight;

      // Draw small tick mark
      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + 4),
        paintAxis,
      );

      // Draw X label
      _drawText(
        canvas,
        'Hari $day',
        Offset(x, y + 14),
        AppColors.textSecondary,
        isCenterAligned: true,
      );
    }
  }

  void _drawSvirLine(
    Canvas canvas,
    List<double> values,
    double leftPadding,
    double topPadding,
    double chartWidth,
    double chartHeight,
    double maxVal,
    Color color,
  ) {
    final paintLine = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final stepX = chartWidth / (values.length - 1);

    for (int i = 0; i < values.length; i++) {
      final x = leftPadding + i * stepX;
      final y = topPadding + chartHeight - (values[i] / maxVal) * chartHeight;

      if (i == 0) {
        path.moveTo(x, y.clamp(topPadding, topPadding + chartHeight));
      } else {
        path.lineTo(x, y.clamp(topPadding, topPadding + chartHeight));
      }
    }

    canvas.drawPath(path, paintLine);
  }

  String _formatNumber(double val) {
    if (val >= 1000000) {
      return '${(val / 1000000).toStringAsFixed(1)}M';
    } else if (val >= 1000) {
      return '${(val / 1000).toStringAsFixed(0)}k';
    }
    return val.toStringAsFixed(0);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    Color color, {
    bool isRightAligned = false,
    bool isCenterAligned = false,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    double x = position.dx;
    if (isRightAligned) {
      x -= textPainter.width;
    } else if (isCenterAligned) {
      x -= textPainter.width / 2;
    }
    final y = position.dy - textPainter.height / 2;
    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
