import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Dashboard extends StatefulWidget {
  final String baseUrl;
  final Map<String, dynamic> userData; // Added parameter to receive user data

  const Dashboard({
    super.key,
    required this.baseUrl,
    required this.userData, // Required parameter for user data
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // Dashboard data
  List<FlSpot> _lineSpots = [];
  int _wordsMastered = 0;
  int _userLevel = 1;
  double _accuracyScore = 0.0;
  int _streakDays = 0;
  bool _isLoading = true;
  String _error = "";

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = "";
    });

    try {
      // Get the email from userData to identify the user
      final String userEmail = widget.userData['email'];

      final response = await http.get(
        Uri.parse('${widget.baseUrl}/dashboard?email=$userEmail'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Convert weekly trend data to FlSpot
        final List trendsData = data['weekly_trend'];
        List<FlSpot> spots = [];
        for (int i = 0; i < trendsData.length; i++) {
          double accuracy = trendsData[i]['average_accuracy'].toDouble();
          spots.add(FlSpot(i.toDouble(), accuracy));
        }

        setState(() {
          _accuracyScore = data['accuracy']['average_accuracy'].toDouble();
          _wordsMastered = data['words_mastered']['count'];
          _userLevel = data['level']['current_level'];
          _streakDays = data['streak']['current_streak'];
          _lineSpots = spots;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Error: Server returned status code ${response.statusCode}";
          _isLoading = false;
        });
        print("Server error: ${response.body}");
      }
    } catch (e) {
      setState(() {
        _error = "Error: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final borderRadius = BorderRadius.circular(screenWidth * 0.02);
    const shadowColor = Color(0xFF8C8C8C);
    const accuracyContainerColor = Color(0xFFFFB000); // Yellow
    const textColor = Color(0xFF3A435F); // Dark blue-gray
    const chartLineColor = Color(0xFF3A435F); // Dark blue-gray
    const graphFillColor = Color(0xFF3A435F); // Color under the graph

    final defaultPadding = screenWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dashboard - ${widget.userData['name']}", // Show user name in the title
          style: const TextStyle(fontSize: 27, fontFamily: "Fredoka One"),
        ),
        backgroundColor: const Color(0xFF3A435F),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchDashboardData,
          ),
        ],
      ),
      backgroundColor: const Color(0xFF8A9AD6), // Light blue-purple background
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Column(
                    children: [
                      // Weekly Streak Container
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: borderRadius,
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: shadowColor,
                              offset: Offset(2, 2),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        width: double.infinity,
                        padding: EdgeInsets.all(defaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Weekly Streak",
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontFamily: "Fredoka One"),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: _error.isEmpty
                                    ? _streakDays / 7
                                    : 0, // Use 0 when there's an error
                                backgroundColor: Colors.grey.shade300,
                                color: const Color(0xFFFFB000),
                                minHeight: 15,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Accuracy Score and Stats Containers
                      Row(
                        children: [
                          // Accuracy Score Container
                          Expanded(
                            flex: 45,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: borderRadius,
                                color: accuracyContainerColor,
                                boxShadow: const [
                                  BoxShadow(
                                    color: shadowColor,
                                    offset: Offset(2, 2),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              height: screenHeight * 0.2,
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
                                            value: _error.isEmpty
                                                ? _accuracyScore / 100
                                                : 0,
                                            strokeWidth: 10,
                                            backgroundColor: Colors.white,
                                            color: chartLineColor,
                                          ),
                                        ),
                                        Text(
                                          _error.isEmpty
                                              ? "${_accuracyScore.toStringAsFixed(1)}%"
                                              : "N/A",
                                          style: const TextStyle(
                                              color: textColor,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Fredoka "),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      "Accuracy Score",
                                      style: TextStyle(
                                          color: textColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Fredoka"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: screenWidth * 0.03),

                          // Right column containers
                          Expanded(
                            flex: 55,
                            child: Column(
                              children: [
                                // Words Mastered Container
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: borderRadius,
                                    color: Colors.white,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: shadowColor,
                                        offset: Offset(2, 2),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                  height: screenHeight * 0.095,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _error.isEmpty
                                            ? "$_wordsMastered"
                                            : "N/A",
                                        style: const TextStyle(
                                            fontSize: 24,
                                            color: textColor,
                                            fontFamily: "Fredoka One"),
                                      ),
                                      const Text(
                                        "Words Mastered",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Fredoka"),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: screenHeight * 0.01),

                                // Level Container
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: borderRadius,
                                    color: Colors.white,
                                    boxShadow: const [
                                      BoxShadow(
                                        color: shadowColor,
                                        offset: Offset(2, 2),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                  height: screenHeight * 0.095,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _error.isEmpty
                                            ? "Level $_userLevel"
                                            : "Level N/A",
                                        style: const TextStyle(
                                            fontSize: 24,
                                            color: textColor,
                                            fontFamily: "Fredoka One"),
                                      ),
                                      const Text(
                                        "Your Level",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Fredoka"),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Weekly Accuracy Trend Graph
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: borderRadius,
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: shadowColor,
                              offset: Offset(2, 2),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        height: screenHeight * 0.45,
                        width: double.infinity,
                        padding: EdgeInsets.all(defaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Weekly Accuracy Trend",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: textColor,
                                  fontFamily: "Fredoka One"),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Expanded(
                              child: _error.isEmpty && _lineSpots.isNotEmpty
                                  ? LineChart(
                                      LineChartData(
                                        gridData: FlGridData(
                                          show: true,
                                          drawVerticalLine: true,
                                          getDrawingHorizontalLine: (value) {
                                            return FlLine(
                                              color: Colors.grey.shade300,
                                              strokeWidth: 1,
                                              dashArray: [5, 5],
                                            );
                                          },
                                          getDrawingVerticalLine: (value) {
                                            return FlLine(
                                              color: Colors.grey.shade300,
                                              strokeWidth: 1,
                                              dashArray: [5, 5],
                                            );
                                          },
                                        ),
                                        titlesData: FlTitlesData(
                                          leftTitles: AxisTitles(
                                            axisNameWidget: const Padding(
                                              padding:
                                                  EdgeInsets.only(right: 8.0),
                                              child: Text(
                                                "Daily Accuracy (%)",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: "Fredoka"),
                                              ),
                                            ),
                                            axisNameSize: 40,
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 30,
                                              interval: 10,
                                              getTitlesWidget: (value, meta) {
                                                if (value % 10 == 0) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 4.0),
                                                    child: Text(
                                                      '${value.toInt()}%',
                                                      style: const TextStyle(
                                                          fontSize: 10),
                                                    ),
                                                  );
                                                }
                                                return Container();
                                              },
                                            ),
                                          ),
                                          rightTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          topTitles: const AxisTitles(
                                            sideTitles:
                                                SideTitles(showTitles: false),
                                          ),
                                          bottomTitles: AxisTitles(
                                            axisNameWidget: const Text(
                                              "Day",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
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
                                                if (value >= 0 &&
                                                    value < days.length) {
                                                  return Text(
                                                    days[value.toInt()],
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  );
                                                }
                                                return Container();
                                              },
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(
                                          show: true,
                                          border: Border.all(
                                              color: Colors.grey.shade400,
                                              width: 1),
                                        ),
                                        minX: 0,
                                        maxX: 6,
                                        minY: 0,
                                        maxY: 100,
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: _lineSpots,
                                            isCurved: true,
                                            color: chartLineColor,
                                            barWidth: 3,
                                            isStrokeCapRound: true,
                                            belowBarData: BarAreaData(
                                              show: true,
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  graphFillColor
                                                      .withOpacity(0.9),
                                                  graphFillColor
                                                      .withOpacity(0.5),
                                                ],
                                              ),
                                            ),
                                            dotData: FlDotData(
                                              show: true,
                                              getDotPainter: (spot, percent,
                                                  barData, index) {
                                                return FlDotCirclePainter(
                                                  radius: 4,
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                  strokeColor: chartLineColor,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "No data available",
                                            style: TextStyle(
                                                color: textColor,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Fredoka"),
                                          ),
                                          if (_error.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Text(
                                                "Check your connection",
                                                style: TextStyle(
                                                    color: textColor
                                                        .withOpacity(0.7),
                                                    fontSize: 14,
                                                    fontFamily: "Fredoka"),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),

                      // User Email Info
                      SizedBox(height: screenHeight * 0.02),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: borderRadius,
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: shadowColor,
                              offset: Offset(2, 2),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        width: double.infinity,
                        padding: EdgeInsets.all(defaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Account Information",
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontFamily: "Fredoka One"),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Email: ${widget.userData['email']}",
                              style: const TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontFamily: "Fredoka"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Error Banner - only show when there's an error
                if (_error.isNotEmpty)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.red.shade100,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.wifi_off, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Connection error: Unable to load data",
                              style: TextStyle(
                                  color: Colors.red.shade900,
                                  fontFamily: "Fredoka"),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: fetchDashboardData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade900,
                              foregroundColor: Colors.white,
                              textStyle:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                            ),
                            child: const Text(
                              "Retry",
                              style: TextStyle(fontFamily: "Fredoka"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
