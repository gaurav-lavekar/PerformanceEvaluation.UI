import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';
import 'package:perf_evaluation/common/widgets/notification_bar.dart';
import 'package:perf_evaluation/features/employee_master/application/employee_provider.dart';
import 'package:perf_evaluation/features/employee_master/models/employee_master_model.dart';
import 'package:perf_evaluation/features/employee_master/presentation/employee_navigation.dart';
import 'package:syn_multitenancy/login/presentation/widgets/loading_widget.dart';

import 'package:syn_useraccess/common/utilities/app_settings.dart';
import 'package:syn_useraccess/common/widget/form_controls/accesscontrolledwidget.dart';

class EmployeeList extends ConsumerStatefulWidget {
  const EmployeeList({required this.onAdd, super.key});

  final void Function(bool flg, List<EmployeeMaster> selectedEmployee) onAdd;

  @override
  ConsumerState<EmployeeList> createState() => _ExpandableState();
}

class _ExpandableState extends ConsumerState<EmployeeList> {
  final moduleName = 'O_Employee';
  List<EmployeeMaster> bm = [];

  final TextEditingController enteredSearch = TextEditingController();

  bool isDeleting = false;
  String _searchText = '';
  // final bool _sortNameAsc = true;
  // final bool _sortAgeAsc = true;
  // final bool _sortHightAsc = true;
  final bool _sortAsc = true;
  final int _sortColumnIndex = 1;

  bool isResolutionChanged = false;
  // bool _initialized = false;
  bool showCustomArrow = false;
  bool sortArrowsAlwaysVisible = false;

  void removeItem(String id) async {
    try {
      ref.watch(deleteEmployeeBody.notifier).state = id;

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
  }

  @override
  void dispose() {
    enteredSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool useMobileLayout = shortestSide < mobilewidth;
    ref.watch(employeeMaster.future);
    List<EmployeeMaster> employees = ref.watch(employeeMasterListNotifier);
    List<EmployeeMaster> searchList = [];

    if (_searchText != '') {
      var searchText = _searchText.toLowerCase();

      for (var c in employees) {
        if (c.firstName!.toLowerCase().contains(searchText) ||
            c.lastName!.toLowerCase().contains(searchText)) {
          searchList.add(c);
        }
      }
      employees = searchList;
    }

    Widget content = Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              //const Spacer(),
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
                          'Add Employee',
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
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.zero,
              child: DataTable2(
                headingRowColor: WidgetStateColor.resolveWith(
                    (states) => Theme.of(context).colorScheme.primaryContainer),
                headingTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer),

                isHorizontalScrollBarVisible: false,
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
                      'First Name',
                    ),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text(
                      'Last Name',
                    ),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    size: ColumnSize.M,
                    label: Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Text(
                        'Action',
                      ),
                    ),
                  ),
                ],
                rows: employees
                    .map(
                      (c) => DataRow(
                        cells: [
                          DataCell(Text(c.firstName!)),
                          DataCell(Text(c.lastName!)),
                          DataCell(Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  _buildOnEdit(c.employeeId!);
                                },
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                ),
                                tooltip: 'Edit',
                              ),
                              AccessControlledWidget(
                                uiTag: moduleName,
                                permission: userAccessHelper.AccessDelete,
                                child: IconButton(
                                  onPressed: () {
                                    _buildOnDelete(c.employeeId!);
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
      return const EmployeeNavigation();
    }

    if (isDeleting) {
      if (isResolutionChanged) {
        return const EmployeeNavigation();
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

  void _buildOnEdit(String id) {
    final employeelist = ref.watch(employeeMasterListNotifier).where((element) {
      return (element.employeeId == id);
    }).toList();

    widget.onAdd(false, employeelist);
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
                final employeelist =
                    ref.watch(employeeMasterListNotifier).where((element) {
                  return (element.employeeId == id);
                }).toList();
                if (employeelist.isNotEmpty) {
                  removeItem(employeelist[0].employeeId!);
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
