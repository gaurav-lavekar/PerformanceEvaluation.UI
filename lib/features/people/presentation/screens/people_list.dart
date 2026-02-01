import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';
import 'package:perf_evaluation/common/widgets/notification_bar.dart';
import 'package:perf_evaluation/features/employee_master/application/employee_provider.dart';
import 'package:perf_evaluation/features/employee_master/models/employee_master_model.dart';
import 'package:perf_evaluation/features/my_goals/application/goal_provider.dart';
import 'package:perf_evaluation/features/my_goals/models/goal_master_model.dart';
import 'package:perf_evaluation/features/people/application/reportee_provider.dart';
import 'package:perf_evaluation/features/people/presentation/people_navigation.dart';
import 'package:syn_multitenancy/login/presentation/widgets/loading_widget.dart';

class PeopleList extends ConsumerStatefulWidget {
  const PeopleList({required this.onAdd, required this.onView, super.key});

  final void Function(bool flg, List<EmployeeMaster> selectedPeople,
      List<GoalMaster> selectedGoal, String selectedPage) onAdd;

  final void Function(
      bool flg, List<GoalMaster> selectedGoals, String selectedPage) onView;

  @override
  ConsumerState<PeopleList> createState() => _ExpandableState();
}

class _ExpandableState extends ConsumerState<PeopleList> {
  final moduleName = 'O_MyPeople';
  List<EmployeeMaster> bm = [];

  final TextEditingController enteredSearch = TextEditingController();

  bool isDeleting = false;
  String _searchText = '';

  final bool _sortAsc = true;
  final int _sortColumnIndex = 1;

  bool isResolutionChanged = false;
  bool showCustomArrow = false;
  bool sortArrowsAlwaysVisible = false;

  late Future<void> combinedFuture;

  @override
  void initState() {
    super.initState();
    initialData();
  }

  @override
  void dispose() {
    enteredSearch.dispose();
    super.dispose();
  }

  Future<void> initialData() async {
    List<Future> future = [];
    future.add(ref.read(employeeMasterbyId.future));

    combinedFuture = Future.wait(future);
    await combinedFuture;
  }

  @override
  Widget build(BuildContext context) {
    List<EmployeeMaster> empmaster = ref.read(employeeMasterListNotifier);
    List<EmployeeMaster> people = empmaster[0].reportees!;
    List<EmployeeMaster> searchList = [];

    if (_searchText != '') {
      var searchText = _searchText.toLowerCase();

      for (var c in people) {
        if (c.firstName!.toLowerCase().contains(searchText) ||
            c.lastName!.toLowerCase().contains(searchText)) {
          searchList.add(c);
        }
      }
      people = searchList;
    }

    Widget content = Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (KeyEvent event) {
                    setState(() {
                      _searchText = enteredSearch.text;
                    });
                  },
                  child: TextFormField(
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.onPrimary,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _searchText = enteredSearch.text;
                          });
                        },
                        icon: const Icon(
                          Icons.search,
                          size: 20,
                        ),
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    controller: enteredSearch,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.zero,
              child: DataTable2(
                headingRowColor: WidgetStateColor.resolveWith(
                    (states) => Theme.of(context).colorScheme.primaryContainer),
                headingTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer),

                isHorizontalScrollBarVisible: true,
                isVerticalScrollBarVisible: true,
                columnSpacing: 12,
                horizontalMargin: 12,
                sortArrowBuilder: (ascending, sorted) => sorted
                    ? Padding(
                        padding: const EdgeInsets.only(right: 0),
                        child: _SortIcon(ascending: sorted, active: ascending))
                    : null,

                dividerThickness:
                    1, // this one will be ignored if [border] is set above
                bottomMargin: 10,
                minWidth: 900,
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAsc,
                fixedLeftColumns: 0,

                sortArrowAnimationDuration: const Duration(milliseconds: 500),
                columns: const [
                  DataColumn2(
                    label: Text(
                      'Employee ID',
                    ),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: Text(
                      'Employee Name',
                    ),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    size: ColumnSize.L,
                    label: Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Text(
                        'Action',
                      ),
                    ),
                  ),
                ],
                rows: people
                    .map(
                      (c) => DataRow(
                        cells: [
                          DataCell(Text(c.empid!)),
                          DataCell(Text("${c.firstName} ${c.lastName}")),
                          DataCell(
                            IconButton(
                              onPressed: () {
                                final goalList = ref
                                    .read(goalMasterListNotifier)
                                    .where((g) => g.employeeId == c.employeeId)
                                    .toList();

                                ref.watch(reporteeId.notifier).state =
                                    c.employeeId!;
                                widget.onView(
                                    true, goalList, "EmployeeGoalsGrid");
                              },
                              icon: const Icon(
                                Icons.visibility,
                                size: 20,
                              ),
                              tooltip: 'View Goals',
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );

    Widget contentLoading = Stack(
      children: [
        content,
        const Center(child: LoadingDialogWidget()),
      ],
    );

    Widget contentException(String msg) {
      showNotificationBar(NotificationTypes.error, msg).show(context);
      setState(() {
        isDeleting = false;
      });
      return content;
    }

    contentSuccess(String msg) {
      showNotificationBar(NotificationTypes.success, msg).show(context);
      setState(() {
        isResolutionChanged = true;
      });
      return const PeopleNavigation();
    }

    if (isDeleting) {
      if (isResolutionChanged) {
        return const PeopleNavigation();
      }
      final response = ref.watch(deleteEmployeeMaster);
      return response.when(
        loading: () => contentLoading,
        error: (err, stack) => contentException('Error: $err'),
        data: (config) => contentSuccess(response.value!),
      );
    } else {
      return content;
    }
  }
}

class _SortIcon extends StatelessWidget {
  final bool ascending;
  final bool active;

  const _SortIcon({required this.ascending, required this.active});

  @override
  Widget build(BuildContext context) {
    return Icon(
      ascending
          ? active
              ? Icons.keyboard_arrow_up
              : Icons.keyboard_arrow_down
          : null,
      size: 18,
      color: const Color.fromARGB(255, 2, 146, 164),
    );
  }
}
