import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/common/widgets/notification_bar.dart';
import 'package:perf_evaluation/features/employee_master/application/employee_provider.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';
import 'package:perf_evaluation/features/employee_master/models/employee_master_model.dart';
import 'package:perf_evaluation/features/my_goals/models/goal_master_model.dart';
import 'package:perf_evaluation/features/people/application/reportee_provider.dart';
import 'package:perf_evaluation/features/people/presentation/screens/people_list.dart';
import 'package:perf_evaluation/features/people/presentation/screens/people_new_goal.dart';
import 'package:perf_evaluation/features/people/presentation/screens/reportee_goals.dart';

import 'package:syn_multitenancy/login/presentation/widgets/loading_widget.dart';

class PeopleNavigation extends ConsumerStatefulWidget {
  const PeopleNavigation({this.isGoalUpdated = false, super.key});
  @override
  ConsumerState<PeopleNavigation> createState() {
    return _PeopleNavigationState();
  }

  final bool isGoalUpdated;
}

class _PeopleNavigationState extends ConsumerState<PeopleNavigation> {
  bool _isGrid = true;
  String pgName = "ReporteesGrid";
  String _recordType = "New";
  List<EmployeeMaster> _selectedEmployee = [];
  List<GoalMaster> _selectedGoals = [];

  void selectPage(bool flag, List<EmployeeMaster> selectedEmployee,
      List<GoalMaster> selectedGoal, String pageName) {
    setState(() {
      _isGrid = flag;
      pgName = pageName;
      _selectedGoals = selectedGoal;
      _selectedEmployee = selectedEmployee;
      if (selectedEmployee.isNotEmpty) {
        _recordType = "Edit";
      } else {
        _recordType = "New";
      }
    });
  }

  void viewGoals(bool flag, List<GoalMaster> selectedGoals, String pageName) {
    setState(() {
      _isGrid = flag;
      _selectedGoals = selectedGoals;
      pgName = pageName;
    });
  }

  Widget contentSuccess() {
    return ReporteeGoals(
      onAdd: selectPage,
      onView: viewGoals,
    );
  }

  Widget contentException(String msg) {
    showNotificationBar(NotificationTypes.error, msg).show(context);
    return contentSuccess();
  }

  @override
  Widget build(BuildContext context) {
    if (pgName == "ReporteesGrid" && widget.isGoalUpdated == true) {
      pgName = "EmployeeGoalsGrid";
    }

    if (_isGrid && pgName == "ReporteesGrid") {
      final response = ref.watch(employeeMasterbyId);
      return response.when(
          data: (data) => PeopleList(
                onAdd: selectPage,
                onView: viewGoals,
              ),
          error: (e, _) => contentException(e.toString()),
          loading: () => const LoadingDialogWidget());
    }

    if (_isGrid && pgName == "EmployeeGoalsGrid") {
      final response = ref.watch(reporteeGoals);
      return response.when(
          data: (data) => contentSuccess(),
          error: (e, _) => contentException(e.toString()),
          loading: () => const LoadingDialogWidget());
    }

    return NewPeopleGoal(
      onAdd: selectPage,
      onView: viewGoals,
      selectedGoal: _selectedGoals,
      selectedEmployee: _selectedEmployee,
      recordType: _recordType,
    );
  }
}
