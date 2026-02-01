import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_evaluation/common/widgets/notification_bar.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';
import 'package:perf_evaluation/features/category_master/application/category_provider.dart';
import 'package:perf_evaluation/features/rating_master/application/ratings_provider.dart';
import 'package:perf_evaluation/features/rating_master/models/rating_master_model.dart';
import 'package:perf_evaluation/features/rating_master/presentation/rating_navigation.dart';
import 'package:syn_form_fields/syn_form_fields.dart';
import 'package:syn_multitenancy/login/presentation/widgets/loading_widget.dart';
import 'package:syn_useraccess/common/widget/form_controls/accesscontrolledwidget.dart';

class NewRating extends ConsumerStatefulWidget {
  const NewRating(
      {super.key,
      this.selectedRating,
      required this.recordType,
      required this.onAdd});

  final List<RatingMaster>? selectedRating;

  final String recordType;
  final void Function(bool flg, List<RatingMaster> selectedRating) onAdd;

  @override
  ConsumerState<NewRating> createState() {
    return _NewRatingScreenState();
  }
}

class _NewRatingScreenState extends ConsumerState<NewRating> {
  var _isLoading = false;
  final moduleName = 'O_Rating';
  var isResolutionChanged = false;
  String? selectedCategory = "", ratingcategoryId = "";

  late Future<void> combinedFuture;

  @override
  void initState() {
    super.initState();
    initialData();
  }

  Future<void> initialData() async {
    List<Future> futures = [];
    if (ref.read(ratingMasterListNotifier).isEmpty) {
      futures.add(ref.read(ratingMaster.future));
    }

    if (ref.read(categoryMasterListNotifier).isEmpty) {
      futures.add(ref.read(categoryMaster.future));
    }

    combinedFuture = Future.wait(futures);
    await combinedFuture;

    if (widget.recordType == "Edit") {
      setState(() {
        enteredRating.text = widget.selectedRating![0].ratingScale.toString();

        selectedCategory = widget.selectedRating![0].ratingCategory ?? "";

        ratingcategoryId = widget.selectedRating![0].ratingCategoryId ?? "";
      });
    }
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController enteredRating = TextEditingController();

  @override
  void dispose() {
    enteredRating.dispose();
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
      if (enteredRating.text !=
              widget.selectedRating![0].ratingScale.toString() ||
          ratingcategoryId != widget.selectedRating![0].ratingCategoryId) {
        return true;
      }
    } else {
      if (enteredRating.text.isNotEmpty || selectedCategory!.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  submitRating() async {
    Map<String, dynamic> requestBody;
    int ratingscale = int.parse(enteredRating.text.trim());

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (widget.recordType == "Edit") {
        if (!checkIfFormUpdated()) {
          showNotificationBar(NotificationTypes.info, "No changes to update")
              .show(context);
          return;
        }
      }

      if (ratingscale > 10 || ratingscale < 1) {
        showNotificationBar(
                NotificationTypes.error, "Rating Scale not in range")
            .show(context);
        return;
      }

      if (widget.recordType == "Edit") {
        widget.selectedRating![0].ratingScale = ratingscale;
        widget.selectedRating![0].ratingCategoryId = ratingcategoryId;

        requestBody = {
          'ratingid': widget.selectedRating![0].ratingId,
          'ratingscale': widget.selectedRating![0].ratingScale,
          'ratingcategoryid': widget.selectedRating![0].ratingCategoryId,
          'deleted': false
        };

        ref.watch(updateRatingBody.notifier).state = requestBody;

        setState(() {
          _isLoading = true;
        });
      } else {
        requestBody = {
          'ratingscale': ratingscale,
          'ratingcategoryid': ratingcategoryId,
          'deleted': false
        };

        ref.watch(ratingsBody.notifier).state = requestBody;

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
            void onCallbackCategory(String columnLabel, String columnValue) {
              if (columnLabel == "Rating Category") {
                setState(() {
                  selectedCategory = columnValue;
                });
              }

              ratingcategoryId = ref
                  .read(categoryMasterListNotifier)
                  .firstWhere((e) => e.ratingCategoryName == selectedCategory)
                  .ratingCategoryId!;
            }

            Widget rating = SizedBox(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InputControl(
                    isMandatory: true,
                    allowonlyNumbers: true,
                    columnLabel: "Rating Scale",
                    columnEnteredValue: enteredRating),
              ),
            );

            Widget ratingcategory = SizedBox(
                width: 320,
                child: PickControl(
                    columnLabel: "Rating Category",
                    columnSelectedValue: selectedCategory!,
                    itemlist: List<String>.from(ref
                        .read(categoryMasterListNotifier)
                        .map((element) => element.ratingCategoryName)
                        .toList()),
                    onPickChange: onCallbackCategory,
                    isMandatory: true));

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
                                  Icons.rate_review,
                                  color: Theme.of(context)
                                      .appBarTheme
                                      .backgroundColor,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "Ratings",
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
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  rating,
                                  const SizedBox(width: 40),
                                  ratingcategory
                                ],
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
                                        onPressed: submitRating,
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
              return const RatingNavigation();
            }

            if (_isLoading) {
              if (isResolutionChanged) {
                return const RatingNavigation();
              }
              if (widget.recordType == "Edit") {
                final response = ref.watch(updateRatingMaster);
                return response.when(
                  loading: () => contentLoading,
                  error: (err, stack) => contentException('Error: $err'),
                  data: (config) => contentSuccess(response.value!),
                );
              } else {
                final response = ref.watch(saveRatingMaster);
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
