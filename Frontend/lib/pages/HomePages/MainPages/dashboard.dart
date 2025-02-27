import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<FlSpot> get lineSpots => [
        FlSpot(0, 70),
        FlSpot(1, 75),
        FlSpot(2, 80),
        FlSpot(3, 65),
        FlSpot(4, 90),
        FlSpot(5, 85),
        FlSpot(6, 95),
      ];

  String getWeekdayLabel(double value) {
    switch (value.toInt()) {
      case 0:
        return 'Mon';
      case 1:
        return 'Tue';
      case 2:
        return 'Wed';
      case 3:
        return 'Thu';
      case 4:
        return 'Fri';
      case 5:
        return 'Sat';
      case 6:
        return 'Sun';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final borderRadius = BorderRadius.circular(screenWidth * 0.02);
    const shadowColor = Color(0xFF8C8C8C);
    const accuracyContainerColor = Color(0xFFFFB000); // Dark yellow
    const textColor = Color(0xFF3A435F); // Dark blue-gray
    const chartLineColor = Color(0xFF3A435F); // Dark blue-gray
    const graphFillColor = Color(0xFF3A435F); // Color under the graph

    final defaultPadding = screenWidth * 0.02;

    // Sample values (Replace with real data)
    int wordsMastered = 250;
    int userLevel = 5;
    double accuracyScore = 87.5;
    int streakDays = 5;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dashboard",
          style: TextStyle(
              fontFamily: "Fredoka One", fontSize: screenWidth * 0.07),
        ),
        backgroundColor: const Color(0xFF3A435F),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.02),

            // Weekly Streak Container
            Container(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    offset: const Offset(4, 4),
                  ),
                ],
              ),
              height: screenHeight * 0.1,
              width: screenWidth * 0.9,
              padding: EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Weekly Streak",
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: "Fredoka",
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.018),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: streakDays / 7, // Normalize to weekly progress
                      backgroundColor: Colors.grey.shade300,
                      color: const Color(0xFFFFB000),
                      minHeight: 15,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenWidth * 0.05),

            // Containers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Accuracy Score Container
                Container(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    color: accuracyContainerColor,
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  height: screenHeight * 0.213,
                  width: screenWidth * 0.4,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: screenHeight * 0.1,
                              width: screenHeight * 0.1,
                              child: CircularProgressIndicator(
                                value: accuracyScore / 100,
                                strokeWidth: 10,
                                backgroundColor: Colors.white,
                                color: chartLineColor,
                              ),
                            ),
                            Text(
                              "${accuracyScore.toStringAsFixed(1)}%",
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Fredoka "),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Accuracy Score",
                          style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontFamily: "Fredoka",
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                Column(
                  children: [
                    // Words Mastered Container
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: borderRadius,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            offset: const Offset(4, 4),
                          ),
                        ],
                      ),
                      height: screenHeight * 0.1,
                      width: screenWidth * 0.45,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$wordsMastered",
                            style: TextStyle(
                                fontSize: 20,
                                color: textColor,
                                fontFamily: "Fredoka One"),
                          ),
                          Text(
                            "Words Mastered",
                            style: TextStyle(
                                fontSize: 14,
                                color: textColor,
                                fontFamily: "Fredoka",
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenWidth * 0.03),

                    // Level Container
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: borderRadius,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            offset: const Offset(4, 4),
                          ),
                        ],
                      ),
                      height: screenHeight * 0.1,
                      width: screenWidth * 0.45,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Level $userLevel",
                            style: TextStyle(
                                fontSize: 20,
                                color: textColor,
                                fontFamily: "Fredoka One"),
                          ),
                          Text(
                            "Your Level",
                            style: TextStyle(
                                fontSize: 14,
                                color: textColor,
                                fontFamily: "Fredoka",
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),

            SizedBox(height: screenWidth * 0.05),

            // Weekly Accuracy Trend Graph
            Container(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              // Reverted to previous sizes
              height: screenHeight * 0.45,
              width: screenWidth * 0.9,
              padding: EdgeInsets.only(
                left: defaultPadding * 0.5,
                right: defaultPadding * 1.5,
                top: defaultPadding,
                bottom: defaultPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Weekly Accuracy Trend",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontFamily: "Fredoka",
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.shade300,
                              strokeWidth: 1.2,
                              dashArray: [5, 5],
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: Colors.grey.shade300,
                              strokeWidth: 1.2,
                              dashArray: [5, 5],
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            axisNameWidget: Padding(
                              // Add some padding to create a gap between axis name and labels
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Text(
                                "Daily Accuracy (%)",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Fredoka"),
                              ),
                            ),
                            // Increase axisNameSize for extra space
                            axisNameSize: 40,
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize:
                                  30, // Keep labels close, but not too close
                              interval: 10,
                              getTitlesWidget: (value, meta) {
                                if (value % 10 == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: Text(
                                      '${value.toInt()}%',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }
                                return Container();
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
                            axisNameWidget: Text(
                              "Day",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Fredoka"),
                            ),
                            axisNameSize: 20,
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                List<String> days = [
                                  "Mon",
                                  "Tue",
                                  "Wed",
                                  "Thu",
                                  "Fri",
                                  "Sat",
                                  "Sun"
                                ];
                                if (value >= 0 && value < days.length) {
                                  return Text(
                                    days[value.toInt()],
                                    style: const TextStyle(fontSize: 12),
                                  );
                                }
                                return Container();
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border:
                              Border.all(color: Colors.grey.shade400, width: 1),
                        ),
                        minX: 0,
                        maxX: 6,
                        minY: 0,
                        maxY: 100,
                        lineBarsData: [
                          LineChartBarData(
                            spots: lineSpots,
                            isCurved: true,
                            color: chartLineColor,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  graphFillColor.withOpacity(0.9), // Top part
                                  graphFillColor
                                      .withOpacity(0.5), // Bottom part
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
