import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/common/widgets/notification_bar.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';
import 'package:perf_evaluation/features/my_goals/application/goal_provider.dart';
import 'package:perf_evaluation/features/my_goals/models/goal_master_model.dart';
import 'package:perf_evaluation/features/my_goals/presentation/screens/goal_list.dart';
import 'package:perf_evaluation/features/my_goals/presentation/screens/new_goal.dart';

import 'package:syn_multitenancy/login/presentation/widgets/loading_widget.dart';

class GoalNavigation extends ConsumerStatefulWidget {
  const GoalNavigation({super.key});
  @override
  ConsumerState<GoalNavigation> createState() {
    return _GoalNavigationState();
  }
}

class _GoalNavigationState extends ConsumerState<GoalNavigation> {
  bool _isGrid = true;
  String _recordType = "New";
  List<GoalMaster> _selectedGoal = [];

  @override
  Widget build(BuildContext context) {
    void selectPage(bool flag, List<GoalMaster> selectedGoal) {
      setState(() {
        _isGrid = flag;
        _selectedGoal = selectedGoal;
        if (selectedGoal.isNotEmpty) {
          _recordType = "Edit";
        } else {
          _recordType = "New";
        }
      });
    }

    if (_isGrid) {
      final response = ref.watch(myGoals);

      Widget contentSuccess() {
        return GoalList(
          onAdd: selectPage,
        );
      }

      Widget contentException(String msg) {
        showNotificationBar(NotificationTypes.error, msg).show(context);
        return contentSuccess();
      }

      return response.when(
          data: (data) => GoalList(onAdd: selectPage),
          error: (e, _) => contentException(e.toString()),
          loading: () => const LoadingDialogWidget());
    }

    return NewGoal(
      onAdd: selectPage,
      selectedGoal: _selectedGoal,
      recordType: _recordType,
    );
  }
}
