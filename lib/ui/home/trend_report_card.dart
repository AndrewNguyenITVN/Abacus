import 'package:flutter/material.dart';
import 'home_helpers.dart';

/// Card báo cáo xu hướng với biểu đồ đường
class TrendReportCard extends StatelessWidget {
  final double totalExpense;
  final double totalIncome;

  const TrendReportCard({
    super.key,
    required this.totalExpense,
    required this.totalIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Báo cáo xu hướng',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Xem báo cáo',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tổng đã chi',
                    style: TextStyle(color: Colors.black54, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatCurrency(totalExpense),
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tổng thu',
                    style: TextStyle(color: Colors.black54, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatCurrency(totalIncome),
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Line Chart Area
          SizedBox(
            height: 120,
            child: Stack(
              children: [
                // Grid lines
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildGridLine('900 K'),
                    _buildGridLine('600 K'),
                    _buildGridLine('300 K'),
                    _buildGridLine('0'),
                  ],
                ),
                // Chart
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 40,
                  top: 10,
                  child: CustomPaint(painter: TrendChartPainter(totalExpense)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Date labels
          const Padding(
            padding: EdgeInsets.only(left: 10, right: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '01/10',
                  style: TextStyle(color: Colors.black54, fontSize: 10),
                ),
                Text(
                  '31/10',
                  style: TextStyle(color: Colors.black54, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridLine(String label) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black.withOpacity(0.1), width: 1),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 10),
        ),
      ],
    );
  }
}

/// Custom painter cho biểu đồ xu hướng
class TrendChartPainter extends CustomPainter {
  final double totalExpense;

  TrendChartPainter(this.totalExpense);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.red.shade300.withOpacity(0.3),
          Colors.red.shade100.withOpacity(0.1),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Create chart path
    final path = Path();
    final fillPath = Path();

    // Simulated data points
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.3, size.height * 0.6),
      Offset(size.width * 0.6, size.height * 0.3),
      Offset(size.width, size.height * 0.1),
    ];

    // Line path
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Fill path
    fillPath.moveTo(points[0].dx, size.height);
    fillPath.lineTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      fillPath.lineTo(points[i].dx, points[i].dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw fill and line
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = Colors.red.shade600
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final point in points) {
      canvas.drawCircle(point, 5, pointBorderPaint);
      canvas.drawCircle(point, 3, pointPaint);
    }

    // Draw selected point (last one) - larger
    canvas.drawCircle(points.last, 6, pointBorderPaint);
    canvas.drawCircle(points.last, 4, pointPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

