import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/db/context.dart';
import 'package:myapp/model/history.dart';
import 'package:myapp/utils/date.dart';

class EditTimerHistory extends StatefulWidget {
  static String id = "EditTimerHistory";
  const EditTimerHistory({Key? key}) : super(key: key);

  @override
  _EditTimerHistoryState createState() => _EditTimerHistoryState();
}

class _EditTimerHistoryState extends State<EditTimerHistory> {
  DateTime? startTime;
  DateTime? endTime;
  String? category;
  DateFormat dateFormat = DateFormat.yMd().add_jm();

  Future<DateTime?> _selectDateTime(DateTime initial) async {
    late final TimeOfDay? time;
    DateTime? date;
    date = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(2021),
        lastDate: DateTime(2050));
    time = await showTimePicker(context: context, initialTime: TimeOfDay.now());

    setState(() {
      if (date != null && time != null) {
        date = date!.add(Duration(hours: time.hour, minutes: time.minute));
      }
    });
    return date;
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as History;
    startTime = startTime ?? args.startTime;
    endTime = endTime ?? args.endTime;
    category = category ?? args.category.toString().split('.').last;
    String dropdownValue = 'One';
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            TextFormField(
                decoration: const InputDecoration(labelText: "Start"),
                controller:
                    TextEditingController(text: dateFormat.format(startTime!)),
                readOnly: true,
                onTap: () async {
                  var sTime = await _selectDateTime(startTime!);
                  if (sTime != null) {
                    setState(() {
                      startTime = sTime;
                    });
                  }
                }),
            TextFormField(
                decoration: const InputDecoration(labelText: "End"),
                controller:
                    TextEditingController(text: dateFormat.format(endTime!)),
                readOnly: true,
                onTap: () async {
                  var sTime = await _selectDateTime(endTime!);
                  if (sTime != null) {
                    setState(() {
                      endTime = sTime;
                    });
                  }
                }),
            DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Type"),
                value: args.category.toString().split('.').last,
                onChanged: (String? cat) {
                  setState(() {
                    if (cat != null) {
                      category = cat;
                    }
                  });
                },
                items: Category.values.map((Category e) {
                  return DropdownMenuItem<String>(
                      value: e.toString().split('.').last,
                      child: Text(History.getCategoryDisplayName(e)));
                }).toList()),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.green.shade600)),
                        onPressed: () async {
                          History history =
                              await DBContext.instance.getHistoryById(args.id!);
                          history.startTime = startTime!;
                          history.endTime = endTime!;
                          history.duration =
                              Date.duration(startTime!, endTime!);
                          history.category = History.getHistoryEnum(category!);
                          DBContext.instance.update(history);
                          Navigator.pop(context);
                        },
                        child: const Text("Update",
                            style: TextStyle(
                              color: Colors.white,
                            ))),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
