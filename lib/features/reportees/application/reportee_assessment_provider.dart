import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/features/assessment/application/assessment_provider.dart';
import 'package:perf_evaluation/features/assessment/data/assessment_repository.dart';
import 'package:perf_evaluation/features/people/application/reportee_provider.dart';

final Map<String, String> requestHeaders = {'Content-type': 'application/json'};

final reporteeAssessments = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestbody = ref.read(reporteeId);
    final appraisalList = await ref
        .watch(assessmentMasterRepositoryProvider)
        .getAssessmentsbyId(requestBody: requestbody);

    final assessments = appraisalList.assessments;

    ref.watch(assessmentMasterListNotifier.notifier).clearAssessment();

    for (var i = 0; i < assessments!.length; i++) {
      ref
          .watch(assessmentMasterListNotifier.notifier)
          .addAssessment(assessments[i]);
    }

    return 'Success';
  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});

final updateReporteeAssessment =
    FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.watch(updateAssessmentBody);

    final response = await ref
        .watch(assessmentMasterRepositoryProvider)
        .updateAssessment(
            requestHeaders: requestHeaders, requestBody: requestBody);

    final assessmentList = await ref
        .read(assessmentMasterRepositoryProvider)
        .getAssessmentsbyId(requestBody: requestBody['employeeid']);

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
