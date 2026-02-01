import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/common/widgets/notification_bar.dart';
import 'package:perf_evaluation/features/financial_year/application/financialyear_provider.dart';
import 'package:perf_evaluation/features/financial_year/models/financialyear_model.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';
import 'package:perf_evaluation/features/financial_year/presentation/screens/financialyear_list.dart';
import 'package:syn_multitenancy/login/presentation/widgets/loading_widget.dart';

import 'screens/new_financialyear.dart';

class FinancialYearNavigation extends ConsumerStatefulWidget {
  const FinancialYearNavigation({super.key});
  @override
  ConsumerState<FinancialYearNavigation> createState() {
    return _FinancialYearNavigationState();
  }
}

class _FinancialYearNavigationState
    extends ConsumerState<FinancialYearNavigation> {
  bool _isGrid = true;
  String _recordType = "New";
  List<FinancialYearMaster> _selectedFinancialYear = [];

  @override
  Widget build(BuildContext context) {
    void selectPage(
        bool flag, List<FinancialYearMaster> selectedFinancialYear) {
      setState(() {
        _isGrid = flag;
        _selectedFinancialYear = selectedFinancialYear;
        if (selectedFinancialYear.isNotEmpty) {
          _recordType = "Edit";
        } else {
          _recordType = "New";
        }
      });
    }

    if (_isGrid) {
      final response = ref.watch(financialyearMaster);

      Widget contentSuccess() {
        return FinancialYearList(
          onAdd: selectPage,
        );
      }

      Widget contentException(String msg) {
        showNotificationBar(NotificationTypes.error, msg).show(context);
        return contentSuccess();
      }

      return response.when(
          data: (data) => FinancialYearList(onAdd: selectPage),
          error: (e, _) => contentException(e.toString()),
          loading: () => const LoadingDialogWidget());
    }

    return NewFinancialYear(
      onAdd: selectPage,
      selectedFinancialYear: _selectedFinancialYear,
      recordType: _recordType,
    );
  }
}
