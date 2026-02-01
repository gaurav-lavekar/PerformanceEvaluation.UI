import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/common/widgets/notification_bar.dart';
import 'package:perf_evaluation/features/category_master/application/category_provider.dart';
import 'package:perf_evaluation/features/category_master/models/category_master_model.dart';
import 'package:perf_evaluation/features/category_master/presentation/screen/category_list.dart';
import 'package:perf_evaluation/features/category_master/presentation/screen/new_category.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';
import 'package:syn_multitenancy/login/presentation/widgets/loading_widget.dart';

class CategoryNavigation extends ConsumerStatefulWidget {
  const CategoryNavigation({super.key});
  @override
  ConsumerState<CategoryNavigation> createState() {
    return _CategoryNavigationState();
  }
}

class _CategoryNavigationState extends ConsumerState<CategoryNavigation> {
  bool _isGrid = true;
  String _recordType = "New";
  List<CategoryMaster> _selectedCategory = [];

  @override
  Widget build(BuildContext context) {
    void selectPage(bool flag, List<CategoryMaster> selectedCategory) {
      setState(() {
        _isGrid = flag;
        _selectedCategory = selectedCategory;
        if (selectedCategory.isNotEmpty) {
          _recordType = "Edit";
        } else {
          _recordType = "New";
        }
      });
    }

    if (_isGrid) {
      final response = ref.watch(categoryMaster);

      Widget contentSuccess() {
        return CategoryList(
          onAdd: selectPage,
        );
      }

      Widget contentException(String msg) {
        showNotificationBar(NotificationTypes.error, msg).show(context);
        return contentSuccess();
      }

      return response.when(
          data: (data) => CategoryList(onAdd: selectPage),
          error: (e, _) => contentException(e.toString()),
          loading: () => const LoadingDialogWidget());
    }

    return NewCategory(
      onAdd: selectPage,
      selectedCategory: _selectedCategory,
      recordType: _recordType,
    );
  }
}
