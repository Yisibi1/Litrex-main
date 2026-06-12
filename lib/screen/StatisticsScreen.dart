import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/colors.dart';
import '../utils/Extensions/Commons.dart';
import '../utils/Extensions/int_extensions.dart';
import '../main.dart';
import '../store/TrackingStore.dart';
import 'ReadingTimerScreen.dart';

class StatisticsScreen extends StatefulWidget {
  static String tag = '/StatisticsScreen';

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final int dailyGoalSeconds = 1800; // 30 minutes default goal
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    trackingStore.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    trackingStore.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  String _formatDuration(int totalSeconds) {
    if (totalSeconds < 60) return "$totalSeconds sn";
    int m = totalSeconds ~/ 60;
    int h = m ~/ 60;
    m = m % 60;
    if (h > 0) return "${h}s ${m}d";
    return "${m} d";
  }

  List<ReadingSession> _getEventsForDay(DateTime day) {
    return trackingStore.sessions.where((session) => 
      isSameDay(session.endTime, day)
    ).toList();
  }

  List<BarChartGroupData> _getWeeklyChartData() {
    List<BarChartGroupData> barGroups = [];
    DateTime now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      DateTime day = now.subtract(Duration(days: i));
      int seconds = trackingStore.sessions
          .where((s) => isSameDay(s.endTime, day))
          .fold(0, (sum, s) => sum + s.durationSeconds);
      
      double minutes = seconds / 60.0;
      
      barGroups.add(
        BarChartGroupData(
          x: 6 - i,
          barRods: [
            BarChartRodData(
              toY: minutes,
              color: primaryColor,
              width: 16,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 60, // Max 60 mins scale
                color: context.dividerColor.withOpacity(0.1),
              ),
            ),
          ],
        ),
      );
    }
    return barGroups;
  }

  @override
  Widget build(BuildContext context) {
    int todaySeconds = trackingStore.getTodayTotalSeconds();
    double progress = (todaySeconds / dailyGoalSeconds).clamp(0.0, 1.0);
    List<ReadingSession> allSessions = trackingStore.sessions.reversed.toList();

    return Scaffold(
      appBar: appBarWidget("İzleyici", color: primaryColor, textColor: Colors.white, showBack: false),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Goal Circular Progress
            Container(
              padding: EdgeInsets.all(24),
              decoration: boxDecorationWithRoundedCornersWidget(
                backgroundColor: context.cardColor,
                borderRadius: radius(16),
                border: Border.all(color: context.dividerColor),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: context.dividerColor.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                        Center(
                          child: Text(
                            "${(progress * 100).toInt()}%",
                            style: boldTextStyle(size: 20, color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),
                  24.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Günlük Hedef (30 dk)", style: secondaryTextStyle()),
                        8.height,
                        Text(_formatDuration(todaySeconds), style: boldTextStyle(size: 28)),
                        4.height,
                        if (progress >= 1.0)
                          Text("Hedefe ulaştınız! 🎉", style: boldTextStyle(color: Colors.orange, size: 14))
                        else
                          Text("Hedefe ulaşmak için: ${_formatDuration(dailyGoalSeconds - todaySeconds)}", style: secondaryTextStyle(size: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            24.height,
            
            // Start Timer Button
            InkWell(
              onTap: () {
                ReadingTimerScreen().launch(context);
              },
              borderRadius: radius(12),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: boxDecorationWithRoundedCornersWidget(
                  backgroundColor: primaryColor,
                  borderRadius: radius(12),
                  boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28),
                    12.width,
                    Text("Fiziksel Kitap Oku (Barkod/Zamanlayıcı)", style: boldTextStyle(color: Colors.white, size: 16)),
                  ],
                ),
              ),
            ),
            
            24.height,

            // Calendar
            Text("Okuma Takvimi", style: boldTextStyle(size: 20)),
            16.height,
            Container(
              decoration: boxDecorationWithRoundedCornersWidget(
                backgroundColor: context.cardColor,
                borderRadius: radius(16),
                border: Border.all(color: context.dividerColor),
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: _getEventsForDay,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(color: primaryColor.withOpacity(0.3), shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                  markerDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),

            24.height,
            
            // Weekly Chart
            Text("Haftalık İstatistik (Dakika)", style: boldTextStyle(size: 20)),
            16.height,
            Container(
              height: 250,
              padding: EdgeInsets.all(24),
              decoration: boxDecorationWithRoundedCornersWidget(
                backgroundColor: context.cardColor,
                borderRadius: radius(16),
                border: Border.all(color: context.dividerColor),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 60,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
                          DateTime date = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(days[date.weekday - 1], style: secondaryTextStyle(size: 12)),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: _getWeeklyChartData(),
                ),
              ),
            ),

            24.height,
            Text("Geçmiş", style: boldTextStyle(size: 20)),
            16.height,
            
            if (allSessions.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text("Henüz hiç kitap okumadınız.", style: secondaryTextStyle()),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: allSessions.length,
                itemBuilder: (context, index) {
                  final session = allSessions[index];
                  final isToday = session.endTime.day == DateTime.now().day && session.endTime.month == DateTime.now().month;
                  
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    decoration: boxDecorationWithRoundedCornersWidget(
                      backgroundColor: context.cardColor,
                      border: Border.all(color: context.dividerColor),
                      borderRadius: radius(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                          child: Icon(Icons.menu_book_rounded, color: Colors.orange),
                        ),
                        16.width,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(session.bookName, style: boldTextStyle()),
                              4.height,
                              Text(
                                isToday ? "Bugün, ${session.endTime.hour}:${session.endTime.minute.toString().padLeft(2, '0')}" 
                                        : "${session.endTime.day}/${session.endTime.month}/${session.endTime.year}",
                                style: secondaryTextStyle(size: 12),
                              ),
                            ],
                          ),
                        ),
                        Text("+${_formatDuration(session.durationSeconds)}", style: boldTextStyle(color: Colors.green)),
                      ],
                    ),
                  );
                },
              ),
              
            30.height,
          ],
        ),
      ),
    );
  }
}
