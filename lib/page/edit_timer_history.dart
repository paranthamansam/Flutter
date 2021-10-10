import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/model/history.dart';

class EditTimerHistory extends StatefulWidget {
  static String id = "EditTimerHistory";
  const EditTimerHistory({Key? key}) : super(key: key);

  @override
  _EditTimerHistoryState createState() => _EditTimerHistoryState();
}

class _EditTimerHistoryState extends State<EditTimerHistory> {
  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2021),
        lastDate: DateTime(2050));
    print(picked);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as History;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit'),
          centerTitle: true,
        ),
        body: Center(
            child: CustomDateTime(
                startTime: args.startTime, endTime: args.endTime)));
  }
}

class CustomDateTime extends StatefulWidget {
  late DateTime startTime;
  late DateTime endTime;

  CustomDateTime(
      {Key? key, required DateTime startTime, required DateTime endTime})
      : super(key: key);

  @override
  _CustomDateTimeState createState() => _CustomDateTimeState();
}

class _CustomDateTimeState extends State<CustomDateTime> {
  Future<DateTime?> _selectDateTime() async {
    late final TimeOfDay? time;
    final DateTime? date;
    date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2021),
        lastDate: DateTime(2050));
    time = await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (date != null && time != null) {
      date.add(Duration(hours: time.hour, minutes: time.minute));
    }
    return date;
  }

  @override
  Widget build(BuildContext context) {
    late DateTime? start;
    return Row(
      children: [
        IconButton(
            onPressed: () async {
              start = await _selectDateTime();
            },
            icon: const Icon(Icons.calendar_today_rounded)),
        const SizedBox(
          width: 20.0,
        ),
        Text(DateFormat.yMd().add_jm().format(start ?? DateTime.now())),
      ],
    );
  }
}
