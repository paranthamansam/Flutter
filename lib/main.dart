import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/page/apptimer.dart';
import 'package:date_time_picker/date_time_picker.dart';

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
          primarySwatch: Colors.indigo,
        ),
        home: const BaseLayer());
  }
}

class BaseLayer extends StatefulWidget {
  const BaseLayer({Key? key}) : super(key: key);

  @override
  State<BaseLayer> createState() => _BaseLayerState();
}

class _BaseLayerState extends State<BaseLayer> {
  DateTime picked = DateTime.now();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pick = await showDatePicker(
        context: context,
        firstDate: DateTime(2021),
        lastDate: DateTime(2050),
        initialDate: DateTime.now());
    print(pick);
    setState(() {
      if (pick != null) {
        picked = pick;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.yMd().format(picked)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {
                _selectDate(context);
              },
              icon: const Icon(
                Icons.calendar_today_rounded,
              ),
            ),
          )
        ],
      ),
      body: AppTimer(picked: picked),
    );
  }
}
