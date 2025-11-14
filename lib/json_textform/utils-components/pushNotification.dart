import 'dart:io';

import 'package:astor_mobile/http/astorHttp.dart';
import 'package:astor_mobile/model/AstorProvider.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:device_id/device_id.dart';
import 'package:flutter/foundation.dart' show consolidateHttpClientResponseBytes, debugPrintThrottled, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:workmanager/workmanager.dart';

late String uuid;
String deviceType=getDeviceType();


void getDeviceIdentifier() async {
  if (kIsWeb)
    uuid="0000000000000000";
  else
    uuid=await DeviceId.getID;
}

String getDeviceType() {
  if (kIsWeb)
    return "web";
  if (Platform.isAndroid)
    return "Android";
  if (Platform.isIOS)
    return "IOS";
  if (Platform.isLinux)
    return "Linux";
  if (Platform.isMacOS)
    return "MacOS";
  if (Platform.isWindows)
    return "Windows";
  if (Platform.isFuchsia)
    return "Fuchsia";
  return "unknown";
}
const String taskId = "pwr.notification";
Future<void> subscribeBackroundTask() async {
  if (kIsWeb) return;
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );
  Workmanager().cancelAll();
  String channel=GetStorage().read("channel");
  String url = AstorProvider.url;
  if (channel!=null && channel!="") {
    Workmanager().registerPeriodicTask(
      taskId,
      taskId,
      inputData: {
        "url" : url,
        "channel": channel,
      },
      frequency: Duration(minutes: 15),
    );
  }
}
void callbackDispatcher() {
  if (kIsWeb) return;
  Workmanager().executeTask((task, inputData) async {

    debugPrint("Callback call");
    PushNotification notification = PushNotification();
    await notification.communicate(inputData!);

    return Future.value(true);
  });
}
class PushNotification {
  static final PushNotification _pushNotification = PushNotification._internal();
  FlutterLocalNotificationsPlugin flip = new FlutterLocalNotificationsPlugin();
  String? channel;
  String? url;

  factory PushNotification() {
    return _pushNotification;
  }

  PushNotification._internal() {
    _prepareNotifications();
  }
  void subscribe(AstorProvider provider) async {
    final storage = GetStorage();
    channel=GetStorage().read("channel");
    if (channel!=null && channel!="") {
      debugPrint("Ya suscripto a: {$channel}");
      await communicate( {
       "url" : AstorProvider.url,
       "channel": channel,
      });

      return; // ya suscripto
    }
    debugPrint("try subscribe");
    String channelId=await provider.subscribe();
    if (channelId==null || channelId=="") {
      debugPrint("Fallo subscripcion!!!!");
      return; // fallo
    }
    channel=channelId;
    debugPrint("suscripto como: {$channel}");
    storage.write("channel", channelId);
    storage.save();
  }

  Future<void> communicate(Map<String,dynamic> inputData) async {
    channel = inputData['channel'];
    url = inputData['url'];

    if (channel==null) return;
    if (url==null) return;
    List<AstorNotif>? notis  = await doNotification();
    if (notis==null) {
      return;
    }
    int size = notis.length;
    for(AstorNotif noti in notis) {
      _showNotificationWithDefaultSound(noti);
    }

  }

  AstorWebHttp getHttp() {
    AstorWebHttp obj = AstorWebHttp.instance;
    obj.open(url!);
    obj.setResponses(
        doNotif: processNotif,
    );
    return obj;
  }

  Future<List<AstorNotif>>? doNotification() {
    AstorWebHttp astorHttp = getHttp();

    String nextUrl = "/do-pushnotification";
    Map<String, String> params = Map<String, String>();
    params['mobile_channel']=channel!;
    return astorHttp.notification(nextUrl, params);
  }
  Future<List<AstorNotif>> processNotif(dynamic json) async {
    List<AstorNotif> itemsList = [];

    if (json['messages'] != null) {
      var listItems = json['messages'] as List;
      for (var i in listItems) {
        AstorNotif item = AstorNotif.fromJson(i);
        itemsList.add(item);
      }
    }
    return itemsList;
  }
  Future _prepareNotifications() async {
    // initialise the plugin of flutterlocalnotifications.

    // app_icon needs to be a added as a drawable
    // resource to the Android head project.
    var android = new AndroidInitializationSettings('app_icon');
    var IOS = new IOSInitializationSettings();

    // initialise settings for both Android and iOS device.
    var settings = new InitializationSettings(android: android, iOS: IOS);
    flip.initialize(settings);

  }

  Future _showNotificationWithDefaultSound(AstorNotif notif) async {
    // Show a notification after every 15 minute with the first
    // appearance happening a minute after invoking the method
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'pwr.channel',
        'pwr',
        'pwr communications',
        importance: Importance.max,
        priority: Priority.high
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();

    // initialise channel platform for both Android and iOS device.
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics
    );
    await flip.show(0, notif.title,
        notif.info,
        platformChannelSpecifics, payload: 'Default_Sound'
    );
  }

}

