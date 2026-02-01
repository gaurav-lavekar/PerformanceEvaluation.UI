import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/features/assessment/application/assessment_provider.dart';
import 'package:perf_evaluation/features/assessment/data/assessment_repository.dart';

final Map<String, String> requestHeaders = {'Content-type': 'application/json'};

final employeeAssessments = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestbody = ref.read(hrProvider);
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

final hrProvider = StateProvider<String>((ref) {
  return "";
});
