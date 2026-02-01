import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/features/rating_master/data/ratings_repository.dart';
import 'package:perf_evaluation/features/rating_master/models/rating_master_model.dart';

final Map<String,String> requestHeaders = {'Content-type':'application/json'};

final ratingMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final ratingList = await ref
        .watch(ratingMasterRepositoryProvider)
        .getRatings();

    final rating = ratingList.rating;

    ref.watch(ratingMasterListNotifier.notifier).clearRating();

    for (var i = 0; i < rating!.length; i++) {
      ref.watch(ratingMasterListNotifier.notifier).addRating(rating[i]);
    }

    return 'Success';
  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});


final saveRatingMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.watch(ratingsBody);
    final response = await ref
        .watch(ratingMasterRepositoryProvider)
        .postRatings(requestBody: requestBody, requestHeaders: requestHeaders);

    final ratingList = await ref
        .read(ratingMasterRepositoryProvider)
        .getRatings();

    final rating = ratingList.rating;

    ref.read(ratingMasterListNotifier.notifier).clearRating();

    for (var i = 0; i < rating!.length; i++) {
      ref.read(ratingMasterListNotifier.notifier).addRating(rating[i]);
    }
    return response;

  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});


final updateRatingMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.watch(updateRatingBody);
    final response = await ref
        .watch(ratingMasterRepositoryProvider)
        .updateRatings(requestHeaders: requestHeaders, requestBody: requestBody);

    final ratingList = await ref
        .read(ratingMasterRepositoryProvider).getRatings();

    final rating = ratingList.rating;

    ref.read(ratingMasterListNotifier.notifier).clearRating();

    for (var i = 0; i < rating!.length; i++) {
      ref.read(ratingMasterListNotifier.notifier).addRating(rating[i]);
    }
    return response;

  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});


final deleteRatingMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.watch(deleteRatingBody); 
    final response = await ref
        .watch(ratingMasterRepositoryProvider)
        .deleteRatings(requestBody: requestBody, requestHeaders: requestHeaders);

    final ratingList = await ref
        .read(ratingMasterRepositoryProvider)
        .getRatings();

    final rating = ratingList.rating;

    ref.read(ratingMasterListNotifier.notifier).clearRating();

    for (var i = 0; i < rating!.length; i++) {
      ref.read(ratingMasterListNotifier.notifier).addRating(rating[i]);
    }
    return response;
  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});


final ratingMasterListNotifier =
    StateNotifierProvider<RatingsMasterNotifier, List<RatingMaster>>((ref) {
  return RatingsMasterNotifier();
});

final ratingsBody = StateProvider<Map>((ref) {
  return {};
});

final updateRatingBody = StateProvider<Map>((ref) {
  return {};
});

final deleteRatingBody = StateProvider<String>((ref) {
  return "";
});

