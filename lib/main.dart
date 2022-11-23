import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'INWARE SMS Sender',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List dataList = [];
  bool loading = false;
  String loadingText = "Loading ...";

  late Box<dynamic> box;

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    box = await Hive.openBox<dynamic>("settings");
    print(box.get("i", defaultValue: 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SMS sender"),
      ),
      body: !loading
          ? const SizedBox()
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  Text(loadingText),
                ],
              ),
            ),
      floatingActionButton: loading ? null : FloatingActionButton(
        onPressed: () => startSend(),
        child: const Icon(Icons.play_arrow),
      ),
    );
  }

  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/data_clients.json');
  }

  startSend() async {
    setState(() {
      loading = true;
      loadingText = "Loading data ...";
    });
    dataList = jsonDecode(await loadAsset());
/*dataList = [
  {"tr":"26","device_tr":"26","adi":"Xoliddin","soyadi":"Nabiyev","tel":"903854544"},
  {"tr":"26","device_tr":"26","adi":"Muhammad Ali","soyadi":"Nabiyev","tel":"998932137689"},
];*/
    List<String> myList = [];
    String message;
    String fish;
    int i = box.get("i", defaultValue: 0);
    for (Map data in dataList) {
      i++;
      String number = data['tel'].toString();
      if (number.length == 9) {
        number = "998$number";
        myList.add(number);
      } else if (number.length == 12) {
        myList.add(number);
      } else {
        print("Error: $i: ${data['tr']} $number - ${data['adi']} ");
        continue;
      }
      //fish = "${data['adi']} ${data['soyadi']}";
      fish = "${data['adi']}";
      setState(() {
        loading = true;
        loadingText = "Sending ...";
      });
      print("$i: ${data['tr']} $number - $fish");
      // 160 ta harf 1-sms, keyingilariga +145
      message = """Assalomu alaykum!

O'zaro hisob-kitob uchun ishingizga munosib mobil ilovani sinab ko'rishingizni tavsiya qilamiz

Sayt orqali yuklash: inware.uz/c/sms""";
      String result = await sendSMS(message: message, recipients: [number], sendDirect: true)
              .catchError((onError) {
            print("Error: $i: $onError");
          });
      print(result);
      if (i % 60 == 0) { //  || dataList.length - 60 <= i
        setState(() {
          loading = true;
          loadingText = "Waiting 60 sec ...";
        });
        await Future.delayed(const Duration(seconds: 60));
      }
      setState(() {
        loading = true;
        loadingText = "Success!";
      });
      if(i % 300 == 0) {
        box.put("i", i);
        await Future.delayed(const Duration(seconds: 120));
      }
    }
    setState(() {
      loading = false;
      loadingText = "";
    });
  }

  send(List<String> recipents) async {
    //await Future.delayed(const Duration(seconds: 2));
    const String message = "Assalomu alaykum! Bu flutterdan yuborildi";
    //List<String> recipents = ["998932137689"];
    print("Sent: $recipents");
    /*String _result = await sendSMS(message: message, recipients: recipents, sendDirect: true)
            .catchError((onError) {
          print(onError);
        });
    print(_result);*/
  }
}
