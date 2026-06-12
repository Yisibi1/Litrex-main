import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../utils/Extensions/Widget_extensions.dart';
import '../utils/Extensions/context_extensions.dart';
import '../utils/Extensions/decorations.dart';
import '../utils/Extensions/int_extensions.dart';
import '../utils/Extensions/text_styles.dart';
import '../utils/Extensions/Colors.dart';
import '../utils/colors.dart';
import '../utils/Extensions/Commons.dart';
import '../component/StreakBalanceComponent.dart';
import '../main.dart';

class StreakDetailScreen extends StatefulWidget {
  @override
  _StreakDetailScreenState createState() => _StreakDetailScreenState();
}

class _StreakDetailScreenState extends State<StreakDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut)
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildHero(int streak) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 200,
            height: 200,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: streak > 0 ? [Colors.orange, Colors.deepOrange] : [Colors.grey.shade400, Colors.grey.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: streak > 0 ? Colors.deepOrange.withOpacity(0.4) : Colors.transparent,
                  blurRadius: 30,
                  spreadRadius: 10,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_fire_department_rounded, size: 80, color: Colors.white),
                8.height,
                Text(
                  "$streak",
                  style: boldTextStyle(size: 48, color: Colors.white, letterSpacing: 2),
                ),
                Text(
                  language.lblDay,
                  style: primaryTextStyle(size: 16, color: Colors.white70),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildWeekCalendar(int streak) {
    List<String> days = [language.lblMon, language.lblTue, language.lblWed, language.lblThu, language.lblFri, language.lblSat, language.lblSun];
    int currentWeekday = DateTime.now().weekday; // 1 = Mon, 7 = Sun
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: boxDecorationWithRoundedCornersWidget(
        backgroundColor: context.cardColor,
        borderRadius: radius(20),
        border: Border.all(color: primaryColor.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(language.lblThisWeek, style: boldTextStyle(size: 18)),
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              int dayOfWeek = index + 1; // 1 to 7
              bool isToday = dayOfWeek == currentWeekday;
              
              // Calculate if this day should be lit up based on streak
              bool isPastOrToday = dayOfWeek <= currentWeekday;
              int daysAgo = currentWeekday - dayOfWeek;
              bool isActive = isPastOrToday && (daysAgo < streak);

              return Column(
                children: [
                  Text(days[index], style: secondaryTextStyle(size: 12, color: isToday ? primaryColor : null)),
                  8.height,
                  Container(
                    width: 35,
                    height: 45,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.orange : (isToday ? primaryColor.withOpacity(0.1) : context.dividerColor.withOpacity(0.1)),
                      borderRadius: radius(12),
                      border: isToday && !isActive ? Border.all(color: primaryColor) : null,
                      boxShadow: isActive ? [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 8)] : null,
                    ),
                    child: Center(
                      child: isActive 
                          ? Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 20)
                          : (isToday ? Icon(Icons.circle, color: primaryColor, size: 10) : SizedBox()),
                    ),
                  ),
                ],
              );
            }),
          )
        ],
      ),
    );
  }

  Widget _buildAchievementItem(String title, int target, int currentStreak, String reward) {
    bool isCompleted = currentStreak >= target;
    double progress = currentStreak / target;
    if (progress > 1.0) progress = 1.0;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCornersWidget(
        backgroundColor: context.cardColor,
        borderRadius: radius(16),
        border: Border.all(color: isCompleted ? Colors.orange.withOpacity(0.5) : context.dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.orange.withOpacity(0.1) : context.dividerColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.emoji_events : Icons.lock_outline,
              color: isCompleted ? Colors.orange : textSecondaryColor,
              size: 28,
            ),
          ),
          16.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: boldTextStyle(size: 16)),
                    Text(isCompleted ? language.lblCompleted : "$currentStreak / $target", style: boldTextStyle(size: 12, color: isCompleted ? Colors.green : textSecondaryColor)),
                  ],
                ),
                8.height,
                Stack(
                  children: [
                    Container(height: 8, width: double.infinity, decoration: BoxDecoration(color: context.dividerColor.withOpacity(0.2), borderRadius: radius(10))),
                    AnimatedContainer(
                      duration: Duration(seconds: 1),
                      height: 8,
                      width: MediaQuery.of(context).size.width * 0.6 * progress, // approximate
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrange]),
                        borderRadius: radius(10),
                        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 4)]
                      ),
                    ),
                  ],
                ),
                8.height,
                Text("${language.lblReward}: $reward", style: secondaryTextStyle(size: 12, color: primaryColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsPanel(int streak) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(language.lblAchievements, style: boldTextStyle(size: 18)),
          16.height,
          _buildAchievementItem("3 ${language.lblDayStreak}", 3, streak, "15 ${language.lblCoinsReward}"),
          _buildAchievementItem("7 ${language.lblDayStreak}", 7, streak, "50 ${language.lblCoinsReward}"),
          _buildAchievementItem("30 ${language.lblDayStreak}", 30, streak, "300 ${language.lblCoinsReward}"),
          _buildAchievementItem("100 ${language.lblDayStreak}", 100, streak, "1000 ${language.lblCoinsReward}"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language.lblStreakDetails,
        color: context.scaffoldBackgroundColor,
        textColor: context.iconColor,
        showBack: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: context.iconColor),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(borderRadius: radius(16)),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.all(24),
                      decoration: boxDecorationWithRoundedCornersWidget(
                        backgroundColor: context.cardColor,
                        borderRadius: radius(16),
                        border: Border.all(color: Colors.orange.withOpacity(0.5)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_fire_department_rounded, size: 48, color: Colors.orange),
                          16.height,
                          Text(language.lblStreakInfoTitle, style: boldTextStyle(size: 20)),
                          16.height,
                          Text(
                            language.lblStreakInfoMsg,
                            style: secondaryTextStyle(size: 14),
                            textAlign: TextAlign.center,
                          ),
                          24.height,
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(borderRadius: radius(10)),
                              minimumSize: Size(double.infinity, 45)
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(language.lblClose, style: boldTextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                    ),
                  );
                }
              );
            },
          )
        ],
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: currentStreakNotifier,
        builder: (context, streak, child) {
          return SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                30.height,
                _buildHero(streak),
                30.height,
                _buildWeekCalendar(streak),
                30.height,
                _buildAchievementsPanel(streak),
                30.height,
              ],
            ),
          );
        }
      ),
    );
  }
}
