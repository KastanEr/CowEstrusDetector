class HistoryModel {
  final String title, location, cctv, time, type;

  HistoryModel({required this.title, required this.location, required this.cctv, required this.time, required this.type});

  HistoryModel.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        location = json['location'],
        cctv = json['cctv'],
        time = json['time'],
        type = json['class'];
}
