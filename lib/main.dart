import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'app/data/public.dart';
import 'app/modules/quiz/componen/quiz_provider.dart';
import 'app/modules/testpage/componen/test_provider.dart';
import 'app/routes/app_pages.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init('token-mekanik');
  await GetStorage.init('role-mekanik');

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight
  ]);

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => TestProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

void startPollingNotifications() {
  const pollingInterval = Duration(minutes: 1);

  Timer.periodic(pollingInterval, (timer) async {
    print("Polling notification...");
  });
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _token;

  @override
  void initState() {
    super.initState();

    requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    final token = Publics.controller.getToken.value;
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Agency Room",
      initialRoute: token.isEmpty ? AppPages.INITIAL : Routes.SPLASHSCREEN,
      getPages: AppPages.routes,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: ThemeMode.system,
    );
  }
}

Future<bool> requestPermission() async {
  PermissionStatus status = await Permission.mediaLibrary.request();

  if (status.isGranted) {
    return true;
  } else if (status.isDenied) {
    status = await Permission.storage.request();

    return false;
  } else if (status.isPermanentlyDenied) {
    openAppSettings(); // Prompt user to open settings
    return false;
  }

  return false;
}
