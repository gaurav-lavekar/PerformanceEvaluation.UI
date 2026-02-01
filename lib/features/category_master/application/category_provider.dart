import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/features/category_master/data/category_repository.dart';
import 'package:perf_evaluation/features/category_master/models/category_master_model.dart';

final Map<String,String> requestHeaders = {'Content-type':'application/json'};

final categoryMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final categoryList = await ref
        .watch(categoryMasterRepositoryProvider)
        .getCategory();

    final category = categoryList.category!;

    ref.watch(categoryMasterListNotifier.notifier).clearCategory();

    for(var i = 0; i < category.length; i++) {
      ref.watch(categoryMasterListNotifier.notifier).addCategory(category[i]);
      
    }                         
    return "Success";
  } catch (e) {
      throw e.toString();
  }
});


final saveCategoryMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.watch(categoryBody);
    final response = await ref
        .watch(categoryMasterRepositoryProvider)
        .postCategory(requestBody: requestBody, requestHeaders: requestHeaders);

    final categoryList = await ref
        .read(categoryMasterRepositoryProvider)
        .getCategory();

    final category = categoryList.category!;

    ref.read(categoryMasterListNotifier.notifier).clearCategory();

    for (var i = 0; i < category.length; i++) {
      ref.read(categoryMasterListNotifier.notifier).addCategory(category[i]);
    }
    return response;

  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});


final updateCategoryMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.watch(updateCategoryBody);
    final response = await ref
        .watch(categoryMasterRepositoryProvider)
        .updateCategory(requestHeaders: requestHeaders, requestBody: requestBody);

    final categoryList = await ref
        .read(categoryMasterRepositoryProvider)
        .getCategory();

    final category = categoryList.category!;

    ref.read(categoryMasterListNotifier.notifier).clearCategory();

    for (var i = 0; i < category.length; i++) {
      ref.read(categoryMasterListNotifier.notifier).addCategory(category[i]);
    }
    return response;

  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});


final deleteCategoryMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.watch(deleteCategoryBody); 
    final response = await ref
        .watch(categoryMasterRepositoryProvider)
        .deleteCategory(requestBody: requestBody, requestHeaders: requestHeaders);

    final categoryList = await ref
        .read(categoryMasterRepositoryProvider)
        .getCategory();

    final category = categoryList.category!;

    ref.read(categoryMasterListNotifier.notifier).clearCategory();

    for (var i = 0; i < category.length; i++) {
      ref.read(categoryMasterListNotifier.notifier).addCategory(category[i]);
    }
    return response;
  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});

final categoryMasterListNotifier =
    StateNotifierProvider<CategoryMasterNotifier, List<CategoryMaster>>((ref) {
  return CategoryMasterNotifier();
});

final categoryBody = StateProvider<Map>((ref) {
  return {};
});

final updateCategoryBody = StateProvider<Map>((ref) {
  return {};
});

final deleteCategoryBody = StateProvider<String>((ref) {
  return "";
});

