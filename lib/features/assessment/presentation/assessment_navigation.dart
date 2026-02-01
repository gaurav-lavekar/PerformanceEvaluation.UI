import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/common/widgets/notification_bar.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';
import 'package:perf_evaluation/features/assessment/application/assessment_provider.dart';
import 'package:perf_evaluation/features/assessment/models/assessment_master_model.dart';
import 'package:perf_evaluation/features/assessment/presentation/screens/assessment_list.dart';
import 'package:perf_evaluation/features/assessment/presentation/screens/new_assessment.dart';

import 'package:syn_multitenancy/login/presentation/widgets/loading_widget.dart';

class AssessmentNavigation extends ConsumerStatefulWidget {
  const AssessmentNavigation({super.key});
  @override
  ConsumerState<AssessmentNavigation> createState() {
    return _AssessmentNavigationState();
  }
}

class _AssessmentNavigationState extends ConsumerState<AssessmentNavigation> {
  bool _isGrid = true;
  String _recordType = "New";
  List<AssessmentMaster> _selectedAssessment = [];

  @override
  Widget build(BuildContext context) {
    void selectPage(bool flag, List<AssessmentMaster> selectedAssessment) {
      setState(() {
        _isGrid = flag;
        _selectedAssessment = selectedAssessment;
        if (selectedAssessment.isNotEmpty) {
          _recordType = "Edit";
        } else {
          _recordType = "New";
        }
      });
    }

    if (_isGrid) {
      final response = ref.watch(myAssessments);

      Widget contentSuccess() {
        return AssessmentList(
          onAdd: selectPage,
        );
      }

      Widget contentException(String msg) {
        showNotificationBar(NotificationTypes.error, msg).show(context);
        return contentSuccess();
      }

      return response.when(
          data: (data) => AssessmentList(onAdd: selectPage),
          error: (e, _) => contentException(e.toString()),
          loading: () => const LoadingDialogWidget());
    }

    return NewAssessment(
      onAdd: selectPage,
      selectedAssessment: _selectedAssessment,
      recordType: _recordType,
    );
  }
}
