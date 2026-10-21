import 'package:flutter/material.dart';
import 'pages/tally_page.dart';

void main() => runApp(const TallyApp());

class TallyApp extends StatelessWidget {
  const TallyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'အဓိဋ္ဌာန်ပုတီး',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const TallyPage(),
    );
  }
}
