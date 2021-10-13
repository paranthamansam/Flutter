import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:myapp/page/apptimer.dart';
import 'package:myapp/page/edit_timer_history.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: "/",
      routes: {
        '/': (context) => const BaseLayer(),
        EditTimerHistory.id: (context) => const EditTimerHistory()
      },
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.pink,
      ),
    );
  }
}

class BaseLayer extends StatefulWidget {
  const BaseLayer({Key? key}) : super(key: key);

  @override
  State<BaseLayer> createState() => _BaseLayerState();
}

class _BaseLayerState extends State<BaseLayer> {
  DateTime picked =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  String tLeft = "00:00:00";
  String tRight = "00:00:00";
  String tSleep = "00:00:00";

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pick = await showDatePicker(
        context: context,
        firstDate: DateTime(2021),
        lastDate: DateTime(2050),
        initialDate: DateTime.now());
    setState(() {
      if (pick != null) {
        picked = pick;
      }
    });
  }

  void _nextday() {
    setState(() {
      picked = picked.add(const Duration(days: 1));
    });
  }

  void _prevday() {
    setState(() {
      picked = picked.add(const Duration(days: -1));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              // borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              gradient: LinearGradient(colors: [Colors.pink, Colors.purple])),
        ),
        // shape: const RoundedRectangleBorder(
        //     borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () {
                  _prevday();
                },
                icon: const Icon(Icons.arrow_left)),
            TextButton(
              child: Text(DateFormat.yMd().format(picked)),
              style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20.0),
                  primary: Theme.of(context).colorScheme.onPrimary),
              onPressed: () {
                _selectDate(context);
              },
            ),
            IconButton(
                onPressed: () {
                  _nextday();
                },
                icon: const Icon(Icons.arrow_right))
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.add), onPressed: () {}),
              ],
            ),
          )
        ],
      ),
      body: AppTimer(picked: picked),
    );
  }
}
