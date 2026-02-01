import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/common/widgets/notification_bar.dart';
import 'package:perf_evaluation/features/financial_year/application/financialyear_provider.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';
import 'package:perf_evaluation/features/financial_year/models/financialyear_model.dart';
import 'package:perf_evaluation/features/financial_year/presentation/financialyear_navigation.dart';
import 'package:syn_form_fields/syn_form_fields.dart';
import 'package:syn_multitenancy/login/presentation/widgets/loading_widget.dart';
import 'package:syn_useraccess/common/widget/form_controls/accesscontrolledwidget.dart';

class NewFinancialYear extends ConsumerStatefulWidget {
  const NewFinancialYear(
      {super.key,
      this.selectedFinancialYear,
      required this.recordType,
      required this.onAdd});

  final List<FinancialYearMaster>? selectedFinancialYear;

  final String recordType;
  final void Function(bool flg, List<FinancialYearMaster> selectedFinancialYear)
      onAdd;

  @override
  ConsumerState<NewFinancialYear> createState() {
    return _NewFinancialYearScreenState();
  }
}

class _NewFinancialYearScreenState extends ConsumerState<NewFinancialYear> {
  var _isLoading = false;
  final moduleName = 'O_FinancialYear';
  var isResolutionChanged = false;

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

    combinedFuture = Future.wait(futures);
    await combinedFuture;

    if (widget.recordType == "Edit") {
      setState(() {
        enteredFinancialYear.text =
            widget.selectedFinancialYear![0].financialYear ?? "";
      });
    }
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController enteredFinancialYear = TextEditingController();

  @override
  void dispose() {
    enteredFinancialYear.dispose();
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
      if (enteredFinancialYear.text !=
          widget.selectedFinancialYear![0].financialYear) {
        return true;
      }
    } else {
      if (enteredFinancialYear.text.isNotEmpty) return true;
    }
    return false;
  }

  bool isValidFinancialYear(String fyString) {
    final RegExp fyRegex = RegExp(r'^FY\s(\d{4})-(\d{2})$');
    final match = fyRegex.firstMatch(fyString);

    if (match != null) {
      int firstYear = int.parse(match.group(1)!);
      int secondYear = int.parse(match.group(2)!);

      return secondYear == (firstYear + 1) % 100;
    }

    return false;
  }

  submitFinancialYear() async {
    Map<String, dynamic> requestBody;
    String financialyear = enteredFinancialYear.text.trim().toUpperCase();

    if (widget.recordType == "Edit") {
      if (!checkIfFormUpdated()) {
        showNotificationBar(NotificationTypes.info, "No changes to update")
            .show(context);
        return;
      }
    }
    if (!isValidFinancialYear(financialyear)) {
      showNotificationBar(NotificationTypes.error, "Invalid Financial Year")
          .show(context);
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (widget.recordType == "Edit") {
        widget.selectedFinancialYear![0].financialYear = financialyear;

        requestBody = {
          'financialyearid': widget.selectedFinancialYear![0].financialyearid,
          'financialyear': widget.selectedFinancialYear![0].financialYear,
          'deleted': false
        };

        ref.watch(updateYearBody.notifier).state = requestBody;
        setState(() {
          _isLoading = true;
        });
      } else {
        requestBody = {'financialyear': financialyear, 'deleted': false};

        ref.watch(yearBody.notifier).state = requestBody;

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
            Widget financialyear = SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InputControl(
                    isMobileNumber: false,
                    allowonlyNumbers: false,
                    isEmailFiled: false,
                    isMandatory: true,
                    columnLabel: "Financial Year",
                    columnEnteredValue: enteredFinancialYear),
              ),
            );

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
                                  Icons.calendar_month_outlined,
                                  color: Theme.of(context)
                                      .appBarTheme
                                      .backgroundColor,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "Financial Year",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .appBarTheme
                                          .backgroundColor),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Wrap(
                                children: [financialyear],
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      checkIfFormUpdated()
                                          ? _buildOnDiscard()
                                          : widget.onAdd(true, []);
                                    },
                                    child: const Text('Discard'),
                                  ),
                                  const SizedBox(width: 10),
                                  AccessControlledWidget(
                                      uiTag: moduleName,
                                      permission: userAccessHelper.AccessWrite,
                                      child: ElevatedButton.icon(
                                        onPressed: submitFinancialYear,
                                        icon: const Icon(Icons.save),
                                        label: Text(widget.recordType == "Edit"
                                            ? 'Update'
                                            : 'Save'),
                                      )),
                                ],
                              ),
                            )
                          ],
                        ))));

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
              return const FinancialYearNavigation();
            }

            if (_isLoading) {
              if (isResolutionChanged) {
                return const FinancialYearNavigation();
              }
              if (widget.recordType == "Edit") {
                final response = ref.watch(updateFinancialYear);
                return response.when(
                  loading: () => contentLoading,
                  error: (err, stack) => contentException('Error: $err'),
                  data: (config) => contentSuccess(response.value!),
                );
              } else {
                final response = ref.watch(saveFinancialYear);
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
