import 'package:flutter/material.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';

const notificationdata = {
  NotificationTypes.info: NotificationType(
    Icons.info_rounded,
    'Info',
    Color.fromARGB(255, 82, 139, 199),
  ),
  NotificationTypes.error: NotificationType(
    Icons.error_rounded,
    'Error',
    Color.fromARGB(255, 229, 54, 54),
  ),
  NotificationTypes.success: NotificationType(
    Icons.check_circle_rounded,
    'Success',
    Color.fromARGB(255, 97, 138, 82),
  ),
  NotificationTypes.warning: NotificationType(
    Icons.warning_rounded,
    'Warning',
    Color.fromARGB(255, 224, 130, 42),
  ),
};

const cardTheme = {
  CardTypes.added: CardType(
    Color.fromARGB(255, 248, 239, 63),
    Color.fromARGB(255, 0, 0, 0),
  ),
  CardTypes.canceled: CardType(
    Color.fromARGB(255, 254, 93, 93),
    Color.fromARGB(255, 0, 0, 0),
  ),
  CardTypes.editclinicspecialty: CardType(
    Color.fromARGB(255, 179, 214, 247),
    Color.fromARGB(255, 0, 0, 0),
  ),
  CardTypes.inprogress: CardType(
    Color.fromARGB(255, 234, 237, 237),
    Color.fromARGB(255, 0, 0, 0),
  ),
  CardTypes.scheduled: CardType(
    Color.fromARGB(255, 243, 255, 197),
    Color.fromARGB(255, 0, 0, 0),
  ),
  CardTypes.schedulelimited: CardType(
    Color.fromARGB(255, 126, 140, 159),
    Color.fromARGB(255, 0, 0, 0),
  ),
  CardTypes.shortenedhours: CardType(
    Color.fromARGB(255, 217, 155, 62),
    Color.fromARGB(255, 0, 0, 0),
  ),
  CardTypes.backgroundShade: CardType(
    Color.fromARGB(255, 245, 247, 255),
    Color.fromARGB(255, 0, 0, 0),
  ),
  CardTypes.successShade: CardType(
    Color.fromARGB(255, 97, 138, 82),
    Color.fromARGB(255, 0, 0, 0),
  ),
};
