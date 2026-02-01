import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';
import 'package:perf_evaluation/common/widgets/notification_bar.dart';
import 'package:perf_evaluation/features/assessment/application/assessment_provider.dart';
import 'package:perf_evaluation/features/assessment/models/assessment_master_model.dart';
import 'package:perf_evaluation/features/employee_master/application/employee_provider.dart';
import 'package:perf_evaluation/features/employee_master/models/employee_master_model.dart';
import 'package:perf_evaluation/features/hr/application/appraisal_provider.dart';
import 'package:perf_evaluation/features/hr/presentation/hr_navigation.dart';
import 'package:perf_evaluation/features/reportees/application/reportee_assessment_provider.dart';
import 'package:syn_form_fields/syn_form_fields.dart';
import 'package:syn_multitenancy/login/presentation/widgets/loading_widget.dart';

import 'package:syn_useraccess/common/widget/form_controls/accesscontrolledwidget.dart';

class EmployeeAppraisals extends ConsumerStatefulWidget {
  const EmployeeAppraisals(
      {required this.onAdd, required this.onView, super.key});

  final void Function(bool flg, List<EmployeeMaster> reportee,
      List<AssessmentMaster> selectedAssessment, String pageName) onAdd;

  final void Function(
          bool flg, List<AssessmentMaster> selectedAssessment, String pgName)
      onView;

  @override
  ConsumerState<EmployeeAppraisals> createState() => _ExpandableState();
}

class _ExpandableState extends ConsumerState<EmployeeAppraisals> {
  final moduleName = 'O_HR';
  List<AssessmentMaster> bm = [];

  final TextEditingController enteredSearch = TextEditingController();
  final TextEditingController enteredEmployee = TextEditingController();

  bool isDeleting = false;
  String _searchText = '';

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
    appraisalData();
  }

  @override
  void dispose() {
    enteredSearch.dispose();
    super.dispose();
  }

  Future<void> appraisalData() async {
    List<Future> futures = [];

    futures.add(ref.read(reporteeAssessments.future));

    if (ref.read(employeeMasterListNotifier).isEmpty) {
      futures.add(ref.read(employeeMaster.future));
    }

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
            List<AssessmentMaster> appraisals = ref
                .read(assessmentMasterListNotifier)
                .where((element) => element.assessmentStatus != "Saved Draft")
                .toList();

            List<AssessmentMaster> searchList = [];

            final employee = ref
                .read(employeeMasterListNotifier)
                .where((element) => element.employeeId == ref.read(hrProvider))
                .toList();

            enteredEmployee.text =
                '${employee.first.firstName} ${employee.first.lastName}';

            if (_searchText != '') {
              var searchText = _searchText.toLowerCase();

              for (var c in appraisals) {
                if (c.assessmentYear!.toLowerCase().contains(searchText) ||
                    c.assessmentPeriod!.toLowerCase().contains(searchText) ||
                    c.assessmentQuarter!.toLowerCase().contains(searchText) ||
                    c.assessmentStatus!
                        .toString()
                        .toLowerCase()
                        .contains(searchText)) {
                  searchList.add(c);
                }
              }
              appraisals = searchList;
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
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: 300,
                    child: Expanded(
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
                            label: Text('Financial Year'),
                            size: ColumnSize.M,
                          ),
                          DataColumn2(
                              label: Text('Appraisal Period'),
                              size: ColumnSize.M),
                          DataColumn2(
                              label: Text('Appraisal Quarter'),
                              size: ColumnSize.M),
                          DataColumn2(
                              label: Text('Appraisal Status'),
                              size: ColumnSize.M),
                          DataColumn2(
                              label: Text('Overall Rating'),
                              size: ColumnSize.M),
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
                        rows: appraisals
                            .map(
                              (c) => DataRow(
                                cells: [
                                  DataCell(Text(c.assessmentYear!)),
                                  DataCell(Text(c.assessmentPeriod!)),
                                  DataCell(Text(c.assessmentQuarter!)),
                                  DataCell(Text(c.assessmentStatus!)),
                                  DataCell(Text(c.overallRating.toString())),
                                  DataCell(Row(
                                    children: [
                                      AccessControlledWidget(
                                        uiTag: moduleName,
                                        permission:
                                            userAccessHelper.AccessWrite,
                                        child: IconButton(
                                          onPressed: () {
                                            _buildOnEdit(
                                                c.assessmentId!, c.employeeId!);
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
              widget.onAdd(
                  true, employee, appraisals, "EmployeeAppraisalsGrid");
              return const HRNavigation();
            }

            if (isDeleting) {
              if (isResolutionChanged) {
                return const HRNavigation();
              }
              final response = ref.watch(deleteAssessmentMaster);
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

  void _buildOnEdit(String appraisalId, String reporteeId) {
    final reportee = ref
        .watch(employeeMasterListNotifier)
        .where((element) => element.employeeId == reporteeId)
        .toList();

    final appraisal = ref.watch(assessmentMasterListNotifier).where((element) {
      return (element.assessmentId == appraisalId);
    }).toList();

    widget.onAdd(false, reportee, appraisal, "NewAssessment");
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
