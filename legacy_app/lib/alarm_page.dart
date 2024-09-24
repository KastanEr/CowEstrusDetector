import 'package:estrus_detector/models/history_model.dart';
import 'package:estrus_detector/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyAlarmPage extends StatefulWidget {
  const MyAlarmPage({super.key});

  @override
  State<MyAlarmPage> createState() => _MyAlarmPageState();
}

class _MyAlarmPageState extends State<MyAlarmPage> {
  final Future<List<HistoryModel>> histories = ApiService.getHistories();

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
