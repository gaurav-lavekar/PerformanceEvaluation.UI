import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/features/my_goals/data/goal_repository.dart';
import 'package:perf_evaluation/features/my_goals/models/goal_master_model.dart';

final Map<String, String> requestHeaders = {'Content-type': 'application/json'};

final goalMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final goalList = await ref.watch(goalMasterRepositoryProvider).getGoals();

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

final myGoals = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestbody = ref.read(employeeId);
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

final saveGoalMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.watch(goalBody);
    final employeeid = ref.watch(employeeId);
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

final updateGoalMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.watch(updateGoalBody);

    final response = await ref
        .watch(goalMasterRepositoryProvider)
        .updateGoal(requestHeaders: requestHeaders, requestBody: requestBody);

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

final deleteGoalMaster = FutureProvider.autoDispose<String>((ref) async {
  try {
    final requestBody = ref.watch(deleteGoalBody);
    final response = await ref
        .watch(goalMasterRepositoryProvider)
        .deleteGoal(requestBody: requestBody, requestHeaders: requestHeaders);

    final goalList = await ref
        .read(goalMasterRepositoryProvider)
        .getGoalsbyId(requestBody: ref.watch(employeeId));

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

final goalMasterListNotifier =
    StateNotifierProvider<GoalMasterNotifier, List<GoalMaster>>((ref) {
  return GoalMasterNotifier();
});

final goalBody = StateProvider<Map>((ref) {
  return {};
});

final employeeId = StateProvider<String>((ref) {
  return "";
});

final financialyear = StateProvider<String>((ref) {
  return "";
});

final goalstartdate = StateProvider<String>((ref) {
  return "";
});

final updateGoalBody = StateProvider<Map>((ref) {
  return {};
});

final deleteGoalBody = StateProvider<String>((ref) {
  return "";
});
