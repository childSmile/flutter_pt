import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:production_tool_app/app/routes/app_pages.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.routerName});

  final String routerName;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    print("routename===${widget.routerName}");

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "My Merit",
      initialRoute: widget.routerName, //AppPages.INITIAL,
      getPages: AppPages.routes, //AppPages.routes,
      themeMode: Get.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
              color: Color(0xff333333),
              fontSize: 16,
              fontWeight: FontWeight.w500),
        ),
        primaryColor: const Color(0xff17D2E3),
        colorScheme: const ColorScheme.light(surface: Colors.white),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        primaryColor: const Color(0xff17D2E3),
        colorScheme: const ColorScheme.dark(surface: Colors.black87),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      // translationsKeys: AppTranslation.translations,
      locale: const Locale("zh", "CN"),
      fallbackLocale: const Locale("en", "US"),
    );
  }
}
