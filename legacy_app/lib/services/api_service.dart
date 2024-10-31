import 'dart:convert';

import 'package:estrus_detector/models/history_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000";
  //static const String baseUrl = "http://127.0.0.1:8000"; for ios test
  static const String today = "today";
  static Map<String, String> getHeaders = {'accept': 'application/json'};
  static Map<String, String> postHeaders = {'accept': 'application/json', 'Content-Type': 'application/json'};
  static Map<String, String> tokenHeaders = {'accept': 'application/json', 'Content-Type': 'application/x-www-form-urlencoded'};

  static Future<bool> createUser(String username, String password) async {
    final url = Uri.parse('$baseUrl/users/');
    final body = {
      "username": username,
      "password": password
    };
    final response = await http.post(url, headers : postHeaders, body: json.encode(body));
    return (response.statusCode == 200? true : false);
  }

  static Future<bool> existUser(String username) async {
    final url = Uri.parse('$baseUrl/users/$username');
    final response = await http.get(url, headers: getHeaders);
    return (response.statusCode == 200? true : false);
  }

  static Future<String> getLoginToken(String username, String password) async {
    final url = Uri.parse('$baseUrl/token');
    final body = 'grant_type=password&username=$username&password=$password&scope=&client_id=string&client_secret=string';
    final response = await http.post(url, headers: tokenHeaders, body: json.encode(body));
    if (response.statusCode==200) {
      return jsonDecode(utf8.decode(response.bodyBytes))['access_token'];
    }
    return '';
  }

  static Future<List<HistoryModel>> getHistories() async {
    List<HistoryModel> historyInstances = [];
    final url = Uri.parse('$baseUrl/history');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> histories = jsonDecode(utf8.decode(response.bodyBytes));
      for (var history in histories) {
        historyInstances.add(HistoryModel.fromJson(history));
      }
      return historyInstances;
    }
    throw Error();
  }
}
