import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/features/financial_year/data/financialyear_repository.dart';
import 'package:perf_evaluation/features/financial_year/models/financialyear_model.dart';

final Map<String, String> requestHeaders = {'Content-type': 'application/json'};

final financialyearMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final yearList =
        await ref.watch(yearMasterRepositoryProvider).getFinancialYears();

    final years = yearList.financialyears!;

    ref.watch(yearMasterListNotifier.notifier).clearFinancialYear();

    for (var i = 0; i < years.length; i++) {
      ref.watch(yearMasterListNotifier.notifier).addFinancialYear(years[i]);
    }
    return "Success";
  } catch (e) {
    throw e.toString();
  }
});

final saveFinancialYear = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.watch(yearBody);

    final response = await ref
        .watch(yearMasterRepositoryProvider)
        .postFinancialYear(
            requestBody: requestBody, requestHeaders: requestHeaders);

    final yearList =
        await ref.read(yearMasterRepositoryProvider).getFinancialYears();

    final year = yearList.financialyears;

    ref.read(yearMasterListNotifier.notifier).clearFinancialYear();

    for (var i = 0; i < year!.length; i++) {
      ref.read(yearMasterListNotifier.notifier).addFinancialYear(year[i]);
    }
    return response;
  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});

final updateFinancialYear = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.watch(updateYearBody);
    final response = await ref
        .watch(yearMasterRepositoryProvider)
        .updateFinancialYear(
            requestHeaders: requestHeaders, requestBody: requestBody);

    final yearList =
        await ref.read(yearMasterRepositoryProvider).getFinancialYears();

    final year = yearList.financialyears;

    ref.read(yearMasterListNotifier.notifier).clearFinancialYear();

    for (var i = 0; i < year!.length; i++) {
      ref.read(yearMasterListNotifier.notifier).addFinancialYear(year[i]);
    }
    return response;
  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});

final deleteFinancialYear = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.watch(deleteYearBody);
    final response = await ref
        .watch(yearMasterRepositoryProvider)
        .deleteFinancialYear(
            requestBody: requestBody, requestHeaders: requestHeaders);

    final yearList =
        await ref.read(yearMasterRepositoryProvider).getFinancialYears();

    final year = yearList.financialyears;

    ref.read(yearMasterListNotifier.notifier).clearFinancialYear();

    for (var i = 0; i < year!.length; i++) {
      ref.read(yearMasterListNotifier.notifier).addFinancialYear(year[i]);
    }
    return response;
  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});

final yearMasterListNotifier =
    StateNotifierProvider<FYMasterNotifier, List<FinancialYearMaster>>((ref) {
  return FYMasterNotifier();
});

final yearBody = StateProvider<Map>((ref) {
  return {};
});

final updateYearBody = StateProvider<Map>((ref) {
  return {};
});

final deleteYearBody = StateProvider<String>((ref) {
  return "";
});
