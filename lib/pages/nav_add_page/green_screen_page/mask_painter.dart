import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class MaskPainter extends CustomPainter {
  final ui.Image maskImage;
  
  MaskPainter(this.maskImage);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    
    // Draw the mask image (scaling to fit the canvas)
    canvas.drawImageRect(
      maskImage,
      Rect.fromLTWH(0, 0, maskImage.width.toDouble(), maskImage.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );
    
    // Restore
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MaskPainter oldDelegate) {
    return oldDelegate.maskImage != maskImage;
  }
}
