import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/common/widgets/notification_bar.dart';
import 'package:perf_evaluation/features/perspective_master/application/perspective_provider.dart';
import 'package:perf_evaluation/features/perspective_master/models/perspective_master_model.dart';
import 'package:perf_evaluation/features/perspective_master/presentation/screens/new_perspective.dart';
import 'package:perf_evaluation/features/perspective_master/presentation/screens/perspective_list.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';
import 'package:syn_multitenancy/login/presentation/widgets/loading_widget.dart';

class PerspectiveNavigation extends ConsumerStatefulWidget {
  const PerspectiveNavigation({super.key});
  @override
  ConsumerState<PerspectiveNavigation> createState() {
    return _PerspectiveNavigationState();
  }
}

class _PerspectiveNavigationState extends ConsumerState<PerspectiveNavigation> {
  bool _isGrid = true;
  String _recordType = "New";
  List<PerspectiveMaster> _selectedPerspective = [];

  @override
  Widget build(BuildContext context) {
    void selectPage(bool flag, List<PerspectiveMaster> selectedPerspective) {
      setState(() {
        _isGrid = flag;
        _selectedPerspective = selectedPerspective;
        if (selectedPerspective.isNotEmpty) {
          _recordType = "Edit";
        } else {
          _recordType = "New";
        }
      });
    }

    if (_isGrid) {
      final response = ref.watch(perspectiveMaster);

      Widget contentSuccess() {
        return PerspectiveList(
          onAdd: selectPage,
        );
      }

      Widget contentException(String msg) {
        showNotificationBar(NotificationTypes.error, msg).show(context);
        return contentSuccess();
      }

      return response.when(
          data: (data) => PerspectiveList(onAdd: selectPage),
          error: (e, _) => contentException(e.toString()),
          loading: () => const LoadingDialogWidget());
    }

    return NewPerspective(
      onAdd: selectPage,
      selectedPerspective: _selectedPerspective,
      recordType: _recordType,
    );
  }
}
