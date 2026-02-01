import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/common/widgets/datecontroller.dart';
import 'package:perf_evaluation/common/widgets/notification_bar.dart';
import 'package:perf_evaluation/features/employee_master/application/employee_provider.dart';
import 'package:perf_evaluation/features/employee_master/models/employee_master_model.dart';
import 'package:perf_evaluation/features/employee_master/presentation/employee_navigation.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';
import 'package:syn_form_fields/syn_form_fields.dart';
import 'package:syn_multitenancy/login/presentation/widgets/loading_widget.dart';
import 'package:syn_useraccess/common/utilities/app_settings.dart';
import 'package:syn_useraccess/user/application/user_provider.dart';

class NewEmployee extends ConsumerStatefulWidget {
  const NewEmployee(
      {super.key,
      this.selectedEmployee,
      required this.recordType,
      required this.onAdd});

  final List<EmployeeMaster>? selectedEmployee;

  final String recordType;
  final void Function(bool flg, List<EmployeeMaster> selectedEmployee) onAdd;

  @override
  ConsumerState<NewEmployee> createState() {
    return _NewEmployeeState();
  }
}

class _NewEmployeeState extends ConsumerState<NewEmployee> {
  final moduleName = 'O_Employee';
  var _isLoading = false;
  var isResolutionChanged = false;
  String? selectedGender = "";
  String? selectedSupervisor = "", supervisorId = "";

  late Future<void> combinedFuture;

  @override
  void initState() {
    super.initState();
    initialData();
  }

  Future<void> initialData() async {
    List<Future> futures = [];

    if (ref.read(employeeMasterListNotifier).isEmpty) {
      futures.add(ref.read(employeeMaster.future));
    }

    if (ref.read(userMasterListNotifier).isEmpty) {
      futures.add(ref.read(userMaster.future));
    }

    combinedFuture = Future.wait(futures);
    await combinedFuture;

    if (widget.recordType == "Edit") {
      setState(() {
        enteredFirstName.text = widget.selectedEmployee![0].firstName ?? "";

        enteredMiddleName.text = widget.selectedEmployee![0].middleName ?? "";
        enteredLastName.text = widget.selectedEmployee![0].lastName ?? "";

        enteredEmail.text = widget.selectedEmployee![0].emailId ?? "";

        enteredMobileNo.text = widget.selectedEmployee![0].phone ?? "";
        selectedGender = widget.selectedEmployee![0].gender ?? "";

        enteredEducation.text =
            widget.selectedEmployee![0].educationQualification ?? "";

        enteredEmpId.text = widget.selectedEmployee![0].empid ?? "";

        supervisorId = widget.selectedEmployee![0].supervisorId ?? "";

        selectedSupervisor = supervisorId == null || supervisorId!.isEmpty
            ? ''
            : ref
                    .read(employeeMasterListNotifier)
                    .where((e) => e.employeeId == supervisorId)
                    .map((e) => '${e.firstName} ${e.lastName}')
                    .join(' ') ??
                '';

        enteredDesignation.text = widget.selectedEmployee![0].designation ?? "";

        enteredDepartment.text = widget.selectedEmployee![0].department ?? "";

        enteredJoinDate.text =
            formatter.format(widget.selectedEmployee![0].joiningDate!);

        enteredConfirmDate.text =
            formatter.format(widget.selectedEmployee![0].confirmationDate!);

        ref.watch(dateofjoining.notifier).state = enteredJoinDate.text;
      });
    }
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController enteredFirstName = TextEditingController();
  final TextEditingController enteredEmpId = TextEditingController();
  final TextEditingController enteredMiddleName = TextEditingController();
  final TextEditingController enteredLastName = TextEditingController();
  final TextEditingController enteredEducation = TextEditingController();
  final TextEditingController enteredDepartment = TextEditingController();
  final TextEditingController enteredEmail = TextEditingController();
  final TextEditingController enteredMobileNo = TextEditingController();
  final TextEditingController enteredDesignation = TextEditingController();
  final TextEditingController enteredJoinDate = TextEditingController();
  final TextEditingController enteredConfirmDate = TextEditingController();

  @override
  void dispose() {
    enteredFirstName.dispose();
    enteredMiddleName.dispose();
    enteredLastName.dispose();
    enteredEmail.dispose();
    enteredMobileNo.dispose();
    enteredEducation.dispose();
    enteredDesignation.dispose();
    enteredDepartment.dispose();
    enteredDesignation.dispose();
    enteredJoinDate.dispose();
    enteredConfirmDate.dispose();
    super.dispose();
  }

  void _buildOnDiscard() {
    ref.watch(dateofjoining.notifier).state = "";
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
          'Are you sure you want to exit?',
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
                widget.onAdd(true, []);
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
      if (enteredFirstName.text != widget.selectedEmployee![0].firstName ||
          enteredLastName.text != widget.selectedEmployee![0].lastName ||
          enteredMiddleName.text != widget.selectedEmployee![0].middleName ||
          enteredEmail.text != widget.selectedEmployee![0].emailId ||
          supervisorId != widget.selectedEmployee![0].supervisorId ||
          enteredMobileNo.text != widget.selectedEmployee![0].phone ||
          enteredEducation.text !=
              widget.selectedEmployee![0].educationQualification ||
          enteredEmpId.text != widget.selectedEmployee![0].employeeId ||
          enteredDesignation.text != widget.selectedEmployee![0].designation ||
          enteredDepartment.text != widget.selectedEmployee![0].department ||
          formatter.parse(enteredJoinDate.text.trim()) !=
              widget.selectedEmployee![0].joiningDate ||
          formatter.parse(enteredConfirmDate.text.trim()) !=
              widget.selectedEmployee![0].confirmationDate) {
        return true;
      }
    } else {
      if (enteredFirstName.text.isNotEmpty ||
          enteredMiddleName.text.isNotEmpty ||
          enteredLastName.text.isNotEmpty ||
          enteredEmail.text.isNotEmpty ||
          enteredMobileNo.text.isNotEmpty ||
          enteredEducation.text.isNotEmpty ||
          enteredEmpId.text.isNotEmpty ||
          enteredJoinDate.text.isNotEmpty ||
          enteredConfirmDate.text.isNotEmpty ||
          enteredDepartment.text.isNotEmpty ||
          enteredDesignation.text.isNotEmpty ||
          supervisorId!.isNotEmpty) return true;
    }
    return false;
  }

  submitEmployee() async {
    Map<String, dynamic> requestBody;
    Map userDetails = ref.read(loggedInUser);
    String emailId = enteredEmail.text.trim().toLowerCase();
    String employeeId = enteredEmpId.text.trim().toLowerCase();

    if (widget.recordType == "Edit") {
      if (!checkIfFormUpdated()) {
        showNotificationBar(NotificationTypes.info, "No changes to update")
            .show(context);
        return;
      }
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (widget.recordType == "Edit") {
        List<String> employeeEmailMapList = ref
            .read(employeeMasterListNotifier)
            .where((e) =>
                e.deleted == false &&
                e.employeeId != widget.selectedEmployee![0].employeeId)
            .map((e) => e.emailId!.toLowerCase())
            .toList();

        List<String> employeeIdMapList = ref
            .read(employeeMasterListNotifier)
            .where((e) =>
                e.deleted == false &&
                e.employeeId != widget.selectedEmployee![0].employeeId)
            .map((e) => e.empid!.toLowerCase())
            .toList();

        if (employeeEmailMapList.contains(emailId)) {
          showNotificationBar(NotificationTypes.error,
                  "Employee with Email ID ${enteredEmail.text.trim()} already exists")
              .show(context);
          return;
        }

        if (employeeIdMapList.contains(employeeId)) {
          showNotificationBar(NotificationTypes.error,
                  "Employee with ID ${enteredEmpId.text.trim()} already exists")
              .show(context);
          return;
        }

        if (enteredJoinDate.text.isNotEmpty &&
            enteredConfirmDate.text.isNotEmpty) {
          if (formatter
              .parse(enteredConfirmDate.text.trim())
              .isBefore(formatter.parse(enteredJoinDate.text.trim()))) {
            showNotificationBar(NotificationTypes.error,
                    "Date of Confirmation cannot be a date before joining date")
                .show(context);
            return;
          }
        }

        widget.selectedEmployee![0].firstName = enteredFirstName.text.trim();
        widget.selectedEmployee![0].lastName = enteredLastName.text.trim();
        widget.selectedEmployee![0].supervisorId =
            supervisorId!.trim().isEmpty ? null : supervisorId!.trim();
        widget.selectedEmployee![0].empid = enteredEmpId.text.trim();
        widget.selectedEmployee![0].middleName = enteredMiddleName.text.trim();
        widget.selectedEmployee![0].gender = selectedGender!.trim();
        widget.selectedEmployee![0].emailId = enteredEmail.text.trim();
        widget.selectedEmployee![0].phone = enteredMobileNo.text.trim();
        widget.selectedEmployee![0].educationQualification =
            enteredEducation.text.trim();
        widget.selectedEmployee![0].designation =
            enteredDesignation.text.trim();
        widget.selectedEmployee![0].department = enteredDepartment.text.trim();

        requestBody = {
          "employeeid": widget.selectedEmployee![0].employeeId,
          "empid": widget.selectedEmployee![0].empid,
          "firstname": widget.selectedEmployee![0].firstName,
          "middlename": widget.selectedEmployee![0].middleName,
          "lastname": widget.selectedEmployee![0].lastName,
          "highesteducationqualification":
              widget.selectedEmployee![0].educationQualification,
          "gender": widget.selectedEmployee![0].gender,
          "department": widget.selectedEmployee![0].department,
          "employeeloginid": widget.selectedEmployee![0].employeeLoginId,
          "emailid": widget.selectedEmployee![0].emailId,
          "phone": widget.selectedEmployee![0].phone,
          "supervisorid": widget.selectedEmployee![0].supervisorId,
          "dateofjoining": widget.selectedEmployee![0].joiningDate,
          "dateofconfirmation": widget.selectedEmployee![0].confirmationDate,
          "designation": widget.selectedEmployee![0].designation,
          "active": true,
          "deleted": false,
          "modifiedby": userDetails['name'],
          "activefromdate":
              widget.selectedEmployee![0].activefromdate!.toIso8601String(),
          "inactivefromdate": null,
          "modifiedon": DateTime.now().toIso8601String()
        };

        requestBody['dateofjoining'] = enteredJoinDate.text.isNotEmpty
            ? formatter.parse(enteredJoinDate.text.trim()).toIso8601String()
            : null;

        requestBody['dateofconfirmation'] = enteredConfirmDate.text.isNotEmpty
            ? formatter.parse(enteredConfirmDate.text.trim()).toIso8601String()
            : null;

        ref.watch(updateEmployeeBody.notifier).state = requestBody;

        setState(() {
          _isLoading = true;
        });
      } else {
        List<String> emailIDs = ref
            .read(employeeMasterListNotifier)
            .where((e) => e.deleted == false)
            .map((e) => e.emailId!)
            .toList();

        List<String> employeeIDs = ref
            .read(employeeMasterListNotifier)
            .where((e) => e.deleted == false)
            .map((e) => e.emailId!)
            .toList();

        if (emailIDs.contains(emailId)) {
          showNotificationBar(NotificationTypes.error,
                  "Employee with Email ID $emailId already exists")
              .show(context);
          return;
        }

        if (employeeIDs.contains(employeeId)) {
          showNotificationBar(NotificationTypes.error,
                  "Employee with ID $employeeId already exists")
              .show(context);
          return;
        }

        if (enteredJoinDate.text.isNotEmpty &&
            enteredConfirmDate.text.isNotEmpty) {
          if (formatter
              .parse(enteredConfirmDate.text.trim())
              .isBefore(formatter.parse(enteredJoinDate.text.trim()))) {
            showNotificationBar(NotificationTypes.error,
                    "Date of Confirmation cannot be a date before joining date")
                .show(context);
            return;
          }
        }

        requestBody = {
          "empid": enteredEmpId.text.trim(),
          "firstname": enteredFirstName.text.trim(),
          "middlename": enteredMiddleName.text.trim(),
          "lastname": enteredLastName.text.trim(),
          "highesteducationqualification": enteredEducation.text.trim(),
          "gender": selectedGender,
          "department": enteredDepartment.text.trim(),
          "emailid": enteredEmail.text.trim(),
          "phone": enteredMobileNo.text.trim(),
          "supervisorid": supervisorId!.isEmpty ? null : supervisorId,
          "dateofjoining": enteredJoinDate.text.trim(),
          "dateofconfirmation": enteredConfirmDate.text.trim(),
          "employeeloginid": enteredEmail.text.trim(),
          "designation": enteredDesignation.text.trim(),
          "active": true,
          "deleted": false,
          "createdon": DateTime.now().toIso8601String(),
          "createdby": userDetails['name'],
          "modifiedby": "",
          "activefromdate": DateTime.now().toIso8601String(),
          "inactivefromdate": null,
          "modifiedon": null
        };

        requestBody['dateofjoining'] = enteredJoinDate.text.isNotEmpty
            ? formatter.parse(enteredJoinDate.text.trim()).toIso8601String()
            : null;

        requestBody['dateofconfirmation'] = enteredConfirmDate.text.isNotEmpty
            ? formatter.parse(enteredConfirmDate.text.trim()).toIso8601String()
            : null;

        ref.watch(employeeBody.notifier).state = requestBody;

        setState(() {
          _isLoading = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            void onCallbackEmployee(String columnLabel, String columnValue) {
              setState(() {
                if (columnLabel == "Supervisor Name") {
                  selectedSupervisor = columnValue;
                }

                List<String> namedParts = selectedSupervisor!.split(" ");
                String firstName = namedParts[0];
                String lastName = namedParts[namedParts.length - 1];
                supervisorId = ref
                    .read(employeeMasterListNotifier)
                    .firstWhere((e) =>
                        e.firstName == firstName && e.lastName == lastName)
                    .employeeId!;
              });
            }
// ------------------------------------------------

            Widget firstName = SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InputControl(
                    isMandatory: true,
                    columnLabel: "First Name",
                    columnEnteredValue: enteredFirstName),
              ),
            );

// ------------------------------------------------
            Widget middlename = SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InputControl(
                    isMandatory: false,
                    columnLabel: "Middle Name",
                    columnEnteredValue: enteredMiddleName),
              ),
            );
// ------------------------------------------------
            Widget lastName = SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InputControl(
                    isMandatory: true,
                    columnLabel: "Last Name",
                    columnEnteredValue: enteredLastName),
              ),
            );
// ------------------------------------------------

            Widget emailId = SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InputControl(
                    isMandatory: true,
                    isEmailFiled: true,
                    columnLabel: "Email ID",
                    columnEnteredValue: enteredEmail),
              ),
            );
// ------------------------------------------------

            Widget gender = SizedBox(
              width: 200,
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: PickControl(
                    columnLabel: "Gender",
                    columnSelectedValue: selectedGender!,
                    itemlist: const ['Male', 'Female', 'Other'],
                    onPickChange: (columnName, columnValue) {
                      selectedGender = columnValue;
                    },
                    isMandatory: false),
              ),
            );
// ------------------------------------------------

            Widget mobileNumber = SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InputControl(
                    allowonlyNumbers: true,
                    isMobileNumber: true,
                    isMandatory: false,
                    columnLabel: "Mobile Number",
                    columnEnteredValue: enteredMobileNo),
              ),
            );
// ------------------------------------------------

            Widget education = SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InputControl(
                    maxLine: 10,
                    columnLabel: "Highest Education Qualification",
                    columnEnteredValue: enteredEducation),
              ),
            );
// ------------------------------------------------
            Widget dateofjoining = SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DateController(
                  bDisablePastDate: false,
                  columnLabel: 'Date of Joining',
                  columnEnteredValue: enteredJoinDate,
                  isMandatory: false,
                  isJoiningDate: true,
                  bDisableFutureDate: true,
                ),
              ),
            );
// -----------------------------------------------

            Widget dateofconfirmation = SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DateController(
                  bDisablePastDate: true,
                  isConfirmationDate: true,
                  columnLabel: 'Date of Confirmation',
                  columnEnteredValue: enteredConfirmDate,
                  isMandatory: false,
                  bDisableFutureDate: false,
                ),
              ),
            );
// ------------------------------------------------
            Widget employeeid = SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InputControl(
                    isMandatory: true,
                    columnLabel: "Employee ID",
                    columnEnteredValue: enteredEmpId),
              ),
            );

// ------------------------------------------------

            Widget designation = SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InputControl(
                    isMandatory: false,
                    columnLabel: "Designation",
                    columnEnteredValue: enteredDesignation),
              ),
            );
// ------------------------------------------------

            Widget department = SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InputControl(
                    isMandatory: false,
                    columnLabel: "Department",
                    columnEnteredValue: enteredDepartment),
              ),
            );
// ------------------------------------------------

            Widget supervisor = SizedBox(
              width: 285,
              child: PickControl(
                  isSearchPickList: true,
                  columnLabel: "Supervisor Name",
                  columnSelectedValue: selectedSupervisor!,
                  itemlist: List<String>.from(ref
                      .read(employeeMasterListNotifier)
                      .map((element) =>
                          '${element.firstName} ${element.lastName}')
                      .toList()),
                  onPickChange: onCallbackEmployee,
                  isMandatory: false),
            );
// ------------------------------------------------

            //FORM
            Widget content = Form(
                key: _formKey,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  padding: const EdgeInsets.all(10.0),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              color:
                                  Theme.of(context).appBarTheme.backgroundColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "Employee",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .appBarTheme
                                    .backgroundColor,
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
                                  firstName,
                                  const SizedBox(
                                    width: 25,
                                  ),
                                  middlename,
                                  const SizedBox(
                                    width: 25,
                                  ),
                                  lastName
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Row(
                                children: [
                                  emailId,
                                  const SizedBox(
                                    width: 25,
                                  ),
                                  mobileNumber,
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  gender,
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Row(
                                children: [
                                  education,
                                  const SizedBox(
                                    width: 25,
                                  ),
                                  dateofjoining,
                                  const SizedBox(
                                    width: 25,
                                  ),
                                  dateofconfirmation,
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Row(
                                children: [
                                  employeeid,
                                  const SizedBox(
                                    width: 25,
                                  ),
                                  designation,
                                  const SizedBox(
                                    width: 25,
                                  ),
                                  department,
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: supervisor,
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
                              ElevatedButton(
                                  onPressed: submitEmployee,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.save),
                                      const SizedBox(
                                        width: 6,
                                      ),
                                      Text(widget.recordType == "Edit"
                                          ? "Update"
                                          : "Save")
                                    ],
                                  )),
                            ],
                          ),
                        )
                      ],
                    ),
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
              return const EmployeeNavigation();
            }

            if (_isLoading) {
              if (isResolutionChanged) {
                return const EmployeeNavigation();
              }
              if (widget.recordType == "Edit") {
                final response = ref.watch(updateEmployeeMaster);
                return response.when(
                  loading: () => contentLoading,
                  error: (err, stack) => contentException('Error: $err'),
                  data: (config) => contentSuccess(response.value!),
                );
              } else {
                final response = ref.watch(saveEmployeeMaster);
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
