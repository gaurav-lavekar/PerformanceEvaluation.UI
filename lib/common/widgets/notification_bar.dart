import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:perf_evaluation/common/utilities/notification_type_data.dart';
import 'package:perf_evaluation/common/utilities/notification_type.dart';

showNotificationBar(NotificationTypes type, String notificationMsg)
{
    return AnimatedSnackBar(
      duration: const Duration(seconds: 3),
      mobileSnackBarPosition: MobileSnackBarPosition.top,
      desktopSnackBarPosition: DesktopSnackBarPosition.topRight,
      builder: ((context) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        color: notificationdata[type]!.color,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              notificationdata[type]!.icon,
              color: Colors.white,
              size: 50,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  notificationdata[type]!.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                const SizedBox(height: 1),
                SizedBox(
                  width: 250,
                  child: Text(
                    notificationMsg,
                    maxLines: 3,
                    //overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            )
          ],
        ),
      );
    })
      );

}