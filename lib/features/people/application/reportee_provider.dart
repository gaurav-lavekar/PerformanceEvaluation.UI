import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/features/my_goals/application/goal_provider.dart';
import 'package:perf_evaluation/features/my_goals/data/goal_repository.dart';

final Map<String, String> requestHeaders = {'Content-type': 'application/json'};

final reporteeGoals = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestbody = ref.read(reporteeId);
    final goalList = await ref
        .watch(goalMasterRepositoryProvider)
        .getGoalsbyId(requestBody: requestbody);

    final goal = goalList.goals;

    ref.watch(goalMasterListNotifier.notifier).clearGoal();

    for (var i = 0; i < goal!.length; i++) {
      ref.watch(goalMasterListNotifier.notifier).addGoal(goal[i]);
    }

    return 'Success';
  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});

final saveReporteeGoal = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.watch(goalBody);
    final employeeid = ref.watch(reporteeId);
    requestBody['employeeid'] = employeeid;

    final response = await ref
        .watch(goalMasterRepositoryProvider)
        .postGoal(requestBody: requestBody, requestHeaders: requestHeaders);

    final goalList = await ref
        .read(goalMasterRepositoryProvider)
        .getGoalsbyId(requestBody: employeeid);

    final goal = goalList.goals;

    ref.read(goalMasterListNotifier.notifier).clearGoal();

    for (var i = 0; i < goal!.length; i++) {
      ref.read(goalMasterListNotifier.notifier).addGoal(goal[i]);
    }
    return response;
  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});

final updateReporteeGoal = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.watch(updateGoalBody);

    final response = await ref
        .watch(goalMasterRepositoryProvider)
        .updateReporteeGoal(
            requestHeaders: requestHeaders, requestBody: requestBody);

    final goalList = await ref
        .read(goalMasterRepositoryProvider)
        .getGoalsbyId(requestBody: requestBody['employeeid']);

    final goal = goalList.goals;

    ref.read(goalMasterListNotifier.notifier).clearGoal();

    for (var i = 0; i < goal!.length; i++) {
      ref.read(goalMasterListNotifier.notifier).addGoal(goal[i]);
    }
    return response;
  } catch (e) {
    //print(e.toString());
    throw e.toString();
  }
});

final reporteeId = StateProvider<String>((ref) {
  return "";
});
