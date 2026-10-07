import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/appointment.dart';
import '../presentation/formatters.dart';
import 'reminder_scheduler.dart';

class LocalReminderScheduler implements ReminderScheduler {
  LocalReminderScheduler([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'lembretes',
      'Lembretes de consulta',
      channelDescription: 'Avisos antes das consultas agendadas',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> init() async {
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// O id da notificação precisa ser int; deriva do id textual da consulta.
  int _notificationId(String appointmentId) =>
      appointmentId.hashCode & 0x7fffffff;

  @override
  Future<void> schedule(
    Appointment appointment, {
    required DateTime at,
    required String doctorName,
  }) {
    // Instante absoluto: não depende do fuso configurado no pacote timezone.
    return _plugin.zonedSchedule(
      id: _notificationId(appointment.id),
      title: 'Consulta em breve',
      body: '$doctorName – ${formatDateTime(appointment.dateTime)}',
      scheduledDate: tz.TZDateTime.from(at, tz.UTC),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancel(String appointmentId) =>
      _plugin.cancel(id: _notificationId(appointmentId));
}
