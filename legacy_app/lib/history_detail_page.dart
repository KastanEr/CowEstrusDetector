import 'dart:typed_data';
import 'package:estrus_detector/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyHistoryDetailPage extends StatefulWidget {
  final String detail;
  const MyHistoryDetailPage({super.key, required this.detail});

  @override
  State<MyHistoryDetailPage> createState() => _MyHistoryDetailPageState();
}

class _MyHistoryDetailPageState extends State<MyHistoryDetailPage> {
  late Uint8List imageBytes;
  bool isLoading = true;
  late List<String> strList = widget.detail.split("\t");

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  Future<void> loadImage() async {
    try {
      imageBytes =
          await ApiService.getImage(int.parse(strList[convertString2Int('pred_id')]));
    } catch (e) {
      imageBytes = Uint8List(0);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  int convertString2Int(String str) {
    switch(str) {
      case 'token':
        return 0;
      case 'location':
        return 1;
      case 'cctv':
        return 2;
      case 'time':
        return 3;
      case 'pred_id':
        return 4;
    }
    return -1;
  }

  void showPopUp(BuildContext context, String msg, bool success) {
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
                      success
                          ? context.go('/history',
                              extra: strList[convertString2Int('token')])
                          : context.pop();
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

  Future<void> fixPrediction(BuildContext context, int predId) async {
    await ApiService.fixPrediction(strList[convertString2Int('token')], predId)
        ? showPopUp(context, "수정에 성공했습니다.", true)
        : showPopUp(context, "수정에 실패했습니다.\n다시 시도해주세요.", false);
  }

  @override
  Widget build(BuildContext context) {
    String token = strList[convertString2Int('token')];
    int location = int.parse(strList[convertString2Int('location')]);
    int cctv = int.parse(strList[convertString2Int('cctv')]);
    String time = strList[convertString2Int('time')];
    int predId = int.parse(strList[convertString2Int('pred_id')]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Center(
          child: Text("상세 내역", style: TextStyle(color: Colors.white)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert_outlined, color: Colors.white),
            onPressed: () => context.push('/alarm', extra: token),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: const Color(0xffd6d6d6),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: isLoading
                    ? CircularProgressIndicator()
                    : Image.memory(imageBytes),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListTile(
                          leading:
                              const Text("위치", style: TextStyle(fontSize: 20)),
                          trailing: Text("제 $location 구획",
                              style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          leading: const Text("CCTV",
                              style: TextStyle(fontSize: 20)),
                          trailing: Text("$cctv번 CCTV",
                              style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          leading: const Text("감지시각",
                              style: TextStyle(fontSize: 20)),
                          trailing:
                              Text(time, style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("이미지를 확인해주세요.",
                                style: TextStyle(fontSize: 23)),
                            Text("승가가 아닌 경우 아래의 '수정하기'를",
                                style: TextStyle(fontSize: 23)),
                            Text("눌러서 수정해주세요.", style: TextStyle(fontSize: 23)),
                          ],
                        ),
                      ),
                    ],
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
                  onPressed: () => fixPrediction(context, predId),
                  child: const Text('수정하기',
                      style: TextStyle(color: Colors.white, fontSize: 30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
