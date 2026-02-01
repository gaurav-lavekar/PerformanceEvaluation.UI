import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/common/widgets/notification_bar.dart';
import 'package:perf_evaluation/features/perspective_master/application/perspective_provider.dart';
import 'package:perf_evaluation/features/perspective_master/models/perspective_master_model.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';
import 'package:perf_evaluation/features/perspective_master/presentation/perspective_navigation.dart';
import 'package:syn_form_fields/syn_form_fields.dart';
import 'package:syn_multitenancy/login/presentation/widgets/loading_widget.dart';
import 'package:syn_useraccess/common/widget/form_controls/accesscontrolledwidget.dart';

class NewPerspective extends ConsumerStatefulWidget {
  const NewPerspective(
      {super.key,
      this.selectedPerspective,
      required this.recordType,
      required this.onAdd});

  final List<PerspectiveMaster>? selectedPerspective;

  final String recordType;
  final void Function(bool flg, List<PerspectiveMaster> selectedPerspective)
      onAdd;

  @override
  ConsumerState<NewPerspective> createState() {
    return _NewPerspectiveScreenState();
  }
}

class _NewPerspectiveScreenState extends ConsumerState<NewPerspective> {
  var _isLoading = false;
  final moduleName = 'O_Perspective';
  var isResolutionChanged = false;

  late Future<void> combinedFuture;

  @override
  void initState() {
    super.initState();
    initialData();
  }

  Future<void> initialData() async {
    List<Future> futures = [];
    if (ref.read(perspectiveMasterListNotifier).isEmpty) {
      futures.add(ref.read(perspectiveMaster.future));
    }

    combinedFuture = Future.wait(futures);
    await combinedFuture;

    if (widget.recordType == "Edit") {
      setState(() {
        enteredPerspective.text =
            widget.selectedPerspective![0].goalPerspectiveName ?? "";
      });
    }
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController enteredPerspective = TextEditingController();

  @override
  void dispose() {
    enteredPerspective.dispose();
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
      if (enteredPerspective.text !=
          widget.selectedPerspective![0].goalPerspectiveName) {
        return true;
      }
    } else {
      if (enteredPerspective.text.isNotEmpty) return true;
    }
    return false;
  }

  submitPerspective() async {
    Map<String, dynamic> requestBody;
    String goalperspectivename = enteredPerspective.text.trim();
    RegExp validPattern = RegExp(r'^[A-Za-z ]+$');

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (widget.recordType == "Edit") {
        if (!checkIfFormUpdated()) {
          showNotificationBar(NotificationTypes.info, "No changes to update")
              .show(context);
          return;
        }
      }
      if (!validPattern.hasMatch(goalperspectivename)) {
        showNotificationBar(NotificationTypes.error, "Invalid Perspective")
            .show(context);
        return;
      }

      if (widget.recordType == "Edit") {
        widget.selectedPerspective![0].goalPerspectiveName =
            enteredPerspective.text.trim();

        requestBody = {
          'goalperspectiveid': widget.selectedPerspective![0].goalPerspectiveId,
          'goalperspectivename':
              widget.selectedPerspective![0].goalPerspectiveName,
          'deleted': false
        };

        ref.watch(updatePerspectiveBody.notifier).state = requestBody;
        setState(() {
          _isLoading = true;
        });
      } else {
        requestBody = {
          'goalperspectivename': goalperspectivename,
          'deleted': false
        };

        ref.watch(perspectiveBody.notifier).state = requestBody;

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
            Widget perspective = SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InputControl(
                    isMandatory: true,
                    allowonlyNumbers: false,
                    columnLabel: "Goal Perspective",
                    columnEnteredValue: enteredPerspective),
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
                                  Icons.category,
                                  color: Theme.of(context)
                                      .appBarTheme
                                      .backgroundColor,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "Perspective",
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
                                children: [perspective],
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
                                        onPressed: submitPerspective,
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
              return const PerspectiveNavigation();
            }

            if (_isLoading) {
              if (isResolutionChanged) {
                return const PerspectiveNavigation();
              }
              if (widget.recordType == "Edit") {
                final response = ref.watch(updatePerspectiveMaster);
                return response.when(
                  loading: () => contentLoading,
                  error: (err, stack) => contentException('Error: $err'),
                  data: (config) => contentSuccess(response.value!),
                );
              } else {
                final response = ref.watch(savePerspectiveMaster);
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
