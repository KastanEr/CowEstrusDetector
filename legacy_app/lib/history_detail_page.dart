import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyHistoryDetailPage extends StatelessWidget {
  final Map detail;
  const MyHistoryDetailPage({Key? key, required this.detail}) : super(key: key);
  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '승가';
        break;
      case 1:
        text = '섬';
        break;
      case 2:
        text = '앉음';
        break;
      case 3:
        text = '누움';
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

  @override
  Widget build(BuildContext context) {
    String location = detail['location'];
    String cctv = detail['cctv'];
    String time = detail['time'];
    String type = detail['type'];
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.green,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => context.pop(),
          ),
          title: const Center(
              child: Text(
            "상세 내역",
            style: TextStyle(
              color: Colors.white,
            ),
          )),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.add_alert_outlined,
                color: Colors.white,
              ),
              onPressed: () => context.push('/alarm'),
            ),
          ]),
      body: SafeArea(
        child: Container(
          color: const Color(0xffd6d6d6),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: const DecorationImage(
                      image: NetworkImage("http://127.0.0.1:8080/image/image.jpg"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(children: [
                      Expanded(
                        child: ListTile(
                          leading: const Text(
                            "위치",
                            style: TextStyle(fontSize: 20),
                          ),
                          trailing: Text(
                            location,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          leading: const Text(
                            "CCTV",
                            style: TextStyle(fontSize: 20),
                          ),
                          trailing: Text(
                            cctv,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          leading: const Text(
                            "감지시각",
                            style: TextStyle(fontSize: 20),
                          ),
                          trailing: Text(
                            time,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          leading: const Text(
                            "행동 유형",
                            style: TextStyle(fontSize: 20),
                          ),
                          trailing: Text(
                            type,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ])),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      minY: 0,
                      maxY: 130,
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: getTitles,
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: 80,
                            ),
                          ],
                          showingTooltipIndicators: [0],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: 10,
                            )
                          ],
                          showingTooltipIndicators: [0],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [
                            BarChartRodData(
                              toY: 5,
                            )
                          ],
                          showingTooltipIndicators: [0],
                        ),
                        BarChartGroupData(
                          x: 3,
                          barRods: [
                            BarChartRodData(
                              toY: 5,
                            )
                          ],
                          showingTooltipIndicators: [0],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    backgroundColor: Colors.green,
                    minimumSize: const Size.fromHeight(30),
                  ),
                  onPressed: () => context.pop(),
                  child: const Text('확 인', style: TextStyle(color: Colors.white, fontSize: 30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
