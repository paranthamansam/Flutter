import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:feedtime/db/context.dart';
import 'package:feedtime/model/history.dart';
import 'package:feedtime/utils/date.dart';

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
  final _formKey = GlobalKey<FormState>();

  Future<DateTime?> _selectDateTime(DateTime initial) async {
    late final TimeOfDay? time;
    DateTime? date;
    date = await showDatePicker(
        selectableDayPredicate: (day) => day.isBefore(DateTime.now()),
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
    late History args;
    late int? historyId;
    if (ModalRoute.of(context)!.settings.arguments != null) {
      args = ModalRoute.of(context)!.settings.arguments as History;
      historyId = args.id;

      startTime = startTime ?? args.startTime;
      endTime = endTime ?? args.endTime;
      category = category ?? args.category.toString().split('.').last;
    } else {
      historyId = null;
      startTime = startTime ?? DateTime.now();
      endTime = endTime ?? startTime;
      category = category ?? Category.none.toString().split('.').last;
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Add/Edit'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 0.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                    decoration: const InputDecoration(labelText: "Start"),
                    validator: (value) {
                      if (endTime!.difference(startTime!).inMinutes < 0) {
                        return "Start timme shouldn't be greater then End Time";
                      }
                      return null;
                    },
                    controller: TextEditingController(
                        text: dateFormat.format(startTime!)),
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
                    validator: (value) {
                      if (startTime!.difference(endTime!).inMinutes > 0) {
                        return "End timme should be greater then Start Time";
                      }
                      return null;
                    },
                    controller: TextEditingController(
                        text: dateFormat.format(endTime!)),
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
                    value: category.toString().split('.').last,
                    validator: (value) {
                      if (value == Category.none.toString().split('.').last) {
                        return "Please select the category";
                      }
                      return null;
                    },
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
                              if (_formKey.currentState!.validate() &&
                                  Duration(
                                              seconds: (endTime!
                                                  .difference(startTime!)
                                                  .inSeconds))
                                          .inHours <
                                      10) {
                                if (historyId == null) {
                                  History history = History(
                                      startTime: startTime!,
                                      endTime: endTime!,
                                      duration:
                                          Date.duration(startTime!, endTime!),
                                      category:
                                          History.getHistoryEnum(category!));
                                  DBContext.instance.create(history);
                                } else {
                                  History history = await DBContext.instance
                                      .getHistoryById(historyId);
                                  history.startTime = startTime!;
                                  history.endTime = endTime!;
                                  history.duration =
                                      Date.duration(startTime!, endTime!);
                                  history.category =
                                      History.getHistoryEnum(category!);
                                  DBContext.instance.update(history);
                                }
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                    "Record Upserted!!",
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold),
                                  )),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                    "Start and End duration should be max of 10hrs",
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold),
                                  )),
                                );
                              }
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
            ),
          ),
        ));
  }
}
