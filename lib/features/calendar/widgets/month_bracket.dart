import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Displays the month name inside a bracket along the right side of the
/// calendar view.
class MonthBracket extends StatelessWidget {
  final String monthName;
  final Color color;
  final double width;

  const MonthBracket({
    Key? key,
    required this.monthName,
    this.color = Colors.blueGrey,
    this.width = 48,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BracketPainter(color: color),
      child: SizedBox(
        width: width,
        child: Center(
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(
              monthName,
              textAlign: TextAlign.center,
              style: GoogleFonts.comicNeue(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  final Color color;
  const _BracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // simple rectangular bracket opening to the left
    final double hBar = size.width * 0.6;
    final double x = size.width - hBar;
    canvas.drawLine(Offset(size.width, 0), Offset(x, 0), paint);
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    canvas.drawLine(Offset(x, size.height), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
