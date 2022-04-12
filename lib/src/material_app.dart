import 'package:flutter/material.dart';

import 'home/home_page.dart';

class MyMaterialApp extends StatefulWidget {
  const MyMaterialApp({ Key? key }) : super(key: key);

  @override
  State<MyMaterialApp> createState() => _MyMaterialAppState();
}

class _MyMaterialAppState extends State<MyMaterialApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firework Test',
      home: Home(),
    );
  }
}