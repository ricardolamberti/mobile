import 'dart:io';

import 'package:astor_mobile/http/astorHttp.dart';
import 'package:astor_mobile/model/AstorProvider.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:device_id/device_id.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:workmanager/workmanager.dart';

late String uuid;
final String deviceType = getDeviceType();

Future<void> getDeviceIdentifier() async {
  if (kIsWeb) {
    uuid = "0000000000000000";
  } else {
    uuid = await DeviceId.getID;
  }
}

String getDeviceType() {
  if (kIsWeb) {
    return "web";
  }
  if (Platform.isAndroid) {
    return "Android";
  }
  if (Platform.isIOS) {
    return "IOS";
  }
  if (Platform.isLinux) {
    return "Linux";
  }
  if (Platform.isMacOS) {
    return "MacOS";
  }
  if (Platform.isWindows) {
    return "Windows";
  }
  if (Platform.isFuchsia) {
    return "Fuchsia";
  }
  return "unknown";
}

const String taskId = "pwr.notification";

Future<void> subscribeBackroundTask() async {
  if (kIsWeb) {
    return;
  }
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );
  Workmanager().cancelAll();
  final String? channel = GetStorage().read<String>("channel");
  final String url = AstorProvider.url;
  if (channel != null && channel.isNotEmpty) {
    Workmanager().registerPeriodicTask(
      taskId,
      taskId,
      inputData: {
        "url": url,
        "channel": channel,
      },
      frequency: const Duration(minutes: 15),
    );
  }
}

void callbackDispatcher() {
  if (kIsWeb) {
    return;
  }
  Workmanager().executeTask((task, inputData) async {
    debugPrint("Callback call");
    final PushNotification notification = PushNotification();
    await notification.communicate(inputData);
    return Future.value(true);
  });
}
class PushNotification {
  static final PushNotification _pushNotification = PushNotification._internal();
  final FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();
  String? channel;
  String? url;

  factory PushNotification() {
    return _pushNotification;
  }

  PushNotification._internal() {
    _prepareNotifications();
  }

  Future<void> subscribe(AstorProvider provider) async {
    final storage = GetStorage();
    channel = storage.read<String>("channel");
    if (channel != null && channel!.isNotEmpty) {
      debugPrint("Ya suscripto a: {$channel}");
      await communicate({
        "url": AstorProvider.url,
        "channel": channel,
      });

      return; // ya suscripto
    }
    debugPrint("try subscribe");
    final String channelId = await provider.subscribe();
    if (channelId.isEmpty) {
      debugPrint("Fallo subscripcion!!!!");
      return; // fallo
    }
    channel = channelId;
    debugPrint("suscripto como: {$channel}");
    storage.write("channel", channelId);
    storage.save();
  }

  Future<void> communicate(Map<String, dynamic>? inputData) async {
    channel = inputData?['channel'] as String? ?? channel;
    url = inputData?['url'] as String? ?? url;

    if (channel == null || channel!.isEmpty) {
      return;
    }
    if (url == null || url!.isEmpty) {
      return;
    }
    final List<AstorNotif> notis = await doNotification();
    if (notis.isEmpty) {
      return;
    }
    for (final AstorNotif noti in notis) {
      await _showNotificationWithDefaultSound(noti);
    }
  }

  AstorWebHttp getHttp() {
    final AstorWebHttp obj = AstorWebHttp.instance;
    obj.open(url!);
    obj.setResponses(
      doNotif: processNotif,
    );
    return obj;
  }

  Future<List<AstorNotif>> doNotification() async {
    final AstorWebHttp astorHttp = getHttp();

    const String nextUrl = "/do-pushnotification";
    final Map<String, String> params = <String, String>{
      'mobile_channel': channel!,
    };
    return astorHttp.notification(nextUrl, params);
  }
  Future<List<AstorNotif>> processNotif(dynamic json) async {
    final List<AstorNotif> itemsList = [];

    if (json['messages'] != null) {
      var listItems = json['messages'] as List;
      for (var i in listItems) {
        AstorNotif item = AstorNotif.fromJson(i);
        itemsList.add(item);
      }
    }
    return itemsList;
  }
  Future<void> _prepareNotifications() async {
    // initialise the plugin of flutterlocalnotifications.

    // app_icon needs to be a added as a drawable
    // resource to the Android head project.
    const android = AndroidInitializationSettings('app_icon');
    const IOS = IOSInitializationSettings();

    // initialise settings for both Android and iOS device.
    const settings = InitializationSettings(android: android, iOS: IOS);
    flip.initialize(settings);

  }

  Future<void> _showNotificationWithDefaultSound(AstorNotif notif) async {
    // Show a notification after every 15 minute with the first
    // appearance happening a minute after invoking the method
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'pwr.channel',
        'pwr',
        'pwr communications',
        importance: Importance.max,
        priority: Priority.high
    );
    const iOSPlatformChannelSpecifics = IOSNotificationDetails();

    // initialise channel platform for both Android and iOS device.
    const platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics
    );
    await flip.show(0, notif.title,
        notif.info,
        platformChannelSpecifics, payload: 'Default_Sound'
    );
  }

}

