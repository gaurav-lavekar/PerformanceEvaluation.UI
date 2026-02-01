import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';
import 'package:perf_evaluation/common/widgets/notification_bar.dart';
import 'package:perf_evaluation/features/employee_master/application/employee_provider.dart';
import 'package:perf_evaluation/features/my_goals/application/goal_provider.dart';
import 'package:perf_evaluation/features/my_goals/models/goal_master_model.dart';
import 'package:perf_evaluation/features/my_goals/presentation/goal_navigation.dart';
import 'package:syn_multitenancy/login/presentation/widgets/loading_widget.dart';

import 'package:syn_useraccess/common/utilities/app_settings.dart';
import 'package:syn_useraccess/common/widget/form_controls/accesscontrolledwidget.dart';

class GoalList extends ConsumerStatefulWidget {
  const GoalList({required this.onAdd, super.key});

  final void Function(bool flg, List<GoalMaster> selectedGoal) onAdd;

  @override
  ConsumerState<GoalList> createState() => _ExpandableState();
}

class _ExpandableState extends ConsumerState<GoalList> {
  final moduleName = 'O_MyGoals';
  List<GoalMaster> bm = [];

  final TextEditingController enteredSearch = TextEditingController();

  bool isDeleting = false;
  String _searchText = '';

  final bool _sortAsc = true;
  final int _sortColumnIndex = 1;
  String? selectedYear;
  bool isResolutionChanged = false;
  bool showCustomArrow = false;
  bool sortArrowsAlwaysVisible = false;

  late Future<void> combinedFuture;

  void removeItem(String id) async {
    try {
      ref.watch(deleteGoalBody.notifier).state = id;

      setState(() {
        isDeleting = true;
        isResolutionChanged = false;
      });
    } catch (e) {
      //error code
    }
  }

  @override
  void initState() {
    super.initState();
    initialData();
  }

  Future<void> initialData() async {
    List<Future> futures = [];
    if (ref.read(goalMasterListNotifier).isEmpty) {
      futures.add(ref.read(myGoals.future));
    }

    combinedFuture = Future.wait(futures);
    await combinedFuture;
  }

  @override
  void dispose() {
    enteredSearch.dispose();
    super.dispose();
  }

  void clearProvider() {
    try {
      ref.watch(goalstartdate.notifier).state = "";
      ref.watch(financialyear.notifier).state = "";
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool useMobileLayout = shortestSide < mobilewidth;
    Map userDetails = ref.read(loggedInUser);
    List<GoalMaster> goals = ref.read(goalMasterListNotifier);
    List<GoalMaster> searchList = [];

    if (_searchText != '') {
      var searchText = _searchText.toLowerCase();

      for (var c in goals) {
        if (c.goalPerspectiveName!.toLowerCase().contains(searchText) ||
            c.goalDescription!.toLowerCase().contains(searchText) ||
            c.goalMeasurementUnit!.toLowerCase().contains(searchText) ||
            c.goalStatus!.toLowerCase().contains(searchText) ||
            c.financialyear!.toLowerCase().contains(searchText) ||
            c.goalTargetValue!.toString().toLowerCase().contains(searchText)) {
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
              const SizedBox(width: 10),
              useMobileLayout
                  ? Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(30),
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: IconButton(
                        onPressed: () {
                          clearProvider();
                          setState(() {
                            widget.onAdd(false, []);
                          });
                        },
                        icon: Icon(
                          Icons.add,
                          size: 25,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
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
                          clearProvider();
                          setState(() {
                            widget.onAdd(false, []);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
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
            height: 10,
          ),
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
                  DataColumn2(label: Text('Period'), size: ColumnSize.M),
                  DataColumn2(label: Text('Target Value'), size: ColumnSize.S),
                  DataColumn2(label: Text('Status'), size: ColumnSize.S),
                  DataColumn2(label: Text('Created By'), size: ColumnSize.S),
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
                          DataCell(Text("${formatter.format(c.goalStartDate!)} "
                              "-"
                              " ${formatter.format(c.goalEndDate!)}")),
                          DataCell(Text(
                              "${c.goalTargetValue.toString()} ${c.goalMeasurementUnit}")),
                          DataCell(Text(c.goalStatus!)),
                          DataCell(Text(c.createdBy!)),
                          DataCell(Row(
                            children: [
                              AccessControlledWidget(
                                uiTag: moduleName,
                                permission: c.createdBy == userDetails['name']
                                    ? userAccessHelper.AccessWrite
                                    : "",
                                child: IconButton(
                                  onPressed: () {
                                    _buildOnEdit(c.goalDetailsId!);
                                  },
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                  ),
                                  tooltip: 'Edit',
                                ),
                              ),
                              AccessControlledWidget(
                                uiTag: moduleName,
                                permission: c.createdBy == userDetails['name']
                                    ? userAccessHelper.AccessDelete
                                    : "",
                                child: IconButton(
                                  onPressed: () {
                                    _buildOnDelete(c.goalDetailsId!);
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                  ),
                                  tooltip: 'Delete',
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
      return const GoalNavigation();
    }

    if (isDeleting) {
      if (isResolutionChanged) {
        return const GoalNavigation();
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

  void _buildOnEdit(String id) {
    final goallist = ref.watch(goalMasterListNotifier).where((element) {
      return (element.goalDetailsId == id);
    }).toList();

    widget.onAdd(false, goallist);
  }

  void _buildOnDelete(String id) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: Container(
          child: const Icon(
            Icons.help_sharp,
            size: 60,
            color: Colors.lightBlue,
          ),
        ),
        title: Text(
          'Confirm',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to delete this record?',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'No'),
            child: Text(
              'No',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                final goallist =
                    ref.watch(goalMasterListNotifier).where((element) {
                  return (element.goalDetailsId == id);
                }).toList();
                if (goallist.isNotEmpty) {
                  //removeItem('79a9bed2-d714-433f-9bf8-3d1593597356');
                  removeItem(goallist[0].goalDetailsId!);
                  Navigator.pop(context, 'Yes');
                } else {
                  showNotificationBar(
                          NotificationTypes.error, 'Something went wrong.')
                      .show(context);
                  Navigator.pop(context, 'Yes');
                }
              } catch (e) {
                //error code
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
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
