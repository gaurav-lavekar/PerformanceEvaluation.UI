import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:perf_evaluation/common/widgets/notification_bar.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';
import 'package:perf_evaluation/features/assessment/application/assessment_provider.dart';
import 'package:perf_evaluation/features/assessment/models/assessment_master_model.dart';
import 'package:perf_evaluation/features/assessment/presentation/assessment_navigation.dart';
import 'package:perf_evaluation/features/employee_master/application/employee_provider.dart';
import 'package:perf_evaluation/features/employee_master/models/employee_master_model.dart';
import 'package:perf_evaluation/features/financial_year/application/financialyear_provider.dart';
import 'package:perf_evaluation/features/my_goals/application/goal_provider.dart';
import 'package:perf_evaluation/features/my_goals/models/goal_master_model.dart';
import 'package:perf_evaluation/features/perspective_master/application/perspective_provider.dart';
import 'package:perf_evaluation/features/rating_master/application/ratings_provider.dart';

import 'package:syn_form_fields/syn_form_fields.dart';
import 'package:syn_multitenancy/login/presentation/widgets/loading_widget.dart';
import 'package:syn_useraccess/common/widget/form_controls/accesscontrolledwidget.dart';

class ViewAssessment extends ConsumerStatefulWidget {
  const ViewAssessment({
    super.key,
    required this.recordType,
    required this.onAdd,
    required this.onView,
    this.selectedAssessment,
    this.selectedEmployee,
  });

  final List<AssessmentMaster>? selectedAssessment;
  final List<EmployeeMaster>? selectedEmployee;

  final String recordType;
  final void Function(bool flg, List<EmployeeMaster> selectedEmployee,
      List<AssessmentMaster> selectedAssessment, String pageName) onAdd;

  final void Function(
          bool flg, List<AssessmentMaster> selectedAssessment, String pageName)
      onView;

  @override
  ConsumerState<ViewAssessment> createState() {
    return _ViewAssessmentState();
  }
}

class _ViewAssessmentState extends ConsumerState<ViewAssessment> {
  final moduleName = 'O_Reportees';
  var _isLoading = false;
  var isResolutionChanged = false;

  String? selectedQuarter = "";
  String? selectedYear = "", selectedAppraisalType = "", selectedQuarterId = "";
  int? startYear, endYear;
  String? selectedRating = "", overallrating = "";
  String? employeeId;
  List<GoalMaster> goals = [];
  Map<String, int> enteredSelfRatings = {};
  Map<String, int> enteredAppraiserRatings = {};
  Map<String, int> qualitativeItemScales = {};
  List<dynamic> quartersData = GlobalConfiguration().getValue("QUARTERS");
  List<dynamic> assessmentperiods =
      GlobalConfiguration().getValue("ASSESSMENTPERIOD");

  List<List<TextEditingController>> goalDescriptions = [];
  List<List<TextEditingController>> targetValues = [];
  List<List<TextEditingController>> appraiseeComments = [];
  List<List<TextEditingController>> actualValues = [];
  List<List<TextEditingController>> perspectives = [];
  List<List<TextEditingController>> appraiserComments = [];

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

    if (ref.read(ratingMasterListNotifier).isEmpty) {
      futures.add(ref.read(ratingMaster.future));
    }

    futures.add(ref.read(myGoals.future));

    if (ref.read(assessmentMasterListNotifier).isEmpty) {
      futures.add(ref.read(myAssessments.future));
    }

    combinedFuture = Future.wait(futures);
    await combinedFuture;

    // Update the selected values after the data is fetched
    final assessment = ref
        .read(assessmentMasterListNotifier)
        .where((element) =>
            element.assessmentId == widget.selectedAssessment![0].assessmentId)
        .toList();

    setState(() {
      selectedYear = assessment.first.assessmentYear ?? "";

      selectedAppraisalType = assessment.first.assessmentPeriod ?? "";

      selectedQuarterId = assessment.first.assessmentQuarter ?? "";

      selectedQuarter = quartersData.firstWhere((element) =>
              element['quarterid'] == selectedQuarterId)['quartername'] ??
          '';

      goals = ref
          .read(goalMasterListNotifier)
          .where((goal) =>
              goal.financialyear == selectedYear &&
              assessment[0]
                  .assessmentdetails!
                  .any((detail) => detail.goalsettingId == goal.goalSettingId))
          .toList();

      if (widget.recordType == "Edit") {
        for (int i = 0; i < assessment[0].assessmentdetails!.length; i++) {
          enteredSelfRatings[
                  assessment[0].assessmentdetails![i].goalsettingId!] =
              assessment[0].assessmentdetails![i].selfRating!;
          enteredAppraiserRatings[
                  assessment[0].assessmentdetails![i].goalsettingId!] =
              assessment[0].assessmentdetails![i].appraiserRating!;
        }
      }
    });
  }

  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController enteredQualityofWork = TextEditingController();
  final TextEditingController enteredLeadership = TextEditingController();
  final TextEditingController enteredJobKnowledge = TextEditingController();
  final TextEditingController enteredPersonalSkill = TextEditingController();
  final TextEditingController enteredWorkHabits = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    enteredQualityofWork.dispose();
    enteredJobKnowledge.dispose();
    enteredPersonalSkill.dispose();
    enteredWorkHabits.dispose();
    enteredLeadership.dispose();
    super.dispose();
  }

  void _buildOnDiscard() {
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
                widget.onAdd(true, [], [], "EmployeeAssessmentsGrid");
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
    } else {
      if (true) return true;
    }
    return false;
  }

  buildOnSaveDraft() async {
    if (widget.recordType == "Edit") {
      if (!checkIfFormUpdated()) {
        showNotificationBar(NotificationTypes.info, "No changes to update")
            .show(context);
        return;
      }
    }

    Map<String, dynamic> requestBody = {};
    List<Map<String, dynamic>>? assessmentDetails = [];

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (widget.recordType == "Edit") {
        widget.selectedAssessment![0].assessmentYear = selectedYear!;
        widget.selectedAssessment![0].assessmentPeriod = selectedAppraisalType!;
        widget.selectedAssessment![0].assessmentQuarter =
            widget.selectedAssessment![0].assessmentPeriod == "Quarterly"
                ? selectedQuarterId
                : "";

        requestBody = {
          'assessmentyear': widget.selectedAssessment![0].assessmentYear,
          'assessmentperiod': widget.selectedAssessment![0].assessmentPeriod,
          'assessmentquarter': widget.selectedAssessment![0].assessmentQuarter,
          'assessmentstatus': "Saved Draft",
          'assessmentqualitatives': [],
          'deleted': false
        };

        for (int i = 0; i < goals.length; i++) {
          widget.selectedAssessment![0].assessmentdetails![i]
              .appraiseeComments = appraiseeComments[i][0].text.trim();
          widget.selectedAssessment![0].assessmentdetails![i].actual =
              actualValues[i][0].text.trim();
          widget.selectedAssessment![0].assessmentdetails![i].selfRating =
              enteredSelfRatings[goals[i].goalSettingId] ?? 0;
          widget.selectedAssessment![0].assessmentdetails![i].deleted = false;
        }

        requestBody['assessmentdetails'] =
            widget.selectedAssessment![0].assessmentdetails;

        ref.watch(updateAssessmentBody.notifier).state = requestBody;

        setState(() {
          _isLoading = true;
        });
      } else {
        requestBody = {
          'assessmentyear': selectedYear,
          'assessmentperiod': selectedAppraisalType,
          'assessmentquarter':
              selectedAppraisalType == "Quarterly" ? selectedQuarterId : "",
          'assessmentstatus': "Saved Draft",
          'assessmentqualitatives': [],
          'deleted': false
        };

        for (int i = 0; i < goals.length; i++) {
          assessmentDetails.add({
            'goalsettingid': goals[i].goalSettingId,
            'appraiseecomments': appraiseeComments[i][0].text.trim(),
            'actual': double.tryParse(actualValues[i][0].text.trim()),
            'selfrating': enteredSelfRatings[goals[i].goalSettingId],
            'deleted': false,
          });
        }

        requestBody['assessmentdetails'] = assessmentDetails;

        ref.watch(assessmentBody.notifier).state = requestBody;

        setState(() {
          _isLoading = true;
        });
      }
    }
  }

  onCallBackRating(String goalKey, String columnValue) {
    String columnName = "Self Rating";
    try {
      if (columnName == "Self Rating") {
        setState(() {
          enteredSelfRatings[goalKey] = int.parse(columnValue);
        });
      }
    } catch (e) {}
  }

  onCallBackSupRating(String goalKey, String columnValue) {
    String columnName = "Appraiser Rating";
    try {
      if (columnName == "Appraiser Rating") {
        setState(() {
          enteredAppraiserRatings[goalKey] = int.parse(columnValue);
        });
      }
    } catch (e) {}
  }

  onCallBackOverallRating(String columnName, String columnValue) {
    try {
      if (columnName == "Overall Rating") {
        setState(() {
          overallrating = columnValue;
        });
      }
    } catch (e) {}
  }

  Widget createContainer(List<GoalMaster> goals, String id) {
    List<Widget> children = [];
    final assessment = ref
        .read(assessmentMasterListNotifier)
        .where((element) => element.assessmentId == id)
        .toList();
    String status =
        assessment.isEmpty ? "" : assessment.first.assessmentStatus!;

    List<AssessmentDetails> assessmentDetails =
        assessment.isEmpty ? [] : assessment[0].assessmentdetails!;

    // List<AssessmentQualitatives> assessmentQualitatives =
    //     assessment.isEmpty ? [] : assessment[0].assessmentqualitatives!;

    Widget qualityOfWork = SizedBox(
      width: 500,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InputControl(
          isReadOnly: true,
          maxLine: 10,
          columnLabel: "Quality of Work",
          columnEnteredValue: enteredQualityofWork,
        ),
      ),
    );

    Widget leadership = SizedBox(
      width: 500,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InputControl(
          isReadOnly: true,
          maxLine: 10,
          columnLabel: "Leadership",
          columnEnteredValue: enteredLeadership,
        ),
      ),
    );

    Widget personalSkill = SizedBox(
      width: 500,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InputControl(
          isReadOnly: true,
          maxLine: 10,
          columnLabel: "Interpersonal Skills",
          columnEnteredValue: enteredPersonalSkill,
        ),
      ),
    );

    Widget workHabits = SizedBox(
      width: 500,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InputControl(
          isReadOnly: true,
          maxLine: 10,
          columnLabel: "Work Habits",
          columnEnteredValue: enteredWorkHabits,
        ),
      ),
    );

    Widget overallRating = SizedBox(
        width: 250,
        child: PickControl(
            isReadOnly: true,
            columnLabel: "Overall Rating",
            columnSelectedValue: overallrating!,
            itemlist: List<String>.from(ref
                .read(yearMasterListNotifier)
                .map((element) => element.financialYear)
                .toList()),
            onPickChange: onCallBackOverallRating,
            isMandatory: true));

    Widget jobKnowledge = SizedBox(
      width: 500,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InputControl(
          isReadOnly: true,
          maxLine: 10,
          columnLabel: "Job Knowledge",
          columnEnteredValue: enteredJobKnowledge,
        ),
      ),
    );

    if (widget.recordType == "Edit") {
      for (int i = 0; i < goals.length; i++) {
        // Initialize controllers dynamically
        String goalKey = goals[i].goalSettingId!;

        goalDescriptions
            .add([TextEditingController(text: goals[i].goalDescription ?? "")]);
        perspectives.add(
            [TextEditingController(text: goals[i].goalPerspectiveName ?? "")]);
        targetValues.add([
          TextEditingController(
              text: goals[i].goalTargetValue?.toString() ?? "")
        ]);
        actualValues.add([
          TextEditingController(text: assessmentDetails[i].actual.toString())
        ]);
        appraiseeComments.add([
          TextEditingController(
              text: assessmentDetails[i].appraiseeComments ?? "")
        ]);
        if (assessment.first.assessmentStatus == "Approved") {
          appraiserComments.add([
            TextEditingController(
                text: assessmentDetails[i].appraiserComments ?? "")
          ]);
        }

        children.add(
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: 300,
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Expanded(
                              child: InputControl(
                                  isReadOnly: true,
                                  columnLabel: "Goal Perspective",
                                  columnEnteredValue: perspectives[i][0])))),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 500,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InputControl(
                            isReadOnly: true,
                            maxLine: 10,
                            columnLabel: "Goal Description",
                            columnEnteredValue: goalDescriptions[i][0],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 200,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InputControl(
                            isReadOnly: true,
                            columnLabel: "Goal Target Value",
                            columnEnteredValue: targetValues[i][0],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      SizedBox(
                        width: 500,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InputControl(
                            isMandatory: false,
                            isReadOnly:
                                status == "Saved Draft" || status == "Rejected"
                                    ? false
                                    : true,
                            maxLine: 10,
                            columnLabel: "Appraisee Comments",
                            columnEnteredValue: appraiseeComments[i][0],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 200,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InputControl(
                            isMandatory: false,
                            isReadOnly:
                                status == "Saved Draft" || status == "Rejected"
                                    ? false
                                    : true,
                            columnLabel: "Actual",
                            columnEnteredValue: actualValues[i][0],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: SizedBox(
                        width: 250,
                        child: PickControl(
                          isReadOnly:
                              status == "Saved Draft" || status == "Rejected"
                                  ? false
                                  : true,
                          columnLabel: "Self Rating",
                          columnSelectedValue:
                              enteredSelfRatings[goalKey].toString(),
                          itemlist: ref
                              .read(ratingMasterListNotifier)
                              .map((element) =>
                                  element.ratingScale?.toString() ?? "0")
                              .toList(),
                          onPickChange: (columnName, columnValue) =>
                              onCallBackRating(goalKey, columnValue),
                          isMandatory: false,
                        )),
                  ),
                  const SizedBox(height: 5),
                  if (assessment.first.assessmentStatus == "Approved")
                    Row(
                      children: [
                        SizedBox(
                          width: 500,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InputControl(
                              isMandatory: false,
                              maxLine: 10,
                              columnLabel: "Appraiser Comments",
                              columnEnteredValue: appraiserComments[i][0],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                            width: 250,
                            child: PickControl(
                              isSearchPickList: true,
                              columnLabel: "Appraiser Rating",
                              columnSelectedValue:
                                  enteredAppraiserRatings[goalKey].toString(),
                              itemlist: ref
                                  .read(ratingMasterListNotifier)
                                  .map((element) =>
                                      element.ratingScale?.toString() ?? "0")
                                  .toList(),
                              onPickChange: (columnName, columnValue) =>
                                  onCallBackRating(goalKey, columnValue),
                              isMandatory: true,
                            )),
                      ],
                    ),
                  const SizedBox(
                    height: 45,
                  ),
                ],
              ),
            ),
          ),
        );
      }
      if (assessment.first.assessmentStatus == "Approved") {
        children.add(Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Qualitative Assessment",
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.backgroundColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              qualityOfWork,
              const SizedBox(
                height: 20,
              ),
              workHabits,
              const SizedBox(
                height: 20,
              ),
              jobKnowledge,
              const SizedBox(
                height: 20,
              ),
              personalSkill,
              const SizedBox(
                height: 20,
              ),
              leadership,
              const SizedBox(
                height: 20,
              ),
              overallRating
            ],
          ),
        ));
      }
    } else {
      if (goals.isNotEmpty) {
        for (int i = 0; i < goals.length; i++) {
          // Initialize controllers dynamically
          String goalKey = goals[i].goalSettingId!;

          goalDescriptions.add(
              [TextEditingController(text: goals[i].goalDescription ?? "")]);
          perspectives.add([
            TextEditingController(text: goals[i].goalPerspectiveName ?? "")
          ]);
          targetValues.add([
            TextEditingController(
                text: goals[i].goalTargetValue?.toString() ?? "")
          ]);
          actualValues.add([TextEditingController(text: "")]);
          appraiseeComments.add([TextEditingController(text: "")]);

          children.add(
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: 300,
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Expanded(
                                child: InputControl(
                                    isReadOnly: true,
                                    columnLabel: "Goal Perspective",
                                    columnEnteredValue: perspectives[i][0])))),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 500,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InputControl(
                              isReadOnly: true,
                              maxLine: 10,
                              columnLabel: "Goal Description",
                              columnEnteredValue: goalDescriptions[i][0],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 200,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InputControl(
                              isReadOnly: true,
                              columnLabel: "Goal Target Value",
                              columnEnteredValue: targetValues[i][0],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        SizedBox(
                          width: 500,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InputControl(
                              isMandatory: false,
                              maxLine: 10,
                              columnLabel: "Appraisee Comments",
                              columnEnteredValue: appraiseeComments[i][0],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 200,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InputControl(
                              isMandatory: true,
                              columnLabel: "Actual",
                              columnEnteredValue: actualValues[i][0],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: SizedBox(
                          width: 250,
                          child: PickControl(
                            isSearchPickList: true,
                            columnLabel: "Self Rating",
                            columnSelectedValue: selectedRating!,
                            itemlist: ref
                                .read(ratingMasterListNotifier)
                                .map((element) =>
                                    element.ratingScale?.toString() ?? "0")
                                .toList(),
                            onPickChange: (columnName, columnValue) =>
                                onCallBackRating(goalKey, columnValue),
                            isMandatory: true,
                          )),
                    ),
                    const SizedBox(
                      height: 45,
                    )
                  ],
                ),
              ),
            ),
          );
        }
      } else {
        children.add(const SizedBox());
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  buildOnSubmit() {
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
          widget.recordType == "Edit"
              ? '''You have modified this appraisal. Click Yes to confirm your changes, or No to continue editing'''
              : 'Are you sure you want to submit the appraisal',
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
              Navigator.pop(context, 'Yes');
              submitAppraisal();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  submitAppraisal() async {
    if (widget.recordType == "Edit") {
      if (!checkIfFormUpdated()) {
        showNotificationBar(NotificationTypes.info, "No changes to update")
            .show(context);
        return;
      }
    }

    Map<String, dynamic> requestBody = {};
    List<Map<String, dynamic>>? assessmentDetails = [];

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (widget.recordType == "Edit") {
        widget.selectedAssessment![0].assessmentYear = selectedYear!;
        widget.selectedAssessment![0].assessmentPeriod = selectedAppraisalType!;
        widget.selectedAssessment![0].assessmentQuarter =
            widget.selectedAssessment![0].assessmentPeriod == "Quarterly"
                ? selectedQuarterId
                : "";

        requestBody = {
          'assessmentyear': widget.selectedAssessment![0].assessmentYear,
          'assessmentperiod': widget.selectedAssessment![0].assessmentPeriod,
          'assessmentquarter': widget.selectedAssessment![0].assessmentQuarter,
          'assessmentstatus': "New",
          'assessmentqualitatives': [],
          'deleted': false
        };

        for (int i = 0; i < goals.length; i++) {
          widget.selectedAssessment![0].assessmentdetails![i]
              .appraiseeComments = appraiseeComments[i][0].text.trim();
          widget.selectedAssessment![0].assessmentdetails![i].actual =
              actualValues[i][0].text.trim();
          assessmentDetails[i]['selfrating'] =
              enteredSelfRatings[goals[i].goalSettingId];
          assessmentDetails[i]['deleted'] = false;
        }

        requestBody['assessmentdetails'] =
            widget.selectedAssessment![0].assessmentdetails;

        ref.watch(updateGoalBody.notifier).state = requestBody;

        setState(() {
          _isLoading = true;
        });
      } else {
        requestBody = {
          'assessmentyear': selectedYear,
          'assessmentperiod': selectedAppraisalType,
          'assessmentquarter':
              selectedAppraisalType == "Quarterly" ? selectedQuarterId : "",
          'assessmentstatus': "New",
          'assessmentqualitatives': [],
          'deleted': false
        };

        for (int i = 0; i < goals.length; i++) {
          assessmentDetails.add({
            'goalsettingid': goals[i].goalSettingId,
            'appraiseecomments': appraiseeComments[i][0].text.trim(),
            'actual': double.tryParse(actualValues[i][0].text.trim()),
            'selfrating': enteredSelfRatings[goals[i].goalSettingId],
            'deleted': false,
          });
        }

        requestBody['assessmentdetails'] = assessmentDetails;

        ref.watch(assessmentBody.notifier).state = requestBody;

        setState(() {
          _isLoading = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String status = widget.recordType == "Edit"
        ? widget.selectedAssessment![0].assessmentStatus!
        : "";

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
            void onCallbackQuarters(String columnName, String columnValue) {
              try {
                if (columnName == "Select Quarter") {
                  setState(() {
                    selectedQuarter = columnValue;
                  });

                  final quartersList = quartersData
                      .where((item) => item['quartername'] == selectedQuarter)
                      .toList();

                  if (quartersList.length == 1) {
                    selectedQuarterId = quartersList[0]['quarterid'];
                  }

                  if (selectedAppraisalType == "Quarterly") {
                    RegExp regExp = RegExp(r'(\d{4})-(\d{2})');
                    Match? match = regExp.firstMatch(selectedYear!);

                    if (match != null) {
                      startYear = int.tryParse(match.group(1)!);
                      endYear = int.tryParse(
                          "${match.group(1)!.substring(0, 2)}${match.group(2)!}");
                    }
                    if (selectedQuarterId == "AMJ") {
                      DateTime start = DateTime(startYear!, DateTime.april, 1);
                      DateTime end = DateTime(startYear!, DateTime.june, 30);

                      final goalList = ref
                          .read(goalMasterListNotifier)
                          .where((goal) =>
                              ((goal.goalStartDate!.isAfter(start) ||
                                      goal.goalStartDate!
                                          .isAtSameMomentAs(start)) &&
                                  (goal.goalEndDate!.isBefore(end) ||
                                      goal.goalEndDate!
                                          .isAtSameMomentAs(end))) &&
                              goal.goalStatus == "Approved")
                          .toList();

                      setState(() {
                        goals = goalList;
                      });
                    }
                    if (selectedQuarterId == "JAS") {
                      DateTime start = DateTime(startYear!, DateTime.july, 1);
                      DateTime end =
                          DateTime(startYear!, DateTime.september, 30);

                      final goalList = ref
                          .read(goalMasterListNotifier)
                          .where((goal) =>
                              ((goal.goalStartDate!.isAfter(start) ||
                                      goal.goalStartDate!
                                          .isAtSameMomentAs(start)) &&
                                  (goal.goalEndDate!.isBefore(end) ||
                                      goal.goalEndDate!
                                          .isAtSameMomentAs(end))) &&
                              goal.goalStatus == "Approved")
                          .toList();

                      setState(() {
                        goals = goalList;
                      });
                    }
                    if (selectedQuarterId == "OND") {
                      DateTime start =
                          DateTime(startYear!, DateTime.october, 1);
                      DateTime end =
                          DateTime(startYear!, DateTime.december, 31);

                      final goalList = ref
                          .read(goalMasterListNotifier)
                          .where((goal) =>
                              ((goal.goalStartDate!.isAfter(start) ||
                                      goal.goalStartDate!
                                          .isAtSameMomentAs(start)) &&
                                  (goal.goalEndDate!.isBefore(end) ||
                                      goal.goalEndDate!
                                          .isAtSameMomentAs(end))) &&
                              goal.goalStatus == "Approved")
                          .toList();

                      setState(() {
                        goals = goalList;
                      });
                    }
                    if (selectedQuarterId == "JFM") {
                      DateTime start = DateTime(endYear!, DateTime.january, 1);
                      DateTime end = DateTime(endYear!, DateTime.march, 31);

                      final goalList = ref
                          .read(goalMasterListNotifier)
                          .where((goal) =>
                              ((goal.goalStartDate!.isAfter(start) ||
                                      goal.goalStartDate!
                                          .isAtSameMomentAs(start)) &&
                                  (goal.goalEndDate!.isBefore(end) ||
                                      goal.goalEndDate!
                                          .isAtSameMomentAs(end))) &&
                              goal.goalStatus == "Approved")
                          .toList();

                      setState(() {
                        goals = goalList;
                      });
                    }
                  }
                }
              } catch (e) {}
            }

            void onCallBackAppraisal(String columnName, String columnValue) {
              try {
                if (columnName == "Assessment Period") {
                  setState(() {
                    selectedAppraisalType = columnValue;
                  });

                  if (selectedAppraisalType == "Annual") {
                    RegExp regExp = RegExp(r'(\d{4})-(\d{2})');
                    Match? match = regExp.firstMatch(selectedYear!);

                    if (match != null) {
                      startYear = int.tryParse(match.group(1)!);
                      endYear = int.tryParse(
                          "${match.group(1)!.substring(0, 2)}${match.group(2)!}");
                    }
                    DateTime start = DateTime(startYear!, DateTime.april, 1);
                    DateTime end = DateTime(endYear!, DateTime.march, 31);

                    final goalList = ref
                        .read(goalMasterListNotifier)
                        .where((goal) =>
                            ((goal.goalStartDate!.isAfter(start) ||
                                    goal.goalStartDate!
                                        .isAtSameMomentAs(start)) &&
                                (goal.goalEndDate!.isBefore(end) ||
                                    goal.goalEndDate!.isAtSameMomentAs(end))) &&
                            goal.goalStatus == "Approved")
                        .toList();

                    setState(() {
                      goals = goalList;
                    });
                  } else {
                    setState(() {
                      goals = [];
                    });
                  }
                }
              } catch (e) {}
            }

            void onCallbackFYs(String columnName, String columnValue) {
              try {
                if (columnName == "Select Financial Year") {
                  setState(() {
                    selectedYear = columnValue;
                  });
                }
              } catch (e) {}
            }

            Widget financialYear = SizedBox(
                width: 320,
                child: PickControl(
                    isSearchPickList: true,
                    columnLabel: "Select Financial Year",
                    columnSelectedValue: selectedYear!,
                    itemlist: List<String>.from(ref
                        .read(yearMasterListNotifier)
                        .map((element) => element.financialYear)
                        .toList()),
                    onPickChange: onCallbackFYs,
                    isMandatory: true));

            //Appraisal Period
            Widget appraisalPeriod = SizedBox(
              width: 320,
              child: PickControl(
                  isSearchPickList: true,
                  columnLabel: "Assessment Period",
                  columnSelectedValue: selectedAppraisalType!,
                  itemlist: List<String>.from(assessmentperiods
                      .map((period) => period['assessmentperiod'])).toList(),
                  onPickChange: onCallBackAppraisal,
                  isMandatory: true),
            );

            //Year Quarter
            Widget appraisalQuarter = SizedBox(
              width: 320,
              child: PickControl(
                  isSearchPickList: true,
                  columnLabel: "Select Quarter",
                  columnSelectedValue: selectedQuarter!,
                  itemlist: List<String>.from(
                      quartersData.map((item) => item['quartername']).toList()),
                  onPickChange: onCallbackQuarters,
                  isMandatory: true),
            );

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
                            Icons.assessment,
                            color:
                                Theme.of(context).appBarTheme.backgroundColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Review Appraisal",
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
                        height: 25,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 24.0),
                            child: Row(
                              children: [
                                financialYear,
                                const SizedBox(
                                  width: 25,
                                ),
                                if (selectedYear!.isNotEmpty)
                                  Container(child: appraisalPeriod),
                                const SizedBox(
                                  width: 25,
                                ),
                                if (selectedAppraisalType == "Quarterly")
                                  Container(
                                    child: appraisalQuarter,
                                  )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height - 300,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Column(
                                  children: [
                                    widget.recordType == "Edit"
                                        ? createContainer(
                                            goals,
                                            widget.selectedAssessment![0]
                                                .assessmentId!)
                                        : createContainer(goals, ""),
                                  ],
                                ),
                              ),
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
                            AccessControlledWidget(
                              uiTag: moduleName,
                              permission: status == "Saved Draft" ||
                                      widget.recordType == "New"
                                  ? userAccessHelper.AccessWrite
                                  : "",
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
                            const SizedBox(width: 8),
                            AccessControlledWidget(
                              uiTag: moduleName,
                              permission: status == "Saved Draft" ||
                                      widget.recordType == "New"
                                  ? userAccessHelper.AccessWrite
                                  : "",
                              child: ElevatedButton(
                                  onPressed: buildOnSubmit,
                                  child: const Row(
                                    children: [
                                      Icon(Icons.save),
                                      SizedBox(
                                        width: 6,
                                      ),
                                      Text("Submit")
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
                const Center(child: CircularProgressIndicator()),
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
              return const AssessmentNavigation();
            }

            if (_isLoading) {
              if (isResolutionChanged) {
                return const AssessmentNavigation();
              }
              if (widget.recordType == "Edit") {
                final response = ref.watch(updateAssessmentMaster);
                return response.when(
                  loading: () => contentLoading,
                  error: (err, stack) => contentException('Error: $err'),
                  data: (config) => contentSuccess(response.value!),
                );
              } else {
                final response = ref.watch(saveAssessmentMaster);
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
