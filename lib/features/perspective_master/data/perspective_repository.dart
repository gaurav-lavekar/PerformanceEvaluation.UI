import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:perf_evaluation/common/api/api_exception.dart';
import 'package:perf_evaluation/common/api/api_master.dart';
import 'package:perf_evaluation/features/perspective_master/models/perspective_master_model.dart';

class PerspectiveMasterNotifier extends StateNotifier<List<PerspectiveMaster>> {
  PerspectiveMasterNotifier() : super([]);

  bool addPerspective(PerspectiveMaster perspective) {
    state
        .where((r) => r.goalPerspectiveId != perspective.goalPerspectiveId)
        .toList();
    state = [...state, perspective];
    return true;
  }

  void clearPerspective() {
    state = [];
  }

  final perspectivesProvider =
      StateNotifierProvider<PerspectiveMasterNotifier, List<PerspectiveMaster>>(
    (ref) => PerspectiveMasterNotifier(),
  );
}

class HttpPerspectiveMasterRepository {
  HttpPerspectiveMasterRepository({required this.client, required this.api});

  final PerfAppraisalAPI api;
  final http.Client client;

  Map<String, String> requestHeaders = {'Content-type': 'application/json'};

  Future<APIPerspectiveMaster> getPerspectives() => _getData(
      uri: api.getPerspective(),
      requestHeaders: requestHeaders,
      builder: (data) => APIPerspectiveMaster.fromJson(data));

  Future<String> postPerspective(
          {required Map<String, String> requestHeaders,
          required Map requestBody}) =>
      _postData(
          uri: api.perspective(),
          requestHeaders: requestHeaders,
          requestBody: requestBody,
          builder: (data) => data.toString());

  Future<String> updatePerspective(
          {required Map<String, String> requestHeaders,
          required Map requestBody}) =>
      _updateData(
          uri: api.perspective(),
          requestHeaders: requestHeaders,
          requestBody: requestBody,
          builder: (data) => data.toString());

  Future<String> deletePerspective(
          {required Map<String, String> requestHeaders,
          required String requestBody}) =>
      _deleteData(
          uri: api.perspective(),
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
          return builder("Perspective added successfully");
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
      String id = requestBody['goalperspectiveid'];
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
          return builder("Perspective updated successfully");
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
          return builder("Perspective deleted successfully");
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

final perspectiveMasterRepositoryProvider =
    Provider<HttpPerspectiveMasterRepository>((ref) {
  /// Use the API key passed via --dart-define,
  /// or fallback to the one defined in api_keys.dart
  // set key to const
  // const apiKey = String.fromEnvironment(
  //   'API_KEY',
  //   defaultValue: "APIKeys",
  // );

  return HttpPerspectiveMasterRepository(
    api: PerfAppraisalAPI(),
    client: http.Client(),
  );
});
