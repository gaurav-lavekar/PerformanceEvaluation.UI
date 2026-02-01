import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';
import 'package:perf_evaluation/common/widgets/notification_bar.dart';
import 'package:perf_evaluation/features/employee_master/application/employee_provider.dart';
import 'package:perf_evaluation/features/my_goals/application/goal_provider.dart';

class DateController extends ConsumerStatefulWidget {
  const DateController(
      {required this.columnLabel,
      required this.columnEnteredValue,
      this.isBorderRequired = false,
      this.isMandatory = false,
      this.isConfirmationDate = false,
      this.isJoiningDate = false,
      this.isGoalEndDate = false,
      this.isGoalStartDate = false,
      this.bDisableFutureDate = false,
      this.bDisablePastDate = false,
      super.key});

  final String columnLabel;
  final bool isBorderRequired;
  final bool isMandatory;
  final bool bDisableFutureDate;
  final bool bDisablePastDate;
  final bool isConfirmationDate;
  final bool isJoiningDate;
  final bool isGoalStartDate;
  final bool isGoalEndDate;

  final TextEditingController columnEnteredValue;

  @override
  ConsumerState<DateController> createState() => _DateControlState();
}

class _DateControlState extends ConsumerState<DateController> {
  final formatter = DateFormat('MM/dd/yyyy');
  int goalfinancialyear = 0;
  DateTime? goalStartDate;

  @override
  Widget build(BuildContext context) {
    presentDatePicker() async {
      final now = DateTime.now();
      if (widget.isJoiningDate == true) {
        DateTime firstDate = DateTime(2000, DateTime.january, 1);
        DateTime lastDate = DateTime(now.year + 1, DateTime.march, 31);
        if (widget.bDisableFutureDate == true) {
          lastDate = now;
        }
        if (widget.bDisablePastDate == true) {
          firstDate = now;
        }
        var pickedDate = await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: firstDate,
          lastDate: lastDate,
        );

        widget.columnEnteredValue.text = formatter.format(pickedDate!);
        ref.watch(dateofjoining.notifier).state = formatter.format(pickedDate);
      }
      if (widget.isConfirmationDate == true) {
        if (ref.read(dateofjoining).isEmpty) {
          showNotificationBar(
                  NotificationTypes.info, "Please select the date of joining")
              .show(context);
          return;
        }
        DateTime firstDate = formatter.parse(ref.read(dateofjoining));
        DateTime lastDate = DateTime(firstDate.year + 10, DateTime.march, 31);

        var pickedDate = await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: firstDate,
          lastDate: lastDate,
        );

        widget.columnEnteredValue.text = formatter.format(pickedDate!);
      }
      if (widget.isGoalStartDate == true) {
        final RegExp fyRegex = RegExp(r'^FY\s(\d{4})-(\d{2})$');
        final match = fyRegex.firstMatch(ref.read(financialyear));

        if (match != null) {
          goalfinancialyear = int.parse(match.group(1)!);
        } else {
          showNotificationBar(
                  NotificationTypes.info, "Please select financial year")
              .show(context);
          return;
        }
        DateTime startDate = DateTime(goalfinancialyear, DateTime.april, 1);
        DateTime endDate = DateTime(goalfinancialyear + 1, DateTime.march, 31);

        var pickedDate = await showDatePicker(
          context: context,
          initialDate: startDate,
          firstDate: startDate,
          lastDate: endDate,
        );

        widget.columnEnteredValue.text = formatter.format(pickedDate!);
        ref.watch(goalstartdate.notifier).state = formatter.format(pickedDate);
      }
      if (widget.isGoalEndDate == true) {
        final RegExp fyRegex = RegExp(r'^FY\s(\d{4})-(\d{2})$');
        final match = fyRegex.firstMatch(ref.read(financialyear));

        if (match != null) {
          goalfinancialyear = int.parse(match.group(1)!);
        } else {
          showNotificationBar(
                  NotificationTypes.info, "Please select financial year")
              .show(context);
          return;
        }
        goalStartDate = formatter.parse(ref.read(goalstartdate));
        DateTime endDate = DateTime(goalfinancialyear + 1, DateTime.march, 31);

        var pickedDate = await showDatePicker(
          context: context,
          initialDate: goalStartDate,
          firstDate: goalStartDate!,
          lastDate: endDate,
        );

        widget.columnEnteredValue.text = formatter.format(pickedDate!);
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border:
                  widget.isBorderRequired ? const OutlineInputBorder() : null,
              contentPadding: const EdgeInsets.fromLTRB(12, 5, 5, 15),
              label: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: widget.columnLabel),
                    TextSpan(
                        text: widget.isMandatory ? '  *' : '',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.error)),
                  ],
                ),
              ),
              labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              suffixIcon: IconButton(
                onPressed: () {
                  presentDatePicker();
                },
                icon: const Icon(
                  Icons.calendar_month_outlined,
                  size: 20,
                ),
              ),
              isDense: true,
            ),
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return widget.isMandatory
                    ? 'Please Select ${widget.columnLabel}.'
                    : null;
              }

              return null;
            },
            controller: widget.columnEnteredValue,
          ),
        ),
      ],
    );
  }
}
