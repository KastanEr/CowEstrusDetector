import 'dart:convert';

import 'package:estrus_detector/models/history_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8080";
  static const String today = "today";

  static Future<List<HistoryModel>> getHistories() async {
    List<HistoryModel> histroyInstances = [];
    final url = Uri.parse('$baseUrl/history');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> histories = jsonDecode(utf8.decode(response.bodyBytes));
      for (var history in histories) {
        histroyInstances.add(HistoryModel.fromJson(history));
      }
      return histroyInstances;
    }
    throw Error();
  }
}
