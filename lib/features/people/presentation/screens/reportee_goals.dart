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
import 'package:syn_form_fields/syn_form_fields.dart';
import 'package:syn_multitenancy/login/presentation/widgets/loading_widget.dart';
import 'package:syn_useraccess/common/utilities/app_settings.dart';

import 'package:syn_useraccess/common/widget/form_controls/accesscontrolledwidget.dart';

class ReporteeGoals extends ConsumerStatefulWidget {
  const ReporteeGoals({required this.onAdd, required this.onView, super.key});

  final void Function(bool flg, List<EmployeeMaster> reportee,
      List<GoalMaster> selectedGoal, String pageName) onAdd;

  final void Function(bool flg, List<GoalMaster> selectedGoal, String pgName)
      onView;

  @override
  ConsumerState<ReporteeGoals> createState() => _ExpandableState();
}

class _ExpandableState extends ConsumerState<ReporteeGoals> {
  final moduleName = 'O_MyPeople';
  List<GoalMaster> bm = [];

  final TextEditingController enteredSearch = TextEditingController();
  final TextEditingController enteredEmployee = TextEditingController();

  bool isDeleting = false;
  String _searchText = '';
  // final bool _sortNameAsc = true;
  // final bool _sortAgeAsc = true;
  // final bool _sortHightAsc = true;
  final bool _sortAsc = true;
  final int _sortColumnIndex = 1;
  String? selectedYear;
  bool isResolutionChanged = false;
  // bool _initialized = false;
  bool showCustomArrow = false;
  bool sortArrowsAlwaysVisible = false;

  late Future<void> combinedFuture;

  @override
  void initState() {
    super.initState();
    reporteeData();
  }

  @override
  void dispose() {
    enteredSearch.dispose();
    super.dispose();
  }

  Future<void> reporteeData() async {
    List<Future> futures = [];

    futures.add(ref.read(reporteeGoals.future));

    futures.add(ref.read(employeeMaster.future));

    combinedFuture = Future.wait(futures);
    await combinedFuture;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: combinedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while _loadUserAccess is still running
            return const LoadingDialogWidget();
          } else if (snapshot.hasError) {
            // Show a loading indicator while _loadUserAccess is still running
            showNotificationBar(
                    NotificationTypes.error, 'Error getting reportee goals')
                .show(context);
            return const SizedBox.shrink();
          } else {
            var shortestSide = MediaQuery.of(context).size.shortestSide;
            final bool useMobileLayout = shortestSide < mobilewidth;

            final employee = ref
                .read(employeeMasterListNotifier)
                .where((element) => element.employeeId == ref.read(reporteeId))
                .toList();

            enteredEmployee.text =
                '${employee.first.firstName} ${employee.first.lastName}';

            List<GoalMaster> goals = ref.read(goalMasterListNotifier).toList();
            List<GoalMaster> searchList = [];

            if (_searchText != '') {
              var searchText = _searchText.toLowerCase();

              for (var c in goals) {
                if (c.goalPerspectiveName!.toLowerCase().contains(searchText) ||
                    c.goalDescription!.toLowerCase().contains(searchText) ||
                    c.goalMeasurementUnit!.toLowerCase().contains(searchText) ||
                    c.goalTargetValue!
                        .toString()
                        .toLowerCase()
                        .contains(searchText)) {
                  searchList.add(c);
                }
              }
              goals = searchList;
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
                              fillColor:
                                  Theme.of(context).colorScheme.onPrimary,
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
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                            controller: enteredSearch,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      useMobileLayout
                          ? Material(
                              elevation: 3,
                              borderRadius: BorderRadius.circular(30),
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    widget.onAdd(false, [], [], "NewGoal");
                                  });
                                },
                                icon: Icon(
                                  Icons.add,
                                  size: 25,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                                tooltip: "Add Goal",
                              ),
                            )
                          : AccessControlledWidget(
                              uiTag: moduleName,
                              permission: userAccessHelper.AccessWrite,
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.add,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer),
                                onPressed: () {
                                  setState(() {
                                    widget.onAdd(false, [], [], "NewGoal");
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                                label: Text(
                                  'Add Goal',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer),
                                ),
                              ),
                            ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: 300,
                    child: Tooltip(
                      message: enteredEmployee.text,
                      child: InputControl(
                        columnLabel: 'Employee Name',
                        filledColor: Colors.white,
                        columnEnteredValue: enteredEmployee,
                        isMandatory: false,
                        isReadOnly: true,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: DataTable2(
                        headingRowColor: WidgetStateColor.resolveWith(
                            (states) =>
                                Theme.of(context).colorScheme.primaryContainer),
                        headingTextStyle: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer),
                        isHorizontalScrollBarVisible: true,
                        isVerticalScrollBarVisible: true,
                        columnSpacing: 12,
                        horizontalMargin: 12,
                        sortArrowBuilder: (ascending, sorted) => sorted
                            ? Padding(
                                padding: const EdgeInsets.only(right: 0),
                                child: _SortIcon(
                                    ascending: sorted, active: ascending))
                            : null,

                        dividerThickness:
                            1, // this one will be ignored if [border] is set above
                        bottomMargin: 10,
                        minWidth: 900,
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _sortAsc,
                        fixedLeftColumns: 0,

                        sortArrowAnimationDuration:
                            const Duration(milliseconds: 500),
                        columns: const [
                          DataColumn2(
                            label: Text(
                              'Financial Year',
                            ),
                            size: ColumnSize.S,
                          ),
                          DataColumn2(
                            label: Text(
                              'Goal Perspective',
                            ),
                            size: ColumnSize.M,
                          ),
                          DataColumn2(
                            label: Text(
                              'Description',
                            ),
                            size: ColumnSize.L,
                          ),
                          DataColumn2(
                              label: Text('Period'), size: ColumnSize.M),
                          DataColumn2(
                              label: Text('Target Value'), size: ColumnSize.S),
                          DataColumn2(
                              label: Text('Status'), size: ColumnSize.S),
                          DataColumn2(
                              label: Text('Created By'), size: ColumnSize.S),
                          DataColumn2(
                            size: ColumnSize.S,
                            label: Padding(
                              padding: EdgeInsets.only(left: 15.0),
                              child: Text(
                                'Action',
                              ),
                            ),
                          ),
                        ],
                        rows: goals
                            .map(
                              (c) => DataRow(
                                cells: [
                                  DataCell(Text(c.financialyear!)),
                                  DataCell(Text(c.goalPerspectiveName!)),
                                  DataCell(Text(c.goalDescription!)),
                                  DataCell(Text(
                                      "${formatter.format(c.goalStartDate!)} "
                                      "-"
                                      " ${formatter.format(c.goalEndDate!)}")),
                                  DataCell(Text(
                                      "${c.goalTargetValue.toString()}  ${c.goalMeasurementUnit}")),
                                  DataCell(Text(c.goalStatus!)),
                                  DataCell(Text(c.createdBy!)),
                                  DataCell(Row(
                                    children: [
                                      AccessControlledWidget(
                                        uiTag: moduleName,
                                        permission:
                                            userAccessHelper.AccessWrite,
                                        child: IconButton(
                                          onPressed: () {
                                            _buildOnEdit(c.goalDetailsId!,
                                                c.employeeId!);
                                          },
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 20,
                                          ),
                                          tooltip: 'Edit',
                                        ),
                                      ),
                                    ],
                                  )),
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
                const Center(child: CircularProgressIndicator()),
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
              widget.onAdd(true, employee, goals, "EmployeeGoalsGrid");
              return const PeopleNavigation();
            }

            if (isDeleting) {
              if (isResolutionChanged) {
                return const PeopleNavigation();
              }
              final response = ref.watch(deleteGoalMaster);
              return response.when(
                loading: () => contentLoading,
                error: (err, stack) => contentException('Error: $err'),
                data: (config) => contentSuccess(response.value!),
              );
            } else {
              return content;
            }
          }
        });
  }

  void _buildOnEdit(String goalId, String reporteeId) {
    final reportee = ref
        .watch(employeeMasterListNotifier)
        .where((element) => element.employeeId == reporteeId)
        .toList();

    final goalList = ref.watch(goalMasterListNotifier).where((element) {
      return (element.goalDetailsId == goalId);
    }).toList();

    widget.onAdd(false, reportee, goalList, "NewGoal");
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
