import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_lab/features/profile/presentation/async_profile_page.dart';
import 'package:riverpod_lab/features/profile/presentation/profile_page.dart';
import 'package:riverpod_lab/features/todos/presenter/todos_page.dart';

import 'features/counter/presentation/counter_page.dart';
import 'features/products/presentation/products_page.dart';

void main() {
  runApp(
    ProviderScope(
      // observers: [AppProviderObserver()],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.pink)),
      home: const ProductsPage(),
    );
  }
}
