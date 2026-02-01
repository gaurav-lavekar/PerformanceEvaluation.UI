import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:perf_evaluation/common/widgets/datecontroller.dart';
import 'package:perf_evaluation/common/widgets/notification_bar.dart';

import 'package:perf_evaluation/common/utilities/notification_type.dart';
import 'package:perf_evaluation/features/employee_master/application/employee_provider.dart';
import 'package:perf_evaluation/features/employee_master/models/employee_master_model.dart';
import 'package:perf_evaluation/features/financial_year/application/financialyear_provider.dart';
import 'package:perf_evaluation/features/my_goals/application/goal_provider.dart';
import 'package:perf_evaluation/features/my_goals/models/goal_master_model.dart';
import 'package:perf_evaluation/features/people/application/reportee_provider.dart';
import 'package:perf_evaluation/features/people/presentation/people_navigation.dart';
import 'package:perf_evaluation/features/perspective_master/application/perspective_provider.dart';

import 'package:syn_form_fields/syn_form_fields.dart';
import 'package:syn_multitenancy/login/presentation/widgets/loading_widget.dart';
import 'package:syn_useraccess/common/utilities/app_settings.dart';
import 'package:syn_useraccess/common/widget/form_controls/accesscontrolledwidget.dart';

class NewPeopleGoal extends ConsumerStatefulWidget {
  const NewPeopleGoal(
      {super.key,
      this.selectedEmployee,
      this.selectedGoal,
      required this.recordType,
      required this.onAdd,
      required this.onView});

  final List<EmployeeMaster>? selectedEmployee;
  final List<GoalMaster>? selectedGoal;

  final String recordType;
  final void Function(bool flg, List<EmployeeMaster> selectedEmployee,
      List<GoalMaster> selectedGoal, String pageName) onAdd;
  final void Function(bool flg, List<GoalMaster>, String pageName) onView;

  @override
  ConsumerState<NewPeopleGoal> createState() {
    return _NewGoalState();
  }
}

class _NewGoalState extends ConsumerState<NewPeopleGoal> {
  final moduleName = 'O_MyPeople';
  var _isLoading = false;
  var isResolutionChanged = false;
  String? selectedPerspective = "";
  String? selectedMeasurementUnit = "";
  String? selectedYear = "";
  String? selectedPerspectiveId = "", selectedFYearId = "";
  String? employeeId = "";
  List<dynamic> measurementunits =
      GlobalConfiguration().getValue("MEASUREMENTUNITS");
  late Future<void> combinedFuture;

  @override
  void initState() {
    super.initState();
    initialData();
  }

  Future<void> initialData() async {
    List<Future> futures = [];

    if (ref.read(yearMasterListNotifier).isEmpty) {
      futures.add(ref.read(financialyearMaster.future));
    }

    if (ref.read(employeeMasterListNotifier).isEmpty) {
      futures.add(ref.read(employeeMaster.future));
    }

    if (ref.read(perspectiveMasterListNotifier).isEmpty) {
      futures.add(ref.read(perspectiveMaster.future));
    }

    combinedFuture = Future.wait(futures);
    await combinedFuture;

    // Update the selected values after the data is fetched
    if (widget.recordType == "Edit") {
      setState(() {
        selectedPerspective = widget.selectedGoal![0].goalPerspectiveName ?? "";

        selectedPerspectiveId = widget.selectedGoal![0].goalPerspectiveId ?? "";

        selectedYear = widget.selectedGoal![0].financialyear ?? "";

        selectedFYearId = widget.selectedGoal![0].financialyearid ?? "";

        enteredGoalDescription.text =
            widget.selectedGoal![0].goalDescription ?? "";

        selectedMeasurementUnit =
            widget.selectedGoal![0].goalMeasurementUnit ?? "";

        enteredTargetValue.text = widget.selectedGoal![0].goalTargetValue ?? "";

        enteredStartDate.text =
            formatter.format(widget.selectedGoal![0].goalStartDate!);

        enteredEndDate.text =
            formatter.format(widget.selectedGoal![0].goalEndDate!);

        ref.watch(financialyear.notifier).state = selectedYear!;
        ref.watch(goalstartdate.notifier).state = enteredStartDate.text;
      });
    }
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController enteredGoalDescription = TextEditingController();
  final TextEditingController enteredTargetValue = TextEditingController();

  final TextEditingController enteredStartDate = TextEditingController();
  final TextEditingController enteredEndDate = TextEditingController();

  @override
  void dispose() {
    enteredGoalDescription.dispose();
    enteredEndDate.dispose();
    enteredStartDate.dispose();
    enteredTargetValue.dispose();
    super.dispose();
  }

  void clearProvider() {
    try {
      ref.watch(goalstartdate.notifier).state = "";
      ref.watch(financialyear.notifier).state = "";
    } catch (e) {}
  }

  void _buildOnDiscard() {
    clearProvider();
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
          widget.recordType == "Edit" && !checkIfFormUpdated()
              ? '''You have modified this work item. Click Yes to discard your changes, or No to continue editing'''
              : 'Are you sure you want to exit?',
          textAlign: TextAlign.center,
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
                Navigator.pop(context, 'Yes');
                widget.onView(true, widget.selectedGoal!, "EmployeeGoalsGrid");
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

  bool checkIfFormUpdated() {
    if (widget.recordType == 'Edit') {
      if (enteredGoalDescription.text !=
              widget.selectedGoal![0].goalDescription ||
          enteredTargetValue.text !=
              widget.selectedGoal![0].goalTargetValue.toString() ||
          selectedPerspectiveId != widget.selectedGoal![0].goalPerspectiveId ||
          selectedFYearId != widget.selectedGoal![0].financialyearid ||
          selectedMeasurementUnit !=
              widget.selectedGoal![0].goalMeasurementUnit ||
          enteredStartDate.text !=
              formatter.format(widget.selectedGoal![0].goalStartDate!) ||
          enteredEndDate.text !=
              formatter.format(widget.selectedGoal![0].goalEndDate!)) {
        return true;
      }
    } else {
      if (enteredGoalDescription.text.isNotEmpty ||
          enteredStartDate.text.isNotEmpty ||
          enteredEndDate.text.isNotEmpty ||
          selectedFYearId!.isNotEmpty ||
          selectedMeasurementUnit!.isNotEmpty ||
          selectedPerspectiveId!.isNotEmpty ||
          enteredTargetValue.text.isNotEmpty) return true;
    }
    return false;
  }

  buildOnReject() async {
    Map<String, dynamic> requestBody;
    String status = "Rejected";
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (widget.recordType == "Edit") {
        if (!checkIfFormUpdated() &&
            status == widget.selectedGoal![0].goalStatus) {
          showNotificationBar(NotificationTypes.info, "No changes to update")
              .show(context);
          return;
        }
      }

      if (widget.recordType == "Edit") {
        widget.selectedGoal![0].goalPerspectiveId =
            selectedPerspectiveId!.trim();
        widget.selectedGoal![0].goalDescription =
            enteredGoalDescription.text.trim();
        widget.selectedGoal![0].financialyearid = selectedFYearId!.trim();
        widget.selectedGoal![0].goalMeasurementUnit = selectedMeasurementUnit!;
        widget.selectedGoal![0].goalTargetValue =
            enteredTargetValue.text.trim();

        requestBody = {
          'goaldetailsid': widget.selectedGoal![0].goalDetailsId,
          'goalsettingid': widget.selectedGoal![0].goalSettingId,
          'employeeid': widget.selectedGoal![0].employeeId,
          "goalperspectiveid": widget.selectedGoal![0].goalPerspectiveId,
          'financialyearid': widget.selectedGoal![0].financialyearid,
          "goaldescription": widget.selectedGoal![0].goalDescription,
          "goalmeasurementunit": widget.selectedGoal![0].goalMeasurementUnit,
          "goaltargetvalue": widget.selectedGoal![0].goalTargetValue,
          "goalstatus": status,
          "createdby": widget.selectedGoal![0].createdBy,
          "deleted": false,
        };

        requestBody['goalstartdate'] = enteredStartDate.text.isNotEmpty
            ? formatter.parse(enteredStartDate.text.trim()).toIso8601String()
            : null;

        requestBody['goalenddate'] = enteredEndDate.text.isNotEmpty
            ? formatter.parse(enteredEndDate.text.trim()).toIso8601String()
            : null;

        ref.watch(updateGoalBody.notifier).state = requestBody;

        setState(() {
          _isLoading = true;
        });
      }
    }
  }

  buildOnSaveDraft() async {
    Map<String, dynamic> requestBody;
    String status = "Saved Draft";
    Map userDetails = ref.read(loggedInUser);

    if (widget.recordType == "Edit") {
      if (!checkIfFormUpdated() &&
          status == widget.selectedGoal![0].goalStatus) {
        showNotificationBar(NotificationTypes.info, "No changes to update")
            .show(context);
        return;
      }
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (formatter
          .parse(enteredEndDate.text.trim())
          .isBefore(formatter.parse(enteredStartDate.text.trim()))) {
        showNotificationBar(NotificationTypes.error,
                "Goal End Date cannot be before Goal Start Date")
            .show(context);
        return;
      }

      if (widget.recordType == "Edit") {
        widget.selectedGoal![0].goalPerspectiveId =
            selectedPerspectiveId!.trim();
        widget.selectedGoal![0].financialyearid = selectedFYearId!.trim();
        widget.selectedGoal![0].financialyear = selectedYear!;
        widget.selectedGoal![0].goalDescription =
            enteredGoalDescription.text.trim();
        widget.selectedGoal![0].goalMeasurementUnit = selectedMeasurementUnit!;
        widget.selectedGoal![0].goalTargetValue =
            enteredTargetValue.text.trim();

        requestBody = {
          'goaldetailsid': widget.selectedGoal![0].goalDetailsId,
          "goalsettingid": widget.selectedGoal![0].goalSettingId,
          "goalperspectiveid": widget.selectedGoal![0].goalPerspectiveId,
          "employeeid": widget.selectedGoal![0].employeeId,
          "financialyearid": widget.selectedGoal![0].financialyearid,
          "goaldescription": widget.selectedGoal![0].goalDescription,
          "goalmeasurementunit": widget.selectedGoal![0].goalMeasurementUnit,
          "goaltargetvalue": widget.selectedGoal![0].goalTargetValue,
          "goalstatus": status,
          "createdby": widget.selectedGoal![0].createdBy,
          "deleted": false,
        };

        requestBody['goalstartdate'] = enteredStartDate.text.isNotEmpty
            ? formatter.parse(enteredStartDate.text.trim()).toIso8601String()
            : null;

        requestBody['goalenddate'] = enteredEndDate.text.isNotEmpty
            ? formatter.parse(enteredEndDate.text.trim()).toIso8601String()
            : null;

        ref.watch(updateGoalBody.notifier).state = requestBody;

        setState(() {
          _isLoading = true;
        });
      } else {
        requestBody = {
          "financialyearid": selectedFYearId!.trim(),
          "goalperspectiveid": selectedPerspectiveId!.trim(),
          "goaldescription": enteredGoalDescription.text.trim(),
          "goalstartdate": enteredStartDate.text,
          "goalenddate": enteredEndDate.text,
          "goalmeasurementunit": selectedMeasurementUnit!.trim(),
          "goaltargetvalue": enteredTargetValue.text.trim(),
          'goalstatus': status,
          "createdby": userDetails['name'],
          "deleted": false
        };

        requestBody['goalstartdate'] = enteredStartDate.text.isNotEmpty
            ? formatter.parse(enteredStartDate.text.trim()).toIso8601String()
            : null;

        requestBody['goalenddate'] = enteredEndDate.text.isNotEmpty
            ? formatter.parse(enteredEndDate.text.trim()).toIso8601String()
            : null;

        ref.watch(goalBody.notifier).state = requestBody;

        setState(() {
          _isLoading = true;
        });
      }
    }
  }

  submitGoal() async {
    Map<String, dynamic> requestBody;
    Map userDetails = ref.read(loggedInUser);
    String status = "Approved";
    String errorMsg = "";

    if (enteredGoalDescription.text.isEmpty ||
        selectedMeasurementUnit!.isEmpty ||
        enteredTargetValue.text.isEmpty) {
      if (enteredGoalDescription.text.isEmpty) {
        errorMsg = "Goal Description is required";
      }
      if (selectedMeasurementUnit!.isEmpty) {
        errorMsg = "Goal Measurement Unit is required";
      }
      if (enteredTargetValue.text.isEmpty) {
        errorMsg = "Goal Target Value is required";
      }

      showNotificationBar(NotificationTypes.error, errorMsg).show(context);
      return;
    }

    if (widget.recordType == "Edit") {
      if (!checkIfFormUpdated() &&
          status == widget.selectedGoal![0].goalStatus) {
        showNotificationBar(NotificationTypes.info, "No changes to update")
            .show(context);
        return;
      }
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (widget.recordType == "Edit") {
        widget.selectedGoal![0].goalPerspectiveId =
            selectedPerspectiveId!.trim();
        widget.selectedGoal![0].goalDescription =
            enteredGoalDescription.text.trim();
        widget.selectedGoal![0].financialyearid = selectedFYearId!.trim();
        widget.selectedGoal![0].goalMeasurementUnit = selectedMeasurementUnit!;
        widget.selectedGoal![0].goalTargetValue =
            enteredTargetValue.text.trim();

        requestBody = {
          'goaldetailsid': widget.selectedGoal![0].goalDetailsId,
          'goalsettingid': widget.selectedGoal![0].goalSettingId,
          'employeeid': widget.selectedGoal![0].employeeId,
          'goalperspectiveid': widget.selectedGoal![0].goalPerspectiveId,
          'financialyearid': widget.selectedGoal![0].financialyearid,
          'goaldescription': widget.selectedGoal![0].goalDescription,
          'goalmeasurementunit': widget.selectedGoal![0].goalMeasurementUnit,
          'goaltargetvalue': widget.selectedGoal![0].goalTargetValue,
          'goalstatus': status,
          'createdby': widget.selectedGoal![0].createdBy,
          "deleted": false,
        };

        if (enteredStartDate.text.isNotEmpty) {
          DateTime? formattedDate;
          formattedDate = formatter.parse(enteredStartDate.text.trim());

          requestBody['goalstartdate'] = formattedDate.toIso8601String();
        }
        if (enteredEndDate.text.isNotEmpty) {
          DateTime? formattedDate;
          formattedDate = formatter.parse(enteredEndDate.text.trim());

          requestBody['goalenddate'] = formattedDate.toIso8601String();
        }

        ref.watch(updateGoalBody.notifier).state = requestBody;

        setState(() {
          _isLoading = true;
        });
      } else {
        requestBody = {
          "financialyearid": selectedFYearId!.trim(),
          "goalperspectiveid": selectedPerspectiveId!.trim(),
          "goaldescription": enteredGoalDescription.text.trim(),
          "goalstartdate": enteredStartDate.text,
          "goalenddate": enteredEndDate.text,
          "goalmeasurementunit": selectedMeasurementUnit!.trim(),
          "goaltargetvalue": enteredTargetValue.text.trim(),
          'goalstatus': status,
          'createdby': userDetails['name'],
          "deleted": false
        };

        if (enteredStartDate.text.isNotEmpty) {
          DateTime? formattedDate;
          formattedDate = formatter.parse(enteredStartDate.text.trim());
          requestBody['goalstartdate'] = formattedDate.toIso8601String();
        }
        if (enteredEndDate.text.isNotEmpty) {
          DateTime? formattedDate;
          formattedDate = formatter.parse(enteredEndDate.text.trim());
          requestBody['goalenddate'] = formattedDate.toIso8601String();
        }

        ref.watch(goalBody.notifier).state = requestBody;

        setState(() {
          _isLoading = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Map userDetails = ref.read(loggedInUser);

    return FutureBuilder(
        future: combinedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator while data is loading
            return const LoadingDialogWidget();
          } else if (snapshot.hasError) {
            // Handle any error that occurred during data loading
            showNotificationBar(NotificationTypes.error, '${snapshot.error}')
                .show(context);
            return const SizedBox.shrink();
          } else {
            void onCallbackPerspective(String columnName, String columnValue) {
              try {
                if (columnName == "Goal Perspective") {
                  setState(() {
                    selectedPerspective = columnValue;
                  });
                  final perspectiveList = ref
                      .read(perspectiveMasterListNotifier)
                      .where((element) =>
                          element.goalPerspectiveName == selectedPerspective)
                      .toList();
                  if (perspectiveList.length == 1) {
                    selectedPerspectiveId =
                        perspectiveList[0].goalPerspectiveId;
                  }
                }
              } catch (e) {}
            }

            void onCallbackFYs(String columnName, String columnValue) {
              try {
                if (columnName == "Financial Year") {
                  setState(() {
                    selectedYear = columnValue;
                    enteredStartDate.text = "";
                    enteredEndDate.text = "";
                    ref.watch(financialyear.notifier).state = selectedYear!;
                    ref.watch(goalstartdate.notifier).state = '';
                  });
                  final financialyearList = ref
                      .read(yearMasterListNotifier)
                      .where((element) => element.financialYear == selectedYear)
                      .toList();

                  if (financialyearList.length == 1) {
                    selectedFYearId = financialyearList[0].financialyearid;
                  }
                }
              } catch (e) {}
            }

            //Goal Perspective
            Widget goalPerspective = SizedBox(
                width: 320,
                child: PickControl(
                    isSearchPickList: true,
                    columnLabel: "Goal Perspective",
                    columnSelectedValue: selectedPerspective!,
                    itemlist: List<String>.from(ref
                        .read(perspectiveMasterListNotifier)
                        .map((element) => element.goalPerspectiveName)
                        .toList()),
                    onPickChange: onCallbackPerspective,
                    isMandatory: true));

            Widget financialYear = SizedBox(
              width: 320,
              child: PickControl(
                  isSearchPickList: true,
                  columnLabel: "Financial Year",
                  columnSelectedValue: selectedYear!,
                  itemlist: List<String>.from(ref
                      .read(yearMasterListNotifier)
                      .map((element) => element.financialYear)
                      .toList()),
                  onPickChange: onCallbackFYs,
                  isMandatory: true),
            );

            // Goal Description
            Widget goalDescription = SizedBox(
              width: 500,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InputControl(
                    maxLine: 10,
                    columnLabel: "Goal Description",
                    columnEnteredValue: enteredGoalDescription),
              ),
            );

            //Goal Start Date
            Widget goalStartDate = SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DateController(
                  isGoalStartDate: true,
                  columnLabel: 'Start Date',
                  columnEnteredValue: enteredStartDate,
                  isMandatory: true,
                ),
              ),
            );

            //Goal End Date
            Widget goalEndDate = SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DateController(
                  isGoalEndDate: true,
                  columnLabel: 'End Date',
                  columnEnteredValue: enteredEndDate,
                  isMandatory: true,
                ),
              ),
            );

            //Goal Measurement Unit
            Widget goalMeasurementUnit = SizedBox(
                width: 320,
                child: PickControl(
                    isSearchPickList: true,
                    columnLabel: "Goal Measurement Unit",
                    columnSelectedValue: selectedMeasurementUnit!,
                    itemlist: List<String>.from(measurementunits
                        .map((unit) => unit['measurementunit'])).toList(),
                    onPickChange: (columnName, columnValue) {
                      selectedMeasurementUnit = columnValue;
                    },
                    isMandatory: false));

            //Goal Target Value
            Widget goalTargetValue = SizedBox(
              width: 200,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InputControl(
                    allowonlyNumbers: true,
                    isMandatory: false,
                    columnLabel: "Goal Target Value",
                    columnEnteredValue: enteredTargetValue),
              ),
            );

            String status = widget.selectedGoal!.isEmpty
                ? ""
                : widget.selectedGoal![0].goalStatus!;

            //FORM
            Widget content = Form(
                key: _formKey,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.stairs,
                            color:
                                Theme.of(context).appBarTheme.backgroundColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            widget.recordType == "Edit"
                                ? "Review Goal"
                                : "Add Goal",
                            style: TextStyle(
                              color:
                                  Theme.of(context).appBarTheme.backgroundColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Row(
                              children: [
                                goalPerspective,
                                const SizedBox(
                                  width: 30,
                                ),
                                financialYear
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          goalDescription,
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                            children: [
                              goalStartDate,
                              const SizedBox(
                                width: 30,
                              ),
                              goalEndDate,
                            ],
                          ),
                          const SizedBox(
                            height: 35,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Row(
                              children: [
                                goalMeasurementUnit,
                                const SizedBox(
                                  width: 30,
                                ),
                                goalTargetValue
                              ],
                            ),
                          )
                        ],
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: _buildOnDiscard,
                                child: const Text("Discard")),
                            const SizedBox(width: 8),
                            if (status == "New" ||
                                status == "Approved" ||
                                status == "Rejected")
                              AccessControlledWidget(
                                uiTag: moduleName,
                                permission: userAccessHelper.AccessWrite,
                                child: Row(
                                  children: [
                                    ElevatedButton(
                                        onPressed: buildOnReject,
                                        child: const Row(
                                          children: [
                                            Icon(Icons.arrow_left),
                                            SizedBox(
                                              width: 6,
                                            ),
                                            Text("Send Back")
                                          ],
                                        )),
                                    const SizedBox(width: 8)
                                  ],
                                ),
                              ),
                            if (status.isEmpty ||
                                (status == "Saved Draft" ||
                                    status == "Approved" &&
                                        widget.selectedGoal![0].createdBy ==
                                            userDetails['name']))
                              AccessControlledWidget(
                                uiTag: moduleName,
                                permission: userAccessHelper.AccessWrite,
                                child: ElevatedButton(
                                    onPressed: buildOnSaveDraft,
                                    child: const Row(
                                      children: [
                                        Icon(Icons.save),
                                        SizedBox(
                                          width: 6,
                                        ),
                                        Text("Save Draft")
                                      ],
                                    )),
                              ),
                            const SizedBox(
                              width: 8,
                            ),
                            AccessControlledWidget(
                              uiTag: moduleName,
                              permission: userAccessHelper.AccessWrite,
                              child: ElevatedButton(
                                  onPressed: submitGoal,
                                  child: const Row(
                                    children: [
                                      Icon(Icons.save),
                                      SizedBox(
                                        width: 6,
                                      ),
                                      Text("Approve")
                                    ],
                                  )),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ));

            Widget contentLoading = Stack(
              children: [
                content,
                const Center(child: LoadingDialogWidget()),
              ],
            );

            Widget contentException(String msg) {
              showNotificationBar(NotificationTypes.error, msg).show(context);
              _isLoading = false;
              return content;
            }

            contentSuccess(String msg) {
              showNotificationBar(NotificationTypes.success, msg).show(context);
              isResolutionChanged = true;
              return const PeopleNavigation(isGoalUpdated: true);
            }

            if (_isLoading) {
              if (isResolutionChanged) {
                return const PeopleNavigation();
              }
              if (widget.recordType == "Edit") {
                final response = ref.watch(updateReporteeGoal);
                return response.when(
                  loading: () => contentLoading,
                  error: (err, stack) => contentException('Error: $err'),
                  data: (config) => contentSuccess(response.value!),
                );
              } else {
                final response = ref.watch(saveReporteeGoal);
                return response.when(
                  loading: () => contentLoading,
                  error: (err, stack) => contentException('Error: $err'),
                  data: (config) => contentSuccess(response.value!),
                );
              }
            } else {
              return content;
            }
          }
        });
  }
}
