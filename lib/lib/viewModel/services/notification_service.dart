import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:digihealthcardapp/res/colors.dart';
import 'package:flutter/foundation.dart';

class NotificationHelper {
  void initializeAwesomeNotification(String channelKeyExtra) {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'schedule_channel $channelKeyExtra',
          channelName: 'vaccine reminder',
          defaultColor: AppColors.primaryColor,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          channelDescription: 'for vaccine reminders',
        ),
      ],
    );
  }

  Future<void> createVaccineReminderNotification(DateTime? notificationSchedule,
      int id, String vaccineName, String childName) async {
    if (kDebugMode) {
      print(childName);
    }
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id + childName.length,
        channelKey: 'schedule_channel $childName',
        title: '${Emojis.person_child} $vaccineName',
        body: 'it\'s time for your child\'s $vaccineName vaccine.',
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        category: NotificationCategory.Event,
        autoDismissible: false,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'got it!',
          label: 'got it!',
        )
      ],
      schedule: NotificationCalendar.fromDate(
          allowWhileIdle: true, date: notificationSchedule!),
    );
  }

  Future<void> cancelScheduledNotifications(String channelKey, int id) async {
    await AwesomeNotifications().cancel(id + channelKey.length);
  }
}
