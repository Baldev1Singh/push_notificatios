import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifications/utils/route_path.dart';

import '../navigation_service/navigation_service.dart';

///TODO:Add the below meta data in AndroidManifest.xml file in <application> </application>tag
// <meta-data
// android:name="com.google.firebase.messaging.default_notification_channel_id"
// android:value="high_importance_channel" />

class NotificationServices {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    ///TODO:Don't forget to re-initialize firebase here
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: 'AIzaSyC4KY8DVBXKXDbfOlX7iSs03lePfaUiTz4',
            appId: '1:366951299587:android:630aa5d0b34724505c2c36',
            messagingSenderId: '366951299587',
            projectId: 'coffee-c3a81'));
  }

  static Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();

    ///TODO:Store FCM token to Shared Preference
    print('Token is : $token');
    return token!;
  }

  static Future<void> isRefreshToken() async {
    messaging.onTokenRefresh.listen((event) {
      ///TODO:Store FCM token to Shared Preference
      print('Token Refresh ${event.toString()}');
    });
  }

  static void requestNotificationPermission() async {
    if (Platform.isIOS) {
      await messaging.requestPermission(
          alert: true,
          announcement: true,
          badge: true,
          carPlay: true,
          criticalAlert: true,
          provisional: true,
          sound: true);
    }

    NotificationSettings notificationSettings =
        await messaging.requestPermission(
            alert: true,
            announcement: true,
            badge: true,
            carPlay: true,
            criticalAlert: true,
            provisional: true,
            sound: true);

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      print('user is already granted permission');
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('user is already granted provisional permission');
    } else {
      print('User has denied permission');
    }
  }

  static Future fogroundMessage() async {
    //define how notifications should be displayed
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static void firebaseInit() {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;
      print(
          'Notification Title:${notification!.title},\nbody:${notification!.body},\ndata:${message.data.toString()}');
      if (Platform.isIOS) {
        fogroundMessage();
      }

      if (Platform.isAndroid) {
        initLocalNotification(message);
        showNotification(message);
      }
    });
  }

  static void initLocalNotification(RemoteMessage message) async {
    var androidInitSettings =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    var iosInitSettings = const DarwinInitializationSettings();
    var initSetting = InitializationSettings(
        android: androidInitSettings, iOS: iosInitSettings);
    await _flutterLocalNotificationsPlugin.initialize(
      initSetting,
      onDidReceiveNotificationResponse: (payload) {
        handelMessage(message);
      },
    );
  }

  static void handelMessage(RemoteMessage message) {
    print('In handel Message method');
    if (message.data['type'] == 'text') {
      ///Redirect to New Screen or Perform any task based on payload you receive.
    }

    ///TODO:Use Navigator Key for navigation on notification click
    ///Don't forget to Add navigator key in MaterialApp Widget
    NavigationService.navigateTo(routeName: RoutePath.anotherScreen);
    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => AnotherScreen(),));
  }

  static Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel androidNotificationChannel =
        AndroidNotificationChannel(
      message.notification!.android!.channelId.toString(),
      message.notification!.android!.channelId.toString(),
      importance: Importance.max,
      showBadge: true,
      playSound: true,
    );

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      androidNotificationChannel.id.toString(),
      androidNotificationChannel.name.toString(),
      channelDescription: 'Flutter Notification',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
      sound: androidNotificationChannel.sound,
    );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    Future.delayed(
      Duration.zero,
      () {
        _flutterLocalNotificationsPlugin.show(
            0,
            message.notification!.title.toString(),
            message.notification!.body.toString(),
            notificationDetails);
      },
    );
  }

  static void onBackgroundNotificationClick() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handelMessage(message);
    });
  }

  ///TODO:Call This Method in main() funtion
  static void notificationsServiceInit() {
    //Do not change the order of these method call
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    requestNotificationPermission();
    fogroundMessage();
    isRefreshToken();
    getDeviceToken();
    firebaseInit();
    onBackgroundNotificationClick();
  }
}
