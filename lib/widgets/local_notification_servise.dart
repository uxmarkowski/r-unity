import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';


class LocalNotificationService {

  String testVar='';
  LocalNotificationService();

  final _localNotificationService = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String?> onNotificationClick = BehaviorSubject();

  Future<void> intialize() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@drawable/ic_stat_all_inclusive');


    IOSInitializationSettings iosInitializationSettings =
    IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    final InitializationSettings settings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    final details2= await _localNotificationService.getNotificationAppLaunchDetails();
    if(details2 != null && details2.didNotificationLaunchApp) {
      onNotificationClick.add(details2.payload);
    }

    await _localNotificationService.initialize(
      settings,
      onSelectNotification: onSelectNotification,
    );
  }

  Future<NotificationDetails> _notificationDetails() async {
    final audio="";
    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      "audioName", "audioName",
        channelDescription: "audioName",
        importance: Importance.high,
        priority: Priority.high,
        playSound: false,
        // sound: RawResourceAndroidNotificationSound(audioName)
        );

    IOSNotificationDetails iosNotificationDetails =
    IOSNotificationDetails();

    return NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final details = await _notificationDetails();
    await _localNotificationService.show(id, title, body, details);
  }

  Future<void> showNotificationRepeat({
    required int id,
    required String title,
    required String body,
  }) async {
    final details = await _notificationDetails();
    RepeatInterval intervalchik=RepeatInterval.everyMinute;
    await _localNotificationService.periodicallyShow(id, title, body, RepeatInterval.everyMinute, details);
  }

  Future<void> deleteAllNotification() async {
    await _localNotificationService.cancelAll();
  }

  Future<void> closeNotification({
    required int id,
  }) async {
    await _localNotificationService.cancel(id);
  }

  Future<void> closeAllNotification() async {
    await _localNotificationService.cancelAll();
  }


  Future<void> showScheduledNotification(
      {required int id,
        required String title,
        required String body,
        required int seconds}) async {
    final details = await _notificationDetails();
    await _localNotificationService.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(
        DateTime.now().add(Duration(seconds: seconds)),
        tz.local,
      ),
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
    print("Уведомление прищло");

  }

  Future<void> showScheduledNotificationRep(
      {required int id,
        required String title,
        required String body,
        required DateTime time,
        required int DateInd,
      }) async {

    // tz.initializeTimeZones();

    final details = await _notificationDetails();
    _localNotificationService.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(
        (time as DateTime).add(Duration(days: DateInd)),
        tz.local,
      ),
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );



    if(DateInd<3) {
      print("Порядок");
      showScheduledNotificationRep(id: id+1, title: title, body: body,time: time,DateInd: DateInd+1);
    }


  }

  Future<void> showNotificationWithPayload(
      {required int id,
        required String title,
        required String body,
        required String payload}) async {
    final details = await _notificationDetails();
    await _localNotificationService.show(id, title, body, details,
        payload: payload);
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    print('id $id');
  }

  void onSelectNotification(String? payload) {
    print('payload $payload');
    if (payload != null && payload.isNotEmpty) {
      onNotificationClick.add(payload);
    }
  }
}