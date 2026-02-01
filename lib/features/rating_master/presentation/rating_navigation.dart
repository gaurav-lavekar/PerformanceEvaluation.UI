import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/common/widgets/notification_bar.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';
import 'package:perf_evaluation/features/rating_master/application/ratings_provider.dart';
import 'package:perf_evaluation/features/rating_master/models/rating_master_model.dart';
import 'package:perf_evaluation/features/rating_master/presentation/screens/new_rating.dart';
import 'package:perf_evaluation/features/rating_master/presentation/screens/rating_list.dart';
import 'package:syn_multitenancy/login/presentation/widgets/loading_widget.dart';

class RatingNavigation extends ConsumerStatefulWidget {
  const RatingNavigation({super.key});
  @override
  ConsumerState<RatingNavigation> createState() {
    return _RatingNavigationState();
  }
}

class _RatingNavigationState extends ConsumerState<RatingNavigation> {
  bool _isGrid = true;
  String _recordType = "New";
  List<RatingMaster> _selectedRating = [];

  @override
  Widget build(BuildContext context) {
    void selectPage(bool flag, List<RatingMaster> selectedRating) {
      setState(() {
        _isGrid = flag;
        _selectedRating = selectedRating;
        if (selectedRating.isNotEmpty) {
          _recordType = "Edit";
        } else {
          _recordType = "New";
        }
      });
    }

    if (_isGrid) {
      final response = ref.watch(ratingMaster);

      Widget contentSuccess() {
        return RatingList(
          onAdd: selectPage,
        );
      }

      Widget contentException(String msg) {
        showNotificationBar(NotificationTypes.error, msg).show(context);
        return contentSuccess();
      }

      return response.when(
          data: (data) => RatingList(onAdd: selectPage),
          error: (e, _) => contentException(e.toString()),
          loading: () => const LoadingDialogWidget());
    }

    return NewRating(
      onAdd: selectPage,
      selectedRating: _selectedRating,
      recordType: _recordType,
    );
  }
}
