class HistoryModel {
  final int id, location, cctv, pred_id;
  final String time;

  HistoryModel({required this.id, required this.location, required this.cctv, required this.pred_id, required this.time});

  HistoryModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        location = json['location'],
        cctv = json['cctv'],
        pred_id = json['pred_id'],
        time = json['time'];
}
