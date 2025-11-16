import 'dart:io';

import 'package:astor_mobile/http/astorHttp.dart';
import 'package:astor_mobile/model/AstorProvider.dart';
import 'package:astor_mobile/model/astorSchema.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';

/// IDENTIFICADOR DE DISPOSITIVO
late String uuid;
final String deviceType = getDeviceType();

Future<void> getDeviceIdentifier() async {
  uuid = "0000000000000000";
}


String getDeviceType() {
  if (kIsWeb) return "web";
  if (Platform.isAndroid) return "Android";
  if (Platform.isIOS) return "IOS";
  if (Platform.isLinux) return "Linux";
  if (Platform.isMacOS) return "MacOS";
  if (Platform.isWindows) return "Windows";
  if (Platform.isFuchsia) return "Fuchsia";
  return "unknown";
}

const String taskId = "pwr.notification";

/// BACKGROUND TASKS
/// ------------------------------------------------------------------
/// Para usar Workmanager necesitarías el paquete `workmanager` añadido
/// en pubspec + configuración nativa. De momento lo dejo como NO-OP
/// para que compile sin ese plugin.
/// ------------------------------------------------------------------
Future<void> subscribeBackroundTask() async {
  if (kIsWeb) return;

  // 🔴 Código original (requiere workmanager):
  //
  // Workmanager().initialize(
  //   callbackDispatcher,
  //   isInDebugMode: false,
  // );
  // Workmanager().cancelAll();
  // final String? channel = GetStorage().read<String>("channel");
  // final String url = AstorProvider.url;
  // if (channel != null && channel.isNotEmpty) {
  //   Workmanager().registerPeriodicTask(
  //     taskId,
  //     taskId,
  //     inputData: {
  //       "url": url,
  //       "channel": channel,
  //     },
  //     frequency: const Duration(minutes: 15),
  //   );
  // }

  debugPrint(
    'subscribeBackroundTask(): Workmanager deshabilitado (sin dependencia).',
  );
}

void callbackDispatcher() {
  if (kIsWeb) return;

  // 🔴 Código original (requiere workmanager):
  //
  // Workmanager().executeTask((task, inputData) async {
  //   debugPrint("Callback call");
  //   final PushNotification notification = PushNotification();
  //   await notification.communicate(inputData);
  //   return Future.value(true);
  // });

  debugPrint('callbackDispatcher(): Workmanager deshabilitado.');
}

/// NOTIFICACIONES
class PushNotification {
  static final PushNotification _pushNotification =
      PushNotification._internal();

  final FlutterLocalNotificationsPlugin flip =
      FlutterLocalNotificationsPlugin();

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
    await storage.save();
  }

  Future<void> communicate(Map<String, dynamic>? inputData) async {
    channel = inputData?['channel'] as String? ?? channel;
    url = inputData?['url'] as String? ?? url;

    if (channel == null || channel!.isEmpty) return;
    if (url == null || url!.isEmpty) return;

    final List<AstorNotif> notis = await doNotification();
    if (notis.isEmpty) return;

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
      final listItems = json['messages'] as List;
      for (final i in listItems) {
        final AstorNotif item = AstorNotif.fromJson(i);
        itemsList.add(item);
      }
    }
    return itemsList;
  }

  Future<void> _prepareNotifications() async {
    // Inicializa el plugin de notificaciones locales.

    const android = AndroidInitializationSettings('app_icon');

    // 🔁 API nueva de flutter_local_notifications:
    //   - DarwinInitializationSettings reemplaza IOSInitializationSettings
    const darwin = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: android,
      iOS: darwin,
    );

    await flip.initialize(settings);
  }

  Future<void> _showNotificationWithDefaultSound(AstorNotif notif) async {
    // Configuración del canal para Android.
    // 🔁 API nueva:
    //   - el tercer parámetro ahora es named: channelDescription:
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'pwr.channel',
      'pwr',
      channelDescription: 'pwr communications',
      importance: Importance.max,
      priority: Priority.high,
    );

    // 🔁 API nueva para iOS:
    const darwinPlatformChannelSpecifics = DarwinNotificationDetails();

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
    );

    await flip.show(
      0,
      notif.title,
      notif.info,
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }
}
