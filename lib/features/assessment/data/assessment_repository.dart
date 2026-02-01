import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:perf_evaluation/common/api/api_exception.dart';
import 'package:perf_evaluation/common/api/api_master.dart';
import 'package:perf_evaluation/features/assessment/models/assessment_master_model.dart';

class AssessmentMasterNotifier extends StateNotifier<List<AssessmentMaster>> {
  AssessmentMasterNotifier() : super([]);

  bool addAssessment(AssessmentMaster assessment) {
    state.where((a) => a.assessmentId != assessment.assessmentId).toList();
    state = [...state, assessment];
    return true;
  }

  void clearAssessment() {
    state = [];
  }

  final employeesProvider =
      StateNotifierProvider<AssessmentMasterNotifier, List<AssessmentMaster>>(
    (ref) => AssessmentMasterNotifier(),
  );
}

class HttpAssessmentMasterRepository {
  HttpAssessmentMasterRepository({required this.client, required this.api});

  final PerfAppraisalAPI api;
  final http.Client client;

  Map<String, String> requestHeaders = {'Content-type': 'application/json'};

  Future<APIAssessmentMaster> getAssessments() => _getData(
      uri: api.getAssessments(),
      requestHeaders: requestHeaders,
      builder: (data) => APIAssessmentMaster.fromJson(data));

  Future<APIAssessmentMaster> getAssessmentsbyId(
          {required String requestBody}) =>
      _getDatabyId(
          uri: api.assessment(),
          requestHeaders: requestHeaders,
          requestBody: requestBody,
          builder: (data) => APIAssessmentMaster.fromJson(data));

  Future<String> postAssessment(
          {required Map<String, String> requestHeaders,
          required Map requestBody}) =>
      _postData(
          uri: api.assessment(),
          requestHeaders: requestHeaders,
          requestBody: requestBody,
          builder: (data) => data.toString());

  Future<String> updateAssessment(
          {required Map<String, String> requestHeaders,
          required Map requestBody}) =>
      _updateData(
          uri: api.assessment(),
          requestHeaders: requestHeaders,
          requestBody: requestBody,
          builder: (data) => data.toString());

  Future<String> deleteAssessment(
          {required Map<String, String> requestHeaders,
          required String requestBody}) =>
      _deleteData(
          uri: api.assessment(),
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
        case 404:
          throw Exception("No data found!");
        default:
          throw Exception("Something went wrong!");
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
        case 404:
          throw Exception("No data found!");
        default:
          throw Exception("Something went wrong!");
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
      String status = requestBody['assessmentstatus'];
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
          if (status == "Saved Draft") {
            return builder("Draft Saved Successfully");
          } else {
            return builder("Appraisal Saved successfully");
          }
        case 400:
          throw BadRequestException(response.body).message;
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
      String id = requestBody['assessmentid'];
      String status = requestBody['assessmentstatus'];
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
        case 200:
          //final data = json.decode(response.body);
          //print(response.body);
          //return builder(data);
          if (status == "New") {
            return builder("Appraisal Saved Successfully");
          } else {
            return builder("Draft Updated Successfully");
          }
        case 404:
          throw NoDataFoundException().message;
        default:
          throw UnknownException().message;
      }
    } on SocketException catch (_) {
      throw NoInternetConnectionException().message;
    }
  }

  Future<T> _updateAppraisal<T>(
      {required Uri uri,
      required Map<String, String> requestHeaders,
      required Map requestBody,
      required T Function(dynamic data) builder}) async {
    try {
      String id = requestBody['assessmentid'];
      String status = requestBody['assessmentstatus'];
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
        case 200:
          //final data = json.decode(response.body);
          //print(response.body);
          //return builder(data);
          if (status == "New") {
            return builder("Appraisal Saved Successfully");
          } else {
            return builder("Draft Updated Successfully");
          }
        case 404:
          throw NoDataFoundException().message;
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
        case 200:
          //final data = json.decode(response.body);
          //print(response.body);
          //return builder(data);
          return builder("Assessment deleted successfully");
        case 404:
          throw NoDataFoundException().message;
        default:
          throw UnknownException().message;
      }
    } on SocketException catch (_) {
      throw NoInternetConnectionException().message;
    }
  }
}

final assessmentMasterRepositoryProvider =
    Provider<HttpAssessmentMasterRepository>((ref) {
  /// Use the API key passed via --dart-define,
  /// or fallback to the one defined in api_keys.dart
  // set key to const
  // const apiKey = String.fromEnvironment(
  //   'API_KEY',
  //   defaultValue: "APIKeys",
  // );

  return HttpAssessmentMasterRepository(
    api: PerfAppraisalAPI(),
    client: http.Client(),
  );
});
