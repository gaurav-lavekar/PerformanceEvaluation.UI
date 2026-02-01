import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/features/assessment/data/assessment_repository.dart';
import 'package:perf_evaluation/features/assessment/models/assessment_master_model.dart';
import 'package:perf_evaluation/features/my_goals/application/goal_provider.dart';

final Map<String, String> requestHeaders = {'Content-type': 'application/json'};

final assessmentMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final assessmentList =
        await ref.watch(assessmentMasterRepositoryProvider).getAssessments();

    final assessment = assessmentList.assessments;

    ref.watch(assessmentMasterListNotifier.notifier).clearAssessment();

    for (var i = 0; i < assessment!.length; i++) {
      ref
          .watch(assessmentMasterListNotifier.notifier)
          .addAssessment(assessment[i]);
    }

    return 'Success';
  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});

final myAssessments = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.read(employeeId);
    final assessmentList = await ref
        .watch(assessmentMasterRepositoryProvider)
        .getAssessmentsbyId(requestBody: requestBody);

    final assessment = assessmentList.assessments;

    ref.watch(assessmentMasterListNotifier.notifier).clearAssessment();

    for (var i = 0; i < assessment!.length; i++) {
      ref
          .watch(assessmentMasterListNotifier.notifier)
          .addAssessment(assessment[i]);
    }

    return 'Success';
  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});

final saveAssessmentMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.watch(assessmentBody);
    final employeeid = ref.read(employeeId);
    requestBody['employeeid'] = employeeid;

    final response = await ref
        .watch(assessmentMasterRepositoryProvider)
        .postAssessment(
            requestBody: requestBody, requestHeaders: requestHeaders);

    final assessmentList =
        await ref.read(assessmentMasterRepositoryProvider).getAssessments();

    final assessment = assessmentList.assessments;

    ref.read(assessmentMasterListNotifier.notifier).clearAssessment();

    for (var i = 0; i < assessment!.length; i++) {
      ref
          .read(assessmentMasterListNotifier.notifier)
          .addAssessment(assessment[i]);
    }
    return response;
  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});

final updateAssessmentMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.watch(updateAssessmentBody);
    final response = await ref
        .watch(assessmentMasterRepositoryProvider)
        .updateAssessment(
            requestHeaders: requestHeaders, requestBody: requestBody);

    final assessmentList =
        await ref.read(assessmentMasterRepositoryProvider).getAssessments();

    final assessment = assessmentList.assessments;

    ref.read(assessmentMasterListNotifier.notifier).clearAssessment();

    for (var i = 0; i < assessment!.length; i++) {
      ref
          .read(assessmentMasterListNotifier.notifier)
          .addAssessment(assessment[i]);
    }
    return response;
  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});

final deleteAssessmentMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.watch(deleteAssessmentBody);
    final response = await ref
        .watch(assessmentMasterRepositoryProvider)
        .deleteAssessment(
            requestBody: requestBody, requestHeaders: requestHeaders);

    final assessmentList =
        await ref.read(assessmentMasterRepositoryProvider).getAssessments();

    final assessment = assessmentList.assessments;

    ref.read(assessmentMasterListNotifier.notifier).clearAssessment();

    for (var i = 0; i < assessment!.length; i++) {
      ref
          .read(assessmentMasterListNotifier.notifier)
          .addAssessment(assessment[i]);
    }
    return response;
  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});

final assessmentMasterListNotifier =
    StateNotifierProvider<AssessmentMasterNotifier, List<AssessmentMaster>>(
        (ref) {
  return AssessmentMasterNotifier();
});

final assessmentBody = StateProvider<Map>((ref) {
  return {};
});

final updateAssessmentBody = StateProvider<Map>((ref) {
  return {};
});

final deleteAssessmentBody = StateProvider<String>((ref) {
  return "";
});
