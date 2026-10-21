import 'package:flutter/material.dart';

void main() {
  runApp(const TallyApp());
}

class TallyApp extends StatelessWidget {
  const TallyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tally App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TallyPage(),
    );
  }
}

class TallyPage extends StatefulWidget {
  const TallyPage({super.key});

  @override
  State<TallyPage> createState() => _TallyPageState();
}

class _TallyPageState extends State<TallyPage> {
  // ပုံထဲမှ စာသားများ
  final List<String> _phrases = [
    "အရဟံဝတ လာဘံ ဟေတုပစ္စယော",
    "အရဟံဝတ လာဘံ အရမ္မဏပစ္စယော",
    "အရဟံဝတ လာဘံ အဓိပတိပစ္စယော",
    "အရဟံဝတ လာဘံ အနန္တရပစ္စယော",
    "အရဟံဝတ လာဘံ သမနန္တရပစ္စယော",
    "အရဟံဝတ လာဘံ သဟဇာတပစ္စယော",
    "အရဟံဝတ လာဘံ အညမညပစ္စယော",
    "အရဟံဝတ လာဘံ နိဿယပစ္စယော",
    "အရဟံဝတ လာဘံ ဥပနိဿယပစ္စယော",
    "အရဟံဝတ လာဘံ ပုရေဇာတပစ္စယော",
    "အရဟံဝတ လာဘံ ပစ္ဆာဇာတပစ္စယော",
    "အရဟံဝတ လာဘံ အာသေဝနပစ္စယော",
    "အရဟံဝတ လာဘံ ကမ္မပစ္စယော",
    "အရဟံဝတ လာဘံ ဝိပါကပစ္စယော",
    "အရဟံဝတ လာဘံ အဟာရပစ္စယော",
    "အရဟံဝတ လာဘံ ဣနြ ဒိယပစ္စယော",
    "အရဟံဝတ လာဘံ ဈာနပစ္စယော",
    "အရဟံဝတ လာဘံ မဂ္ဂပစ္စယော",
    "အရဟံဝတ လာဘံ သမ္မယုတ္တပစ္စယော",
    "အရဟံဝတ လာဘံ ဝိပ္ပယုတ္တပစ္စယော",
    "အရဟံဝတ လာဘံ အတ္တိပစ္စယော",
    "အရဟံဝတ လာဘံ နတ္ထိပစ္စယော",
    "အရဟံဝတ လာဘံ ဝိဂတပစ္စယော",
    "အရဟံဝတ လာဘံ အဝိဂတပစ္စယောတိ။",
  ];

  int _currentIndex = 0;
  int _count = 24; // Default count
  int _weeks = 7;   // Default weeks

  void _nextPhrase() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _phrases.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tally'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: GestureDetector(
        onTap: _nextPhrase,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent, 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  _phrases[_currentIndex],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_count ကြိမ်, ',
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    '$_weeks ပတ်',
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                '(မျက်နှာပြင်ကို နှိပ်၍ စာကြောင်းပြောင်းပါ)',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}