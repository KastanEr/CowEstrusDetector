import 'package:flutter/material.dart';
import 'my_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Estrus Detector',
      routerConfig: router,
    );
  }
}
