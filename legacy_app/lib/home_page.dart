import 'package:estrus_detector/services/api_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'models/history_model.dart';

class MyHomePage extends StatefulWidget {
  final String token;
  const MyHomePage({super.key, required this.token});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 1;
  String formattedDate = DateFormat('yyyy-MM-dd')
      .format(DateTime.now().toUtc().add(Duration(hours: 9)));
  late Future<List<HistoryModel>> histories =
      ApiService.getHistories(widget.token, formattedDate);

  double count(int x, String type, AsyncSnapshot<List<HistoryModel>> snapshot) {
    double cnt = 0;
    if (type == 'district') {
      for (var history in snapshot.data!) {
        if (history.location == x + 1) {
          //location(district) is from 1 to 6
          cnt += 1.0;
        }
      }
      return cnt;
    }
    if (type == 'time') {
      for (var history in snapshot.data!) {
        if (DateTime.parse(history.time).hour == x) {
          cnt += 1.0;
        }
      }
      return cnt;
    }
    return -1.0;
  }

  Widget getDistrictTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '1구획';
        break;
      case 1:
        text = '2구획';
        break;
      case 2:
        text = '3구획';
        break;
      case 3:
        text = '4구획';
        break;
      case 4:
        text = '5구획';
        break;
      case 5:
        text = '6구획';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }

  Widget getTimeTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '00';
        break;
      case 1:
        text = '01';
        break;
      case 2:
        text = '02';
        break;
      case 3:
        text = '03';
        break;
      case 4:
        text = '04';
        break;
      case 5:
        text = '05';
        break;
      case 6:
        text = '06';
        break;
      case 7:
        text = '07';
        break;
      case 8:
        text = '08';
        break;
      case 9:
        text = '09';
        break;
      case 10:
        text = '10';
        break;
      case 11:
        text = '11';
        break;
      case 12:
        text = '12';
        break;
      case 13:
        text = '13';
        break;
      case 14:
        text = '14';
        break;
      case 15:
        text = '15';
        break;
      case 16:
        text = '16';
        break;
      case 17:
        text = '17';
        break;
      case 18:
        text = '18';
        break;
      case 19:
        text = '19';
        break;
      case 20:
        text = '20';
        break;
      case 21:
        text = '21';
        break;
      case 22:
        text = '22';
        break;
      case 23:
        text = '23';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }

  int touchedGroupIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: Icon(
          Icons.account_circle,
          color: Colors.white,
        ),
        title: Text(
          "홍길동",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_alert_outlined,
              color: Colors.white,
            ),
            onPressed: () => context.push('/alarm', extra: widget.token),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder(
            future: histories,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  color: Color(0xffd6d6d6),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('구획별 일일 현황',
                                  style: TextStyle(fontSize: 20)),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.all(20),
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      minY: 0,
                                      maxY: 10,
                                      titlesData: FlTitlesData(
                                        leftTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 30,
                                            getTitlesWidget: getDistrictTitles,
                                          ),
                                        ),
                                        topTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                        rightTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                      ),
                                      barGroups: [
                                        for (int i = 0; i < 6; i++)
                                          BarChartGroupData(
                                            x: i,
                                            barRods: [
                                              BarChartRodData(
                                                toY: count(
                                                    i, 'district', snapshot),
                                              ),
                                            ],
                                            showingTooltipIndicators: (count(i,
                                                        'district', snapshot) >
                                                    0)
                                                ? [0]
                                                : [],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('시간별 일일 현황',
                                  style: TextStyle(fontSize: 20)),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(20),
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      minY: 0,
                                      maxY: 10,
                                      titlesData: FlTitlesData(
                                        leftTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 30,
                                            getTitlesWidget: getTimeTitles,
                                          ),
                                        ),
                                        topTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                        rightTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false),
                                        ),
                                      ),
                                      barGroups: [
                                        for (int i = 0; i < 24; i++)
                                          BarChartGroupData(
                                            x: i,
                                            barRods: [
                                              BarChartRodData(
                                                toY: count(i, 'time', snapshot),
                                              ),
                                            ],
                                            showingTooltipIndicators:
                                                touchedGroupIndex == i
                                                    ? [0]
                                                    : [],
                                          )
                                      ],
                                      barTouchData: BarTouchData(
                                        enabled: true,
                                        handleBuiltInTouches: false,
                                        touchTooltipData: BarTouchTooltipData(
                                          getTooltipItem: (
                                            BarChartGroupData group,
                                            int groupIndex,
                                            BarChartRodData rod,
                                            int rodIndex,
                                          ) {
                                            return BarTooltipItem(
                                              rod.toY.toString(),
                                              TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: rod.color,
                                                fontSize: 18,
                                              ),
                                            );
                                          },
                                        ),
                                        touchCallback: (event, response) {
                                          if (event
                                                  .isInterestedForInteractions &&
                                              response != null &&
                                              response.spot != null) {
                                            setState(() {
                                              touchedGroupIndex = response
                                                  .spot!.touchedBarGroupIndex;
                                            });
                                          } else {
                                            setState(() {
                                              touchedGroupIndex = -1;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
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
              return Container(
                color: Color(0xffd6d6d6),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('구획별 일일 현황',
                                style: TextStyle(fontSize: 20)),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.all(20),
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    minY: 0,
                                    maxY: 10,
                                    titlesData: FlTitlesData(
                                      leftTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          getTitlesWidget: getDistrictTitles,
                                        ),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      rightTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                    ),
                                    barGroups: [
                                      for (int i = 0; i < 6; i++)
                                        BarChartGroupData(
                                          x: i,
                                          barRods: [
                                            BarChartRodData(
                                              toY: 0,
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('시간별 일일 현황',
                                style: TextStyle(fontSize: 20)),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.all(20),
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    minY: 0,
                                    maxY: 10,
                                    titlesData: FlTitlesData(
                                      leftTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          getTitlesWidget: getTimeTitles,
                                        ),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      rightTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                    ),
                                    barGroups: [
                                      for (int i = 0; i < 24; i++)
                                        BarChartGroupData(
                                          x: i,
                                          barRods: [
                                            BarChartRodData(
                                              toY: 0,
                                            ),
                                          ],
                                          showingTooltipIndicators:
                                              touchedGroupIndex == i ? [0] : [],
                                        )
                                    ],
                                    barTouchData: BarTouchData(
                                      enabled: true,
                                      handleBuiltInTouches: false,
                                      touchTooltipData: BarTouchTooltipData(
                                        getTooltipItem: (
                                          BarChartGroupData group,
                                          int groupIndex,
                                          BarChartRodData rod,
                                          int rodIndex,
                                        ) {
                                          return BarTooltipItem(
                                            rod.toY.toString(),
                                            TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: rod.color,
                                              fontSize: 18,
                                            ),
                                          );
                                        },
                                      ),
                                      touchCallback: (event, response) {
                                        if (event.isInterestedForInteractions &&
                                            response != null &&
                                            response.spot != null) {
                                          setState(() {
                                            touchedGroupIndex = response
                                                .spot!.touchedBarGroupIndex;
                                          });
                                        } else {
                                          setState(() {
                                            touchedGroupIndex = -1;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            label: '이력',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: '통계',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/history', extra: widget.token);
            case 1:
              setState(() {
                histories =
                    ApiService.getHistories(widget.token, formattedDate);
              });
            case 2:
              context.go('/statistics', extra: widget.token);
          }
        },
      ),
    );
  }
}
