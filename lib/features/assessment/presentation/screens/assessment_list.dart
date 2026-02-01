import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';
import 'package:perf_evaluation/common/widgets/notification_bar.dart';
import 'package:perf_evaluation/features/assessment/application/assessment_provider.dart';
import 'package:perf_evaluation/features/assessment/models/assessment_master_model.dart';
import 'package:perf_evaluation/features/assessment/presentation/assessment_navigation.dart';

import 'package:syn_useraccess/common/utilities/app_settings.dart';
import 'package:syn_useraccess/common/widget/form_controls/accesscontrolledwidget.dart';

class AssessmentList extends ConsumerStatefulWidget {
  const AssessmentList({required this.onAdd, super.key});

  final void Function(bool flg, List<AssessmentMaster> selectedAssessment)
      onAdd;

  @override
  ConsumerState<AssessmentList> createState() => _ExpandableState();
}

class _ExpandableState extends ConsumerState<AssessmentList> {
  final moduleName = 'O_Assessment';
  List<AssessmentMaster> bm = [];
  final TextEditingController enteredSearch = TextEditingController();
  bool isDeleting = false;
  String _searchText = '';
 
  final bool _sortAsc = true;
  final int _sortColumnIndex = 1;
  String? selectedYear;
  bool isResolutionChanged = false;
  // bool _initialized = false;
  bool showCustomArrow = false;
  bool sortArrowsAlwaysVisible = false;

  void removeItem(String id) async {
    try {
      ref.watch(deleteAssessmentBody.notifier).state = id;

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

    ref.read(myAssessments.future);
    List<AssessmentMaster> assessments = ref.read(assessmentMasterListNotifier);
    List<AssessmentMaster> searchList = [];

    if (_searchText != '') {
      var searchText = _searchText.toLowerCase();

      for (var c in assessments) {
        if (c.assessmentPeriod!.toLowerCase().contains(searchText) ||
            c.assessmentQuarter!.toLowerCase().contains(searchText) ||
            c.assessmentStatus!.toLowerCase().contains(searchText) ||
            c.assessmentYear!.toLowerCase().contains(searchText)) {
          searchList.add(c);
        }
      }
      assessments = searchList;
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
                        tooltip: "Add Assessment",
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
                          'Add Appraisal',
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
                    label: Text('Financial Year'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                      label: Text('Appraisal Period'), size: ColumnSize.M),
                  DataColumn2(
                      label: Text('Appraisal Quarter'), size: ColumnSize.M),
                  DataColumn2(
                      label: Text('Appraisal Status'), size: ColumnSize.M),
                  DataColumn2(
                      label: Text('Overall Rating'), size: ColumnSize.M),
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
                rows: assessments
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
                              c.assessmentStatus == "Saved Draft"
                                  ? AccessControlledWidget(
                                      uiTag: moduleName,
                                      permission: userAccessHelper.AccessWrite,
                                      child: IconButton(
                                        onPressed: () {
                                          _buildOnEdit(c.assessmentId!);
                                        },
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 20,
                                        ),
                                        tooltip: 'Edit',
                                      ),
                                    )
                                  : AccessControlledWidget(
                                      uiTag: moduleName,
                                      permission: userAccessHelper.AccessWrite,
                                      child: IconButton(
                                        onPressed: () {
                                          _buildOnEdit(c.assessmentId!);
                                        },
                                        icon: const Icon(Icons.visibility),
                                        tooltip: "View Appraisal",
                                      )),
                              AccessControlledWidget(
                                uiTag: moduleName,
                                permission: userAccessHelper.AccessDelete,
                                child: IconButton(
                                  onPressed: () {
                                    _buildOnDelete(c.assessmentId!);
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
      return const AssessmentNavigation();
    }

    if (isDeleting) {
      if (isResolutionChanged) {
        return const AssessmentNavigation();
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

  void _buildOnEdit(String id) {
    final appraisal = ref.watch(assessmentMasterListNotifier).where((element) {
      return (element.assessmentId == id);
    }).toList();

    widget.onAdd(false, appraisal);
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
                final appraisal =
                    ref.watch(assessmentMasterListNotifier).where((element) {
                  return (element.assessmentId == id);
                }).toList();
                if (appraisal.isNotEmpty) {
                  //removeItem('79a9bed2-d714-433f-9bf8-3d1593597356');
                  removeItem(appraisal[0].assessmentId!);
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
