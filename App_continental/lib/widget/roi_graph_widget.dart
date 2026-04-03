import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/property_roi_data.dart';

class ROIGraphWidget extends StatelessWidget {
  final String? locality;

  const ROIGraphWidget({
    super.key,
    required this.locality,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('📈 [ROI] Checking graph for locality: $locality');
    if (locality == null) {
      debugPrint('📈 [ROI] Missing data - locality: $locality');
      return const SizedBox(); // Return empty if no locality
    }

    final roiData = PropertyROIData.getROIDataForLocality(locality!);
    if (roiData == null || roiData.isEmpty) {
      debugPrint('📈 [ROI] No ROI data found for locality: $locality');
      return const SizedBox(); // Return empty if no data
    }
    debugPrint('📈 [ROI] Found ${roiData.length} ROI data points');

    // currentROI available if needed for future display
    // final currentROI = PropertyROIData.getCurrentROIForLocality(locality!);

    // Filter for years 1, 3, and 5 (indices 0, 2, 4)
    final List<int> desiredYearsIndices = [0, 2, 4];
    final filteredData = roiData.asMap().entries
        .where((entry) => desiredYearsIndices.contains(entry.key))
        .map((entry) => entry.value)
        .toList();

    if (filteredData.isEmpty) {
      debugPrint('📈 [ROI] No data points for years 1, 3, 5 for locality: $locality');
      return const SizedBox();
    }

    // Use Year 5 ROI for the big text (last of filtered data)
    final year5ROI = filteredData[2].roi;

    // Prepare data for chart - map to Year 1, 3, 5
    final spots = [
      FlSpot(1.0, filteredData[0].roi), // Year 1
      FlSpot(3.0, filteredData[1].roi), // Year 3
      FlSpot(5.0, filteredData[2].roi), // Year 5
    ];

    // Find min and max ROI for better scaling from filtered data
    final minROI = filteredData.map((e) => e.roi).reduce((a, b) => a < b ? a : b);
    final maxROI = filteredData.map((e) => e.roi).reduce((a, b) => a > b ? a : b);
    final padding = (maxROI - minROI) * 0.1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ROI',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '${year5ROI.toStringAsFixed(0)}%',
                style: GoogleFonts.inter(
                  color: Colors.greenAccent,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.trending_up,
                color: Colors.greenAccent,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxROI - minROI + padding * 2) / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[800]!,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: (maxROI - minROI + padding * 2) / 4,
                      getTitlesWidget: (value, meta) {
                        // Hide the first label to prevent overlap with X-axis
                        if (value == meta.min) {
                          return const Text('');
                        }
                        return Text(
                          value.toStringAsFixed(0),
                          style: GoogleFonts.inter(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        // Only show labels for years 1, 3, 5
                        if (value == 1 || value == 3 || value == 5) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: GoogleFonts.inter(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: Colors.grey[700]!),
                    bottom: BorderSide(color: Colors.grey[700]!),
                  ),
                ),
                minX: 0,
                maxX: 6,
                minY: minROI - padding,
                maxY: maxROI + padding,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.greenAccent,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.greenAccent,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.greenAccent.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Year',
                style: GoogleFonts.inter(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

