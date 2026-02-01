import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/common/api/api_exception.dart';
import 'package:perf_evaluation/common/api/api_master.dart';
import 'package:perf_evaluation/features/financial_year/models/financialyear_model.dart';

class FYMasterNotifier extends StateNotifier<List<FinancialYearMaster>> {
  FYMasterNotifier() : super([]);

  bool addFinancialYear(FinancialYearMaster year) {
    state.where((y) => y.financialyearid == year.financialyearid).toList();
    state = [...state, year];
    // print(state.iterator.current.ratingCategoryName!);
    return true;
  }

  void clearFinancialYear() {
    state = [];
  }
}

class HttpFYMasterRepository {
  HttpFYMasterRepository({required this.client, required this.api});

  final PerfAppraisalAPI api;
  final http.Client client;

  Map<String, String> requestHeaders = {'Content-type': 'application/json'};

  Future<ApiFYMaster> getFinancialYears() => _getData(
      uri: api.getFinancialYears(),
      requestHeaders: requestHeaders,
      builder: (data) => ApiFYMaster.fromJson(data));

  Future<String> postFinancialYear(
          {required Map<String, String> requestHeaders,
          required Map requestBody}) =>
      _postData(
          uri: api.financialyears(),
          requestHeaders: requestHeaders,
          requestBody: requestBody,
          builder: (data) => data.toString());

  Future<String> updateFinancialYear(
          {required Map<String, String> requestHeaders,
          required Map requestBody}) =>
      _updateData(
          uri: api.financialyears(),
          requestHeaders: requestHeaders,
          requestBody: requestBody,
          builder: (data) => data.toString());

  Future<String> deleteFinancialYear(
          {required Map<String, String> requestHeaders,
          required String requestBody}) =>
      _deleteData(
          uri: api.financialyears(),
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
          return builder("Financial Year added successfully");
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
      String id = requestBody['financialyearid'];
      final url = Uri.parse('$uri/$id');
      String jsonBody = json.encode(requestBody);
      final encoding = Encoding.getByName('utf-8');
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
          return builder("Financial Year updated successfully");
        //throw UnknownException().message;
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
          return builder("Financial Year deleted successfully");
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

final yearMasterRepositoryProvider = Provider<HttpFYMasterRepository>((ref) {
  /// Use the API key passed via --dart-define,
  /// or fallback to the one defined in api_keys.dart
  // set key to const
  // const apiKey = String.fromEnvironment(
  //   'API_KEY',
  //   defaultValue: "APIKeys",
  // );

  return HttpFYMasterRepository(
    api: PerfAppraisalAPI(),
    client: http.Client(),
  );
});
