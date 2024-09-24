class HistoryModel {
  final String title, time;

  HistoryModel({required this.title, required this.time});

  HistoryModel.fromJson(Map<String, dynamic> json)
      : title = json['location'] + '에서 승가행위가 감지되었습니다',
        time = json['time'];
}
