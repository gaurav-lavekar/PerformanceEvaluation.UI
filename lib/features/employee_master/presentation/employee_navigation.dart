import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/common/widgets/notification_bar.dart';
import 'package:perf_evaluation/features/employee_master/application/employee_provider.dart';
import 'package:perf_evaluation/features/employee_master/models/employee_master_model.dart';
import 'package:perf_evaluation/features/employee_master/presentation/screens/new_employee.dart';
import 'package:perf_evaluation/features/employee_master/presentation/screens/employee_list.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';
import 'package:syn_multitenancy/login/presentation/widgets/loading_widget.dart';

class EmployeeNavigation extends ConsumerStatefulWidget {
  const EmployeeNavigation({super.key});
  @override
  ConsumerState<EmployeeNavigation> createState() {
    return _EmployeeNavigationState();
  }
}

class _EmployeeNavigationState extends ConsumerState<EmployeeNavigation> {
  bool _isGrid = true;
  String _recordType = "New";
  List<EmployeeMaster> _selectedEmployee = [];

  @override
  Widget build(BuildContext context) {
    void selectPage(bool flag, List<EmployeeMaster> selectedEmployee) {
      setState(() {
        _isGrid = flag;
        _selectedEmployee = selectedEmployee;
        if (selectedEmployee.isNotEmpty) {
          _recordType = "Edit";
        } else {
          _recordType = "New";
        }
      });
    }

    if (_isGrid) {
      final response = ref.watch(employeeMaster);

      Widget contentSuccess() {
        return EmployeeList(
          onAdd: selectPage,
        );
      }

      Widget contentException(String msg) {
        showNotificationBar(NotificationTypes.error, msg).show(context);
        return contentSuccess();
      }

      return response.when(
          data: (data) => EmployeeList(onAdd: selectPage),
          error: (e, _) => contentException(e.toString()),
          loading: () => const LoadingDialogWidget());
    }

    return NewEmployee(
      onAdd: selectPage,
      selectedEmployee: _selectedEmployee,
      recordType: _recordType,
    );
  }
}
