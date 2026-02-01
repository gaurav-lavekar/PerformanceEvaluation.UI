import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/common/widgets/notification_bar.dart';
import 'package:perf_evaluation/features/category_master/application/category_provider.dart';
import 'package:perf_evaluation/features/category_master/models/category_master_model.dart';
import 'package:perf_evaluation/features/category_master/presentation/category_navigation.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';
import 'package:syn_form_fields/syn_form_fields.dart';
import 'package:syn_multitenancy/login/presentation/widgets/loading_widget.dart';
import 'package:syn_useraccess/common/widget/form_controls/accesscontrolledwidget.dart';

class NewCategory extends ConsumerStatefulWidget {
  const NewCategory(
      {super.key,
      this.selectedCategory,
      required this.recordType,
      required this.onAdd});

  final List<CategoryMaster>? selectedCategory;

  final String recordType;
  final void Function(bool flg, List<CategoryMaster> selectedCategory) onAdd;

  @override
  ConsumerState<NewCategory> createState() {
    return _NewCategoryScreenState();
  }
}

class _NewCategoryScreenState extends ConsumerState<NewCategory> {
  var _isLoading = false;
  final moduleName = 'O_Category';
  var isResolutionChanged = false;

  late Future<void> combinedFuture;

  @override
  void initState() {
    super.initState();
    initialData();
  }

  Future<void> initialData() async {
    List<Future> futures = [];
    if (ref.read(categoryMasterListNotifier).isEmpty) {
      futures.add(ref.read(categoryMaster.future));
    }

    combinedFuture = Future.wait(futures);
    await combinedFuture;

    if (widget.recordType == "Edit") {
      setState(() {
        enteredCategory.text =
            widget.selectedCategory![0].ratingCategoryName ?? "";
      });
    }
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController enteredCategory = TextEditingController();

  @override
  void dispose() {
    enteredCategory.dispose();
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
      if (enteredCategory.text.trim() !=
          widget.selectedCategory![0].ratingCategoryName) {
        return true;
      }
    } else {
      if (enteredCategory.text.isNotEmpty) return true;
    }
    return false;
  }

  submitCategory() async {
    Map<String, dynamic> requestBody;
    String category = enteredCategory.text.trim();
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

      if (!validPattern.hasMatch(category)) {
        showNotificationBar(NotificationTypes.error, "Invalid Category")
            .show(context);
        return;
      }

      if (widget.recordType == "Edit") {
        widget.selectedCategory![0].ratingCategoryName = category;
        requestBody = {
          'ratingcategoryid': widget.selectedCategory![0].ratingCategoryId,
          'ratingcategoryname': widget.selectedCategory![0].ratingCategoryName,
          'deleted': false
        };

        ref.watch(updateCategoryBody.notifier).state = requestBody;
        setState(() {
          _isLoading = true;
        });
      } else {
        requestBody = {'ratingcategoryname': category, 'deleted': false};

        ref.watch(categoryBody.notifier).state = requestBody;

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
            Widget category = SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InputControl(
                    allowonlyNumbers: false,
                    isMandatory: true,
                    columnLabel: "Category",
                    columnEnteredValue: enteredCategory),
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
                                  "Category",
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
                                children: [category],
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
                                        onPressed: submitCategory,
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
              return const CategoryNavigation();
            }

            if (_isLoading) {
              if (isResolutionChanged) {
                return const CategoryNavigation();
              }
              if (widget.recordType == "Edit") {
                final response = ref.watch(updateCategoryMaster);
                return response.when(
                  loading: () => contentLoading,
                  error: (err, stack) => contentException('Error: $err'),
                  data: (config) => contentSuccess(response.value!),
                );
              } else {
                final response = ref.watch(saveCategoryMaster);
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
