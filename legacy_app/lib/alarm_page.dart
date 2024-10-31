import 'package:estrus_detector/models/history_model.dart';
import 'package:estrus_detector/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MyAlarmPage extends StatefulWidget {
  final String token;
  const MyAlarmPage({super.key, required this.token});

  @override
  State<MyAlarmPage> createState() => _MyAlarmPageState();
}

class _MyAlarmPageState extends State<MyAlarmPage> {
  late Future<List<HistoryModel>> histories = ApiService.getHistories(
      widget.token,
      DateFormat('yyyy-MM-dd')
          .format(DateTime.now().toUtc().add(Duration(hours: 9))));

  @override
  Widget build(BuildContext context) {
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
            "알림",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
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
          title: Text(
              '${history.location}구획에서 ${history.time.split(' ')[1].split(':')[0]}시 ${history.time.split(' ')[1].split(':')[1]}분에 승가 행위가 감지되었습니다. 확인 바랍니다.'),
          onTap: () => context.go('/history/history_detail', extra: {
            'token': widget.token,
            'location': history.location.toString(),
            'cctv': history.cctv.toString(),
            'time': history.time,
            'pred_id': history.pred_id.toString()
          }),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(
        width: 40,
      ),
    );
  }
}
