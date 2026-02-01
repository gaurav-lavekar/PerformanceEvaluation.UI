import 'dart:convert';
import 'dart:io';
//GET - 200,500 / POST-201,400 / PUT- 204,500 / DELETE - 200,409
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:perf_evaluation/common/api/api_exception.dart';
import 'package:perf_evaluation/common/api/api_master.dart';
import 'package:perf_evaluation/features/rating_master/models/rating_master_model.dart';

class RatingsMasterNotifier extends StateNotifier<List<RatingMaster>> {
  RatingsMasterNotifier() : super([]);

  bool addRating(RatingMaster rating) {
    state.where((r) => r.ratingId != rating.ratingId).toList();
    state = [...state, rating];
    return true;
  }

  void clearRating() {
    state = [];
  }

  final ratingsProvider =
      StateNotifierProvider<RatingsMasterNotifier, List<RatingMaster>>(
    (ref) => RatingsMasterNotifier(),
  );
}

class HttpRatingMasterRepository {
  HttpRatingMasterRepository({required this.client, required this.api});

  final PerfAppraisalAPI api;
  final http.Client client;

  Map<String, String> requestHeaders = {'Content-type': 'application/json'};

  Future<APIRatingMaster> getRatings() => _getData(
      uri: api.getRating(),
      requestHeaders: requestHeaders,
      builder: (data) => APIRatingMaster.fromJson(data));

  Future<String> postRatings(
          {required Map<String, String> requestHeaders,
          required Map requestBody}) =>
      _postData(
          uri: api.rating(),
          requestHeaders: requestHeaders,
          requestBody: requestBody,
          builder: (data) => data.toString());

  Future<String> updateRatings(
          {required Map<String, String> requestHeaders,
          required Map requestBody}) =>
      _updateData(
          uri: api.rating(),
          requestHeaders: requestHeaders,
          requestBody: requestBody,
          builder: (data) => data.toString());

  Future<String> deleteRatings(
          {required Map<String, String> requestHeaders,
          required String requestBody}) =>
      _deleteData(
          uri: api.rating(),
          requestHeaders: requestHeaders,
          requestBody: requestBody,
          builder: (data) => data.toString());

  Future<T> _getData<T>(
      {required Uri uri,
      required Map<String, String> requestHeaders,
      required T Function(dynamic data) builder}) async {
    try {
      final url = Uri.parse('$uri');
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
          return builder("Rating added successfully");
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
      String id = requestBody['ratingid'];
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
          return builder("Rating updated successfully");
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
          return builder("Rating deleted successfully");
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

final ratingMasterRepositoryProvider =
    Provider<HttpRatingMasterRepository>((ref) {
  /// Use the API key passed via --dart-define,
  /// or fallback to the one defined in api_keys.dart
  // set key to const
  // const apiKey = String.fromEnvironment(
  //   'API_KEY',
  //   defaultValue: "APIKeys",
  // );

  return HttpRatingMasterRepository(
    api: PerfAppraisalAPI(),
    client: http.Client(),
  );
});
