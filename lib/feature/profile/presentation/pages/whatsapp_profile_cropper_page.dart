import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_theme.dart';

class CropParams {
  final Uint8List rawBytes;
  final double cropXRatio;
  final double cropYRatio;
  final double cropWRatio;
  final double cropHRatio;

  CropParams({
    required this.rawBytes,
    required this.cropXRatio,
    required this.cropYRatio,
    required this.cropWRatio,
    required this.cropHRatio,
  });
}

// Background Isolate Workers
Uint8List _isolateBakeOrientation(Uint8List rawBytes) {
  final decoded = img.decodeImage(rawBytes);
  if (decoded != null) {
    final oriented = img.bakeOrientation(decoded);
    return Uint8List.fromList(img.encodeJpg(oriented, quality: 90));
  }
  return rawBytes;
}

Uint8List _isolateRotateRight(Uint8List rawBytes) {
  final decoded = img.decodeImage(rawBytes);
  if (decoded != null) {
    final rotated = img.copyRotate(decoded, angle: 90);
    return Uint8List.fromList(img.encodeJpg(rotated, quality: 90));
  }
  return rawBytes;
}

Uint8List _isolateCropImage(CropParams params) {
  final decoded = img.decodeImage(params.rawBytes);
  if (decoded == null) return params.rawBytes;

  final oriented = img.bakeOrientation(decoded);
  final imgW = oriented.width;
  final imgH = oriented.height;

  int x = (params.cropXRatio * imgW).round().clamp(0, imgW - 1);
  int y = (params.cropYRatio * imgH).round().clamp(0, imgH - 1);
  int w = (params.cropWRatio * imgW).round().clamp(1, imgW - x);
  int h = (params.cropHRatio * imgH).round().clamp(1, imgH - y);

  final cropped = img.copyCrop(oriented, x: x, y: y, width: w, height: h);
  final resized = img.copyResize(cropped, width: 800);
  return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
}

class WhatsAppProfileCropperPage extends StatefulWidget {
  final String imagePath;

  const WhatsAppProfileCropperPage({
    super.key,
    required this.imagePath,
  });

  @override
  State<WhatsAppProfileCropperPage> createState() => _WhatsAppProfileCropperPageState();
}

class _WhatsAppProfileCropperPageState extends State<WhatsAppProfileCropperPage> {
  final TransformationController _transformationController = TransformationController();
  Uint8List? _imageBytes;
  int _imageWidth = 0;
  int _imageHeight = 0;

  bool _isProcessing = false;
  bool _isRotating = false;

  @override
  void initState() {
    super.initState();
    _loadImageBytes();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _loadImageBytes() async {
    try {
      final file = File(widget.imagePath);
      final bytes = await file.readAsBytes();

      final normalizedBytes = await compute(_isolateBakeOrientation, bytes);
      final decoded = img.decodeImage(normalizedBytes);

      if (mounted && decoded != null) {
        setState(() {
          _imageBytes = normalizedBytes;
          _imageWidth = decoded.width;
          _imageHeight = decoded.height;
        });
      }
    } catch (_) {
      final bytes = await File(widget.imagePath).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (mounted && decoded != null) {
        setState(() {
          _imageBytes = bytes;
          _imageWidth = decoded.width;
          _imageHeight = decoded.height;
        });
      }
    }
  }

  Future<void> _rotateImageRight() async {
    if (_imageBytes == null || _isRotating) return;
    setState(() {
      _isRotating = true;
    });

    try {
      final rotatedBytes = await compute(_isolateRotateRight, _imageBytes!);
      final decoded = img.decodeImage(rotatedBytes);

      if (mounted && decoded != null) {
        setState(() {
          _imageBytes = rotatedBytes;
          _imageWidth = decoded.width;
          _imageHeight = decoded.height;
          _isRotating = false;
        });
        _transformationController.value = Matrix4.identity();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isRotating = false;
        });
      }
    }
  }

  Future<void> _cropAndSave(double cropBoxSize, double canvasWidth, double canvasHeight) async {
    if (_imageBytes == null || _imageWidth == 0 || _imageHeight == 0) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // 1. Calculate Crop Box bounds in canvas space
      final cropRect = Rect.fromCenter(
        center: Offset(canvasWidth / 2, canvasHeight / 2),
        width: cropBoxSize,
        height: cropBoxSize,
      );

      // 2. Calculate displayed image fitted size inside InteractiveViewer
      final double fitScale = (canvasWidth / _imageWidth < canvasHeight / _imageHeight)
          ? canvasWidth / _imageWidth
          : canvasHeight / _imageHeight;

      final double displayedWidth = _imageWidth * fitScale;
      final double displayedHeight = _imageHeight * fitScale;

      final double displayedLeft = (canvasWidth - displayedWidth) / 2;
      final double displayedTop = (canvasHeight - displayedHeight) / 2;

      // 3. Extract matrix values
      final Matrix4 matrix = _transformationController.value;
      final double userScale = matrix.getMaxScaleOnAxis();
      final double translationX = matrix.storage[12];
      final double translationY = matrix.storage[13];

      // 4. Transform CropRect relative to displayed image position
      final double currentLeft = displayedLeft * userScale + translationX;
      final double currentTop = displayedTop * userScale + translationY;

      final double relativeX = cropRect.left - currentLeft;
      final double relativeY = cropRect.top - currentTop;
      final double totalScaledWidth = displayedWidth * userScale;
      final double totalScaledHeight = displayedHeight * userScale;

      // 5. Calculate Ratios relative to total image dimensions
      final double cropXRatio = relativeX / totalScaledWidth;
      final double cropYRatio = relativeY / totalScaledHeight;
      final double cropWRatio = cropBoxSize / totalScaledWidth;
      final double cropHRatio = cropBoxSize / totalScaledHeight;

      // 6. Execute cropping in Isolate
      final params = CropParams(
        rawBytes: _imageBytes!,
        cropXRatio: cropXRatio,
        cropYRatio: cropYRatio,
        cropWRatio: cropWRatio,
        cropHRatio: cropHRatio,
      );

      final croppedBytes = await compute(_isolateCropImage, params);

      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/cropped_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(targetPath).writeAsBytes(croppedBytes);

      if (mounted) {
        Navigator.of(context).pop(targetPath);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memotong foto: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              color: AppColors.textPrimary,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Potong Foto Profil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Canvas Workspace
            Expanded(
              child: _imageBytes == null || _isRotating
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final canvasWidth = constraints.maxWidth;
                        final canvasHeight = constraints.maxHeight;
                        final cropBoxSize = canvasWidth * 0.85;

                        return Stack(
                          children: [
                            // Interactive Pinch-to-Zoom & Drag Image Canvas (Exact WhatsApp Pattern)
                            Positioned.fill(
                              child: InteractiveViewer(
                                transformationController: _transformationController,
                                minScale: 1.0,
                                maxScale: 4.0,
                                boundaryMargin: EdgeInsets.all(cropBoxSize),
                                child: Center(
                                  child: Image.memory(
                                    _imageBytes!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),

                            // Fixed Center Crop Box Overlay + 3x3 Grid + L-Bracket Corner Handles
                            IgnorePointer(
                              child: CustomPaint(
                                size: Size(canvasWidth, canvasHeight),
                                painter: _WhatsAppCropOverlayPainter(cropBoxSize: cropBoxSize),
                              ),
                            ),

                            if (_isProcessing)
                              Container(
                                color: Colors.black54,
                                child: const Center(
                                  child: CircularProgressIndicator(color: AppColors.primary),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
            ),

            // Bottom Action Bar
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  color: AppColors.textPrimary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left: Batal
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // Center: Rotate Button
                      IconButton(
                        icon: const Icon(
                          Icons.rotate_right_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                        tooltip: 'Putar Foto',
                        onPressed: _rotateImageRight,
                      ),

                      // Right: Selesai Button
                      LayoutBuilder(
                        builder: (context, c) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 2,
                            ),
                            onPressed: _isProcessing
                                ? null
                                : () {
                                    final mediaQuery = MediaQuery.of(context);
                                    final canvasW = mediaQuery.size.width;
                                    final canvasH = mediaQuery.size.height - 56 - 64 - mediaQuery.padding.top - mediaQuery.padding.bottom;
                                    final cropBoxSize = canvasW * 0.85;

                                    _cropAndSave(cropBoxSize, canvasW, canvasH);
                                  },
                            child: const Text(
                              'Selesai',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Overlay Painter drawing dark backdrop mask, centered fixed crop frame, 3x3 grid, and bold white corner handles
class _WhatsAppCropOverlayPainter extends CustomPainter {
  final double cropBoxSize;

  _WhatsAppCropOverlayPainter({required this.cropBoxSize});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final cropRect = Rect.fromCenter(center: center, width: cropBoxSize, height: cropBoxSize);

    // 1. Dark Backdrop Mask Outside Crop Rect
    final maskPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(cropRect);
    maskPath.fillType = PathFillType.evenOdd;

    final maskPaint = Paint()
      ..color = AppColors.textPrimary.withOpacity(0.75)
      ..style = PaintingStyle.fill;
    canvas.drawPath(maskPath, maskPaint);

    // 2. 3x3 Thin Rule-of-Thirds Grid Lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.45)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final step = cropBoxSize / 3;

    // Vertical Grid Lines
    canvas.drawLine(Offset(cropRect.left + step, cropRect.top), Offset(cropRect.left + step, cropRect.bottom), gridPaint);
    canvas.drawLine(Offset(cropRect.left + step * 2, cropRect.top), Offset(cropRect.left + step * 2, cropRect.bottom), gridPaint);

    // Horizontal Grid Lines
    canvas.drawLine(Offset(cropRect.left, cropRect.top + step), Offset(cropRect.right, cropRect.top + step), gridPaint);
    canvas.drawLine(Offset(cropRect.left, cropRect.top + step * 2), Offset(cropRect.right, cropRect.top + step * 2), gridPaint);

    // 3. Thin Crop Rect Border
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(cropRect, borderPaint);

    // 4. Bold White L-Bracket Corners & Side Ticks (Exact WhatsApp Aesthetic)
    final handlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    const arm = 22.0;
    const tickLen = 16.0;

    // Top-Left Corner
    canvas.drawLine(cropRect.topLeft, cropRect.topLeft + const Offset(arm, 0), handlePaint);
    canvas.drawLine(cropRect.topLeft, cropRect.topLeft + const Offset(0, arm), handlePaint);

    // Top-Right Corner
    canvas.drawLine(cropRect.topRight, cropRect.topRight - const Offset(arm, 0), handlePaint);
    canvas.drawLine(cropRect.topRight, cropRect.topRight + const Offset(0, arm), handlePaint);

    // Bottom-Left Corner
    canvas.drawLine(cropRect.bottomLeft, cropRect.bottomLeft + const Offset(arm, 0), handlePaint);
    canvas.drawLine(cropRect.bottomLeft, cropRect.bottomLeft - const Offset(0, arm), handlePaint);

    // Bottom-Right Corner
    canvas.drawLine(cropRect.bottomRight, cropRect.bottomRight - const Offset(arm, 0), handlePaint);
    canvas.drawLine(cropRect.bottomRight, cropRect.bottomRight - const Offset(0, arm), handlePaint);

    // Mid Edge Ticks
    canvas.drawLine(Offset(center.dx - tickLen / 2, cropRect.top), Offset(center.dx + tickLen / 2, cropRect.top), handlePaint);
    canvas.drawLine(Offset(center.dx - tickLen / 2, cropRect.bottom), Offset(center.dx + tickLen / 2, cropRect.bottom), handlePaint);
    canvas.drawLine(Offset(cropRect.left, center.dy - tickLen / 2), Offset(cropRect.left, center.dy + tickLen / 2), handlePaint);
    canvas.drawLine(Offset(cropRect.right, center.dy - tickLen / 2), Offset(cropRect.right, center.dy + tickLen / 2), handlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
