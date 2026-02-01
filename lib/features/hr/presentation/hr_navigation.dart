import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/common/widgets/notification_bar.dart';
import 'package:perf_evaluation/features/assessment/models/assessment_master_model.dart';
import 'package:perf_evaluation/features/employee_master/application/employee_provider.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';
import 'package:perf_evaluation/features/employee_master/models/employee_master_model.dart';
import 'package:perf_evaluation/features/hr/application/appraisal_provider.dart';
import 'package:perf_evaluation/features/hr/presentation/screens/employee_appraisals.dart';
import 'package:perf_evaluation/features/hr/presentation/screens/employee_screen.dart';
import 'package:perf_evaluation/features/hr/presentation/screens/view_appraisal.dart';

import 'package:syn_multitenancy/login/presentation/widgets/loading_widget.dart';

class HRNavigation extends ConsumerStatefulWidget {
  const HRNavigation({super.key});
  @override
  ConsumerState<HRNavigation> createState() {
    return _PeopleNavigationState();
  }
}

class _PeopleNavigationState extends ConsumerState<HRNavigation> {
  bool _isGrid = true;
  String pgName = "EmployeeGrid";
  String _recordType = "New";
  List<EmployeeMaster> _selectedEmployee = [];
  List<AssessmentMaster> _selectedAppraisals = [];

  void selectPage(bool flag, List<EmployeeMaster> selectedEmployee,
      List<AssessmentMaster> selectedAppraisal, String pageName) {
    setState(() {
      _isGrid = flag;
      pgName = pageName;
      _selectedAppraisals = selectedAppraisal;
      _selectedEmployee = selectedEmployee;
      if (selectedEmployee.isNotEmpty) {
        _recordType = "Edit";
      } else {
        _recordType = "New";
      }
    });
  }

  void viewAppraisals(
      bool flag, List<AssessmentMaster> selectedAppraisal, String pageName) {
    setState(() {
      _isGrid = flag;
      _selectedAppraisals = selectedAppraisal;
      pgName = pageName;
    });
  }

  Widget contentSuccess() {
    return EmployeeAppraisals(
      onAdd: selectPage,
      onView: viewAppraisals,
    );
  }

  Widget contentException(String msg) {
    showNotificationBar(NotificationTypes.error, msg).show(context);
    return contentSuccess();
  }

  @override
  Widget build(BuildContext context) {
    if (_isGrid && pgName == "EmployeeGrid") {
      final response = ref.watch(employeeMaster);
      return response.when(
          data: (data) => EmployeeScreen(
                onAdd: selectPage,
                onView: viewAppraisals,
              ),
          error: (e, _) => contentException(e.toString()),
          loading: () => const LoadingDialogWidget());
    }

    if (_isGrid && pgName == "EmployeeAppraisalsGrid") {
      final response = ref.watch(employeeAssessments);
      return response.when(
          data: (data) => contentSuccess(),
          error: (e, _) => contentException(e.toString()),
          loading: () => const LoadingDialogWidget());
    }

    return ViewAppraisal(
      onAdd: selectPage,
      onView: viewAppraisals,
      selectedAssessment: _selectedAppraisals,
      selectedEmployee: _selectedEmployee,
      recordType: _recordType,
    );
  }
}
