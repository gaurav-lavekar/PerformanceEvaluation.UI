import 'package:flutter/material.dart';

enum NotificationTypes { info, error, success, warning }

class NotificationType {
  const NotificationType(this.icon, this.title, this.color);

  final IconData icon;
  final String title;
  final Color color;
}

enum CardTypes {
  scheduled,
  added,
  canceled,
  shortenedhours,
  editclinicspecialty,
  schedulelimited,
  inprogress,
  backgroundShade,
  successShade,
}

class CardType {
  const CardType(this.container, this.onContainer);

  final Color container;
  final Color onContainer;
}
