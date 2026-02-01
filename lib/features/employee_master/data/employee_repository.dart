import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:perf_evaluation/common/api/api_exception.dart';
import 'package:perf_evaluation/common/api/api_master.dart';
import 'package:perf_evaluation/features/employee_master/models/employee_master_model.dart';

class EmployeeMasterNotifier extends StateNotifier<List<EmployeeMaster>> {
  EmployeeMasterNotifier() : super([]);

  bool addEmployee(EmployeeMaster employee) {
    state.where((e) => e.employeeId != employee.employeeId).toList();
    state = [...state, employee];
    return true;
  }

  void clearEmployee() {
    state = [];
  }

  final employeesProvider =
      StateNotifierProvider<EmployeeMasterNotifier, List<EmployeeMaster>>(
    (ref) => EmployeeMasterNotifier(),
  );
}

class HttpEmployeeMasterRepository {
  HttpEmployeeMasterRepository({required this.client, required this.api});

  final PerfAppraisalAPI api;
  final http.Client client;

  Map<String, String> requestHeaders = {'Content-type': 'application/json'};

  Future<APIEmployeeMaster> getEmployees() => _getData(
      uri: api.getEmployee(),
      requestHeaders: requestHeaders,
      builder: (data) => APIEmployeeMaster.fromJson(data));

  Future<APIEmployeeMaster> getEmployeebyId({required String requestBody}) =>
      _getDatabyId(
          uri: api.employee(),
          requestHeaders: requestHeaders,
          requestBody: requestBody,
          builder: (data) => APIEmployeeMaster.fromJson(data));

  Future<String> postEmployee(
          {required Map<String, String> requestHeaders,
          required Map requestBody}) =>
      _postData(
          uri: api.employee(),
          requestHeaders: requestHeaders,
          requestBody: requestBody,
          builder: (data) => data.toString());

  Future<String> updateEmployee(
          {required Map<String, String> requestHeaders,
          required Map requestBody}) =>
      _updateData(
          uri: api.employee(),
          requestHeaders: requestHeaders,
          requestBody: requestBody,
          builder: (data) => data.toString());

  Future<String> deleteEmployee(
          {required Map<String, String> requestHeaders,
          required String requestBody}) =>
      _deleteData(
          uri: api.employee(),
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
          return builder("Employee added successfully");
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
      String id = requestBody['employeeid'];
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
          //print(response.statusCode);
          return builder("Employee updated successfully");
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
          //print(response.statusCode);
          return builder("Employee deleted successfully");
        case 401:
          throw InvalidApiKeyException().message;
        case 404:
          throw NoDataFoundException().message;
        case 200:
          throw ConflictException(response.body).message;
        default:
          throw UnknownException().message;
      }
    } on SocketException catch (_) {
      throw NoInternetConnectionException().message;
    }
  }
}

final employeeMasterRepositoryProvider =
    Provider<HttpEmployeeMasterRepository>((ref) {
  /// Use the API key passed via --dart-define,
  /// or fallback to the one defined in api_keys.dart
  // set key to const
  // const apiKey = String.fromEnvironment(
  //   'API_KEY',
  //   defaultValue: "APIKeys",
  // );

  return HttpEmployeeMasterRepository(
    api: PerfAppraisalAPI(),
    client: http.Client(),
  );
});
