import 'package:flutter/material.dart';

enum StatusMessagesType { draft, approved, rejected, submitted }

class StatusTheme {
  const StatusTheme(this.color);

  final Color color;
}

const statusmessages = {
  StatusMessagesType.draft: "Saved Draft",
  StatusMessagesType.rejected: "Rejected",
  StatusMessagesType.approved: "Approved",
  StatusMessagesType.submitted: "Submitted"
};

const statusmessagedata = {
  StatusMessagesType.draft: StatusTheme(
    Color.fromARGB(255, 255, 174, 1),
  ),
  StatusMessagesType.rejected: StatusTheme(
    Color.fromARGB(255, 229, 54, 54),
  ),
  StatusMessagesType.approved: StatusTheme(
    Color.fromARGB(255, 4, 242, 103),
  ),
  StatusMessagesType.submitted: StatusTheme(
    Colors.blue,
  ),
};
