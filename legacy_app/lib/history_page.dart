import 'package:estrus_detector/models/history_model.dart';
import 'package:estrus_detector/services/api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';

class MyHistoryPage extends StatefulWidget {
  const MyHistoryPage({super.key});

  @override
  State<MyHistoryPage> createState() => _MyHistoryPageState();
}

class _MyHistoryPageState extends State<MyHistoryPage> {
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  int selectedIndex = 1;

  final Future<List<HistoryModel>> histories = ApiService.getHistories();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
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
            onPressed: () => context.push('/alarm'),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: histories,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        TableCalendar(
                          locale: 'ko_KR',
                          focusedDay: focusedDay,
                          firstDay: DateTime(2000),
                          lastDay: DateTime(2050),
                          daysOfWeekHeight: 20,
                          onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                            setState(() {
                              this.selectedDay = selectedDay;
                              this.focusedDay = focusedDay;
                            });
                          },
                          selectedDayPredicate: (DateTime day) {
                            return isSameDay(selectedDay, day);
                          },
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                          ),
                          calendarStyle: CalendarStyle(
                            selectedTextStyle: const TextStyle(
                              color: Colors.white,
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: const TextStyle(
                              color: Colors.green,
                            ),
                            todayDecoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.green,
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Expanded(child: makeList(snapshot)),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: '통계',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            label: '이력',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '홈',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/statistics');
            case 2:
              context.go('/');
          }
        },
      ),
    );
  }

  ListView makeList(AsyncSnapshot<List<HistoryModel>> snapshot) {
    return ListView.separated(
      scrollDirection: Axis.vertical,
      itemCount: snapshot.data!.length,
      itemBuilder: (context, index) {
        var history = snapshot.data![index];
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: const DecorationImage(
                image: AssetImage('assets/free-icon-cow-2194805.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          title: Text(history.title),
          subtitle: Text(history.time),
          onTap: () =>
              context.go('/history/history_detail', extra: {'location': history.location, 'cctv': history.cctv, 'time': history.time, 'type': history.type}),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(
        width: 40,
      ),
    );
  }
}
