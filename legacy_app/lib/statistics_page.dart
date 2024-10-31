import 'package:estrus_detector/models/history_model.dart';
import 'package:estrus_detector/services/api_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MyStatisticsPage extends StatefulWidget {
  final String token;
  const MyStatisticsPage({super.key, required this.token});

  @override
  State<MyStatisticsPage> createState() => _MyStatisticsPageState();
}

class _MyStatisticsPageState extends State<MyStatisticsPage> {
  int selectedIndex = 1;
  DateTime selectedStartDate = DateTime.now().toUtc().add(Duration(hours: 9));
  DateTime selectedEndDate = DateTime.now().toUtc().add(Duration(hours: 9));
  late Future<List<HistoryModel>> histories = ApiService.getAllHistoriesBetween(
      widget.token, getAllDatesBetween(selectedStartDate, selectedEndDate));

  List<String> getAllDatesBetween(DateTime start, DateTime end) {
    List<String> dates = [];

    for (DateTime date = start;
        date.isBefore(end) || date.isAtSameMomentAs(end);
        date = date.add(Duration(days: 1))) {
      dates.add(DateFormat('yyyy-MM-dd').format(date));
    }

    return dates;
  }

  void showPopUp(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  msg,
                  style: TextStyle(fontSize: 17),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton(
                    onPressed: () {
                      context.pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  double count(var x, String type, AsyncSnapshot<List<HistoryModel>> snapshot) {
    double cnt = 0;
    if (type == 'district') {
      for (var history in snapshot.data!) {
        if (history.location == x + 1) {
          //location(district) is from 1 to 6
          cnt += 1.0;
        }
      }
      if (snapshot.data!.length == 0) {
        return 1000;
      } else {
        return cnt / snapshot.data!.length * 100;
      }
    }
    if (type == 'time') {
      int startHour = x[0];
      int endHour = x[1];
      for (var history in snapshot.data!) {
        int hour = DateTime.parse(history.time).hour;
        if (hour >= startHour && hour < endHour) {
          cnt += 1.0;
        }
      }
      return cnt;
    }
    return -1.0;
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0-4';
        break;
      case 1:
        text = '4-8';
        break;
      case 2:
        text = '8-12';
        break;
      case 3:
        text = '12-16';
        break;
      case 4:
        text = '16-20';
        break;
      case 5:
        text = '20-24';
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

  List<PieChartSectionData> showingSections(
      AsyncSnapshot<List<HistoryModel>> snapshot) {
    List<PieChartSectionData> lst = [];
    const fontSize = 16.0;
    const radius = 100.0;
    List<Color> color = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple
    ];

    for (int i = 0; i < 6; i++) {
      double percent = count(i, 'district', snapshot);
      if (percent == 1000) {
        continue;
      }
      lst.add(PieChartSectionData(
        color: color[i],
        value: percent,
        title: '$percent%',
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
        badgeWidget: Text(
          "${i + 1}구획",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        badgePositionPercentageOffset: .95,
      ));
    }

    if (lst.length == 0) {
      lst.add(PieChartSectionData(
        color: Colors.grey,
        value: 100,
        title: '0%',
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        badgeWidget: Text(
          "모든 구획",
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        titlePositionPercentageOffset: -0.6,
        badgePositionPercentageOffset: .25,
      ));
    }

    return lst;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: const Icon(
          Icons.account_circle,
          color: Colors.white,
        ),
        title: const Text(
          "홍길동",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
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
                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Row(
                                  children: [
                                    Text(
                                      "시작일 ${DateFormat('yyyy/MM/dd').format(selectedStartDate)}",
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        final selectedDate =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now()
                                              .toUtc()
                                              .add(Duration(hours: 9)),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime.now()
                                              .toUtc()
                                              .add(Duration(hours: 9)),
                                        );
                                        if (selectedDate != null) {
                                          selectedDate.isAfter(selectedEndDate)
                                              ? showPopUp(context,
                                                  "종료일보다 더 앞선 날짜를\n시작일로 선택해주세요.")
                                              : setState(() {
                                                  selectedStartDate =
                                                      selectedDate;
                                                  histories = ApiService
                                                      .getAllHistoriesBetween(
                                                          widget.token,
                                                          getAllDatesBetween(
                                                              selectedStartDate,
                                                              selectedEndDate));
                                                });
                                        }
                                      },
                                      icon: const Icon(Icons.calendar_month),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: Row(
                                  children: [
                                    Text(
                                      "종료일 ${DateFormat('yyyy/MM/dd').format(selectedEndDate)}",
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        final selectedDate =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now()
                                              .toUtc()
                                              .add(Duration(hours: 9)),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime.now()
                                              .toUtc()
                                              .add(Duration(hours: 9)),
                                        );
                                        if (selectedDate != null) {
                                          selectedDate
                                                  .isBefore(selectedStartDate)
                                              ? showPopUp(context,
                                                  "시작일보다 더 늦은 날짜를\n종료일로 선택해주세요.")
                                              : setState(() {
                                                  selectedEndDate =
                                                      selectedDate;
                                                  histories = ApiService
                                                      .getAllHistoriesBetween(
                                                          widget.token,
                                                          getAllDatesBetween(
                                                              selectedStartDate,
                                                              selectedEndDate));
                                                });
                                        }
                                      },
                                      icon: const Icon(Icons.calendar_month),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 20, 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Center(
                                child: Text('시간별 발정 감지 히스토그램',
                                    style: TextStyle(fontSize: 20)),
                              ),
                              Expanded(
                                child: Container(
                                  child: BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      minY: 0,
                                      maxY: 10,
                                      titlesData: FlTitlesData(
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 30,
                                            getTitlesWidget: getTitles,
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
                                                toY: count([i * 4, (i + 1) * 4],
                                                    'time', snapshot),
                                              ),
                                            ],
                                            showingTooltipIndicators: (count(
                                                        [i * 4, (i + 1) * 4],
                                                        'time',
                                                        snapshot) >
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
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('구획별 발정 감지 그래프',
                                style: TextStyle(fontSize: 20)),
                            Expanded(
                              child: PieChart(
                                PieChartData(
                                  borderData: FlBorderData(
                                    show: false,
                                  ),
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 0,
                                  sections: showingSections(snapshot),
                                ),
                              ),
                            ),
                          ],
                        )),
                      ),
                    ],
                  ),
                );
              }
              return Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Row(
                                children: [
                                  Text(
                                    "시작일 ${DateFormat('yyyy/MM/dd').format(selectedStartDate)}",
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      final selectedDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now()
                                            .toUtc()
                                            .add(Duration(hours: 9)),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime.now()
                                            .toUtc()
                                            .add(Duration(hours: 9)),
                                      );
                                      if (selectedDate != null) {
                                        selectedDate.isAfter(selectedEndDate)
                                            ? showPopUp(context,
                                                "종료일보다 더 앞선 날짜를\n시작일로 선택해주세요.")
                                            : setState(() {
                                                selectedStartDate =
                                                    selectedDate;
                                                histories = ApiService
                                                    .getAllHistoriesBetween(
                                                        widget.token,
                                                        getAllDatesBetween(
                                                            selectedStartDate,
                                                            selectedEndDate));
                                              });
                                      }
                                    },
                                    icon: const Icon(Icons.calendar_month),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Row(
                                children: [
                                  Text(
                                    "종료일 ${DateFormat('yyyy/MM/dd').format(selectedEndDate)}",
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      final selectedDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now()
                                            .toUtc()
                                            .add(Duration(hours: 9)),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime.now()
                                            .toUtc()
                                            .add(Duration(hours: 9)),
                                      );
                                      if (selectedDate != null) {
                                        selectedDate.isBefore(selectedStartDate)
                                            ? showPopUp(context,
                                                "시작일보다 더 늦은 날짜를\n종료일로 선택해주세요.")
                                            : setState(() {
                                                selectedEndDate = selectedDate;
                                                histories = ApiService
                                                    .getAllHistoriesBetween(
                                                        widget.token,
                                                        getAllDatesBetween(
                                                            selectedStartDate,
                                                            selectedEndDate));
                                              });
                                      }
                                    },
                                    icon: const Icon(Icons.calendar_month),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 20, 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Center(
                              child: Text('시간별 발정 감지 히스토그램',
                                  style: TextStyle(fontSize: 20)),
                            ),
                            Expanded(
                              child: Container(
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    minY: 0,
                                    maxY: 10,
                                    titlesData: FlTitlesData(
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          getTitlesWidget: getTitles,
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
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('구획별 발정 감지 그래프',
                              style: TextStyle(fontSize: 20)),
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                sectionsSpace: 0,
                                centerSpaceRadius: 0,
                                sections: [
                                  PieChartSectionData(
                                    color: Colors.grey,
                                    value: 100,
                                    title: '0%',
                                    radius: 100.0,
                                    titleStyle: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    badgeWidget: Text(
                                      "모든 구획",
                                      style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    titlePositionPercentageOffset: -0.6,
                                    badgePositionPercentageOffset: .25,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      )),
                    ),
                  ],
                ),
              );
            }),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: '통계',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            label: '이력',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home', extra: widget.token);
            case 2:
              context.go('/history', extra: widget.token);
          }
        },
      ),
    );
  }
}
