import 'package:flutter/material.dart';
import 'package:tdd_arch_reso/features/number_trivia/presentation/pages/number_trivia_page.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Trivia',
      theme: ThemeData(
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.green.shade800),
      ),
      home: const NumberTriviaPage(),
    );
  }
}
