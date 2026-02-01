import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/common/widgets/notification_bar.dart';
import 'package:perf_evaluation/features/assessment/models/assessment_master_model.dart';
import 'package:perf_evaluation/features/employee_master/application/employee_provider.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';
import 'package:perf_evaluation/features/employee_master/models/employee_master_model.dart';
import 'package:perf_evaluation/features/reportees/application/reportee_assessment_provider.dart';
import 'package:perf_evaluation/features/reportees/presentation/screens/reportee_assessments.dart';
import 'package:perf_evaluation/features/reportees/presentation/screens/reportee_list.dart';
import 'package:perf_evaluation/features/reportees/presentation/screens/view_assessment.dart';

import 'package:syn_multitenancy/login/presentation/widgets/loading_widget.dart';

class ReporteesNavigation extends ConsumerStatefulWidget {
  const ReporteesNavigation({super.key});
  @override
  ConsumerState<ReporteesNavigation> createState() {
    return _ReporteeNavigationState();
  }
}

class _ReporteeNavigationState extends ConsumerState<ReporteesNavigation> {
  bool _isGrid = true;
  String pgName = "ReporteesGrid";
  String _recordType = "New";
  List<EmployeeMaster> _selectedEmployee = [];
  List<AssessmentMaster> _selectedAssessment = [];

  void selectPage(bool flag, List<EmployeeMaster> selectedEmployee,
      List<AssessmentMaster> selectedAssessment, String pageName) {
    setState(() {
      _isGrid = flag;
      pgName = pageName;
      _selectedAssessment = selectedAssessment;
      _selectedEmployee = selectedEmployee;
      if (selectedEmployee.isNotEmpty) {
        _recordType = "Edit";
      } else {
        _recordType = "New";
      }
    });
  }

  void viewAssessment(
      bool flag, List<AssessmentMaster> selectedAssessment, String pageName) {
    setState(() {
      _isGrid = flag;
      _selectedAssessment = selectedAssessment;
      pgName = pageName;
    });
  }

  Widget contentSuccess() {
    return ReporteeAssessments(
      onAdd: selectPage,
      onView: viewAssessment,
    );
  }

  Widget contentException(String msg) {
    showNotificationBar(NotificationTypes.error, msg).show(context);
    return contentSuccess();
  }

  @override
  Widget build(BuildContext context) {
    if (_isGrid && pgName == "ReporteesGrid") {
      final response = ref.watch(employeeMasterbyId);
      return response.when(
          data: (data) => ReporteeList(
                onAdd: selectPage,
                onView: viewAssessment,
              ),
          error: (e, _) => contentException(e.toString()),
          loading: () => const LoadingDialogWidget());
    }

    if (_isGrid && pgName == "EmployeeAssessmentGrid") {
      final response = ref.watch(reporteeAssessments);
      return response.when(
          data: (data) => contentSuccess(),
          error: (e, _) => contentException(e.toString()),
          loading: () => const LoadingDialogWidget());
    }

    return ViewAssessment(
      onAdd: selectPage,
      onView: viewAssessment,
      selectedAssessment: _selectedAssessment,
      selectedEmployee: _selectedEmployee,
      recordType: _recordType,
    );
  }
}
