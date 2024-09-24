import 'dart:convert';

import 'package:app/models/history_detail_model.dart';
import 'package:app/models/history_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8080";

  static Future<List<HistoryDetailModel>> getHistoryDetails() async {
    List<HistoryDetailModel> histroyDetailInstances = [];
    final url = Uri.parse('$baseUrl/historyDetails');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> historyDetails = jsonDecode(utf8.decode(response.bodyBytes));
      for (var historyDetail in historyDetails) {
        histroyDetailInstances.add(HistoryDetailModel.fromJson(historyDetail));
      }
      return histroyDetailInstances;
    }
    throw Error();
  }

  static Future<List<HistoryModel>> getHistories() async {
    List<HistoryModel> histroyInstances = [];
    final url = Uri.parse('$baseUrl/histories');
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
