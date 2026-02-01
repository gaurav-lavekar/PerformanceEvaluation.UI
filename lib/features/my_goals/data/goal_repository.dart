import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:perf_evaluation/common/api/api_exception.dart';
import 'package:perf_evaluation/common/api/api_master.dart';
import 'package:perf_evaluation/features/my_goals/models/goal_master_model.dart';

class GoalMasterNotifier extends StateNotifier<List<GoalMaster>> {
  GoalMasterNotifier() : super([]);

  bool addGoal(GoalMaster goal) {
    state.where((g) => g.goalDetailsId != goal.goalDetailsId).toList();
    state = [...state, goal];
    return true;
  }

  void clearGoal() {
    state = [];
  }

  final employeesProvider =
      StateNotifierProvider<GoalMasterNotifier, List<GoalMaster>>(
    (ref) => GoalMasterNotifier(),
  );
}

class HttpGoalMasterRepository {
  HttpGoalMasterRepository({required this.client, required this.api});

  final PerfAppraisalAPI api;
  final http.Client client;

  Map<String, String> requestHeaders = {'Content-type': 'application/json'};

  Future<APIGoalMaster> getGoals() => _getData(
      uri: api.getGoals(),
      requestHeaders: requestHeaders,
      builder: (data) => APIGoalMaster.fromJson(data));

  Future<APIGoalMaster> getGoalsbyId({required String requestBody}) =>
      _getDatabyId(
          uri: api.goals(),
          requestHeaders: requestHeaders,
          requestBody: requestBody,
          builder: (data) => APIGoalMaster.fromJson(data));

  Future<String> postGoal(
          {required Map<String, String> requestHeaders,
          required Map requestBody}) =>
      _postData(
          uri: api.goals(),
          requestHeaders: requestHeaders,
          requestBody: requestBody,
          builder: (data) => data.toString());

  Future<String> updateGoal(
          {required Map<String, String> requestHeaders,
          required Map requestBody}) =>
      _updateData(
          uri: api.goals(),
          requestHeaders: requestHeaders,
          requestBody: requestBody,
          builder: (data) => data.toString());

  Future<String> updateReporteeGoal(
          {required Map<String, String> requestHeaders,
          required Map requestBody}) =>
      _updateGoal(
          uri: api.goals(),
          requestHeaders: requestHeaders,
          requestBody: requestBody,
          builder: (data) => data.toString());

  Future<String> deleteGoal(
          {required Map<String, String> requestHeaders,
          required String requestBody}) =>
      _deleteData(
          uri: api.goals(),
          requestHeaders: requestHeaders,
          requestBody: requestBody,
          builder: (data) => data.toString());

  Future<T> _getData<T>(
      {required Uri uri,
      required Map<String, String> requestHeaders,
      required T Function(dynamic data) builder}) async {
    try {
      final response = await client.get(uri, headers: requestHeaders);

      switch (response.statusCode) {
        case 200:
          final data = json.decode(response.body);
          return builder(data);
        case 401:
          throw InvalidApiKeyException().message;
        case 404:
          throw NoDataFoundException().message;
        default:
          throw UnknownException().message;
      }
    } on SocketException catch (_) {
      throw NoInternetConnectionException().message;
    }
  }

  Future<T> _getDatabyId<T>(
      {required Uri uri,
      required Map<String, String> requestHeaders,
      required String requestBody,
      required T Function(dynamic data) builder}) async {
    try {
      final url = Uri.parse('$uri/$requestBody');
      final response = await client.get(url, headers: requestHeaders);

      switch (response.statusCode) {
        case 200:
          final data = json.decode(response.body);
          return builder(data);
        case 401:
          throw InvalidApiKeyException().message;
        case 404:
          throw NoDataFoundException().message;
        default:
          throw UnknownException().message;
      }
    } on SocketException catch (_) {
      throw NoInternetConnectionException().message;
    }
  }

  Future<T> _postData<T>(
      {required Uri uri,
      required Map<String, String> requestHeaders,
      required Map requestBody,
      required T Function(dynamic data) builder}) async {
    try {
      String jsonBody = json.encode(requestBody);
      final encoding = Encoding.getByName('utf-8');
      final response = await client.post(
        uri,
        headers: requestHeaders,
        body: jsonBody,
        encoding: encoding,
      );
      switch (response.statusCode) {
        case 201:
          //final data = json.decode(response.body);
          //print(response.body);
          //return builder(data);
          if (requestBody['goalstatus'] == "Saved Draft") {
            return builder("Draft Saved Successfully");
          } else {
            return builder("Goal Saved Successfully");
          }
        case 401:
          throw InvalidApiKeyException().message;
        case 404:
          throw NoDataFoundException().message;
        case 409:
          throw ConflictException(response.body).message;
        default:
          throw UnknownException().message;
      }
    } on SocketException catch (_) {
      throw NoInternetConnectionException().message;
    }
  }

  Future<T> _updateData<T>(
      {required Uri uri,
      required Map<String, String> requestHeaders,
      required Map requestBody,
      required T Function(dynamic data) builder}) async {
    try {
      String id = requestBody['goaldetailsid'];
      String jsonBody = json.encode(requestBody);
      final encoding = Encoding.getByName('utf-8');
      final url = Uri.parse('$uri/$id');
      final response = await client.put(
        url,
        headers: requestHeaders,
        body: jsonBody,
        encoding: encoding,
      );

      switch (response.statusCode) {
        case 204:
          //final data = json.decode(response.body);
          //print(response.body);
          //return builder(data);
          if (requestBody['goalstatus'] == "New") {
            return builder("Goal Saved Successfully");
          } else {
            return builder("Draft Updated Successfully");
          }
        case 401:
          throw InvalidApiKeyException().message;
        case 404:
          throw NoDataFoundException().message;
        case 409:
          throw ConflictException(response.body).message;
        default:
          throw UnknownException().message;
      }
    } on SocketException catch (_) {
      throw NoInternetConnectionException().message;
    }
  }

  Future<T> _updateGoal<T>(
      {required Uri uri,
      required Map<String, String> requestHeaders,
      required Map requestBody,
      required T Function(dynamic data) builder}) async {
    try {
      String id = requestBody['goaldetailsid'];
      String jsonBody = json.encode(requestBody);
      final encoding = Encoding.getByName('utf-8');
      final url = Uri.parse('$uri/$id');
      final response = await client.put(
        url,
        headers: requestHeaders,
        body: jsonBody,
        encoding: encoding,
      );

      switch (response.statusCode) {
        case 204:
          //final data = json.decode(response.body);
          //print(response.body);
          //return builder(data);
          if (requestBody['goalstatus'] == "Approved") {
            return builder("Goal Approved Successfully");
          } else if (requestBody['goalstatus'] == "Saved Draft") {
            return builder("Draft Saved Successfully");
          } else if (requestBody['goalstatus'] == "New") {
            return builder("Goal Saved Successfully");
          } else {
            return builder("Goal Rejected Successfully");
          }
        case 401:
          throw InvalidApiKeyException().message;
        case 404:
          throw NoDataFoundException().message;
        case 409:
          throw ConflictException(response.body).message;
        default:
          throw UnknownException().message;
      }
    } on SocketException catch (_) {
      throw NoInternetConnectionException().message;
    }
  }

  Future<T> _deleteData<T>(
      {required Uri uri,
      required Map<String, String> requestHeaders,
      required String requestBody,
      required T Function(dynamic data) builder}) async {
    try {
      final url = Uri.parse('$uri/$requestBody');
      final response = await client.delete(url);
      switch (response.statusCode) {
        case 204:
          //final data = json.decode(response.body);
          //print(response.body);
          //return builder(data);
          return builder("Goal deleted successfully");
        case 401:
          throw InvalidApiKeyException().message;
        case 404:
          throw NoDataFoundException().message;
        case 409:
          throw ConflictException(response.body).message;
        default:
          throw UnknownException().message;
      }
    } on SocketException catch (_) {
      throw NoInternetConnectionException().message;
    }
  }
}

final goalMasterRepositoryProvider = Provider<HttpGoalMasterRepository>((ref) {
  /// Use the API key passed via --dart-define,
  /// or fallback to the one defined in api_keys.dart
  // set key to const
  // const apiKey = String.fromEnvironment(
  //   'API_KEY',
  //   defaultValue: "APIKeys",
  // );

  return HttpGoalMasterRepository(
    api: PerfAppraisalAPI(),
    client: http.Client(),
  );
});
