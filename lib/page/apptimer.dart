import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:myapp/model/history.dart';
import 'package:intl/intl.dart';
import 'package:myapp/db/context.dart';
import 'package:myapp/page/edit_timer_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTimer extends StatefulWidget {
  final DateTime picked;
  const AppTimer({Key? key, required this.picked}) : super(key: key);

  @override
  _AppTimerState createState() => _AppTimerState();
}

class _AppTimerState extends State<AppTimer> {
  bool running = false;
  Category category = Category.none;
  String time = "00:00:00";
  Stopwatch swatch = Stopwatch();

  DateFormat dateFormat = DateFormat.yMd().add_jm();

  Duration totalDuration = const Duration(seconds: 0);
  String totalTime = "00:00:00";

  late DateTime startTime;
  List<History> history = [];

  void runner() {
    if (running) {
      Timer(const Duration(seconds: 1), () {
        if (running) {
          setState(() {
            time = duration(DateTime.now());
          });
          runner();
        }
      });
    }
  }

  Future<void> start(Category cat) async {
    setState(() {
      category = cat;
      running = true;
    });
    runner();
    startTime = DateTime.now();

    setPreference(running, startTime, category);
  }

  void pause() {
    if (running) {
      setState(() {
        running = false;
        resetPreference();
      });
    }
  }

  void stop() {
    pause();
    var endTime = DateTime.now();
    var diffTime = duration(endTime);
    setState(() {
      var his = History(
          startTime: startTime,
          endTime: endTime,
          duration: diffTime,
          category: category);
      DBContext.instance.create(his);
      refreshState();
      time = "00:00:00";
      category = Category.none;
    });
    totalHistoryDuration();
  }

  String duration(DateTime endTime) {
    var difference = endTime.difference(startTime);
    return difference.inHours.toString().padLeft(2, '0') +
        ":" +
        (difference.inMinutes % 60).toString().padLeft(2, '0') +
        ":" +
        (difference.inSeconds % 60).toString().padLeft(2, '0');
  }

  void clear() {
    pause();
    time = "00:00:00";
    totalTime = "00:00:00";
    if (history.isNotEmpty) {
      history.clear();
      totalHistoryDuration();
    }
  }

  Future<void> setPreference(bool running, DateTime start, Category cat) async {
    var sharedPreff = await SharedPreferences.getInstance();
    sharedPreff.setBool("running", running);
    sharedPreff.setString("category", History.getCategoryDisplayName(category));
    sharedPreff.setString("startTime", startTime.toIso8601String());
  }

  Future<void> readPreference() async {
    var sharedPreff = await getSharedPrefereceInstance();

    running = sharedPreff.getBool("running") ?? false;
    category =
        History.getHistoryEnum(sharedPreff.getString("category") ?? "none");
    if (sharedPreff.getString("startTime") != null) {
      startTime = DateTime.parse(sharedPreff.getString("startTime")!);
    }
    if (running) {
      runner();
    }
  }

  Future<void> resetPreference() async {
    var sharedPreff = await getSharedPrefereceInstance();
    sharedPreff.clear();
  }

  void totalHistoryDuration() {
    var duration = const Duration(milliseconds: 0);
    totalTime = "00:00:00";
    for (var item in history) {
      duration += Duration(
          milliseconds:
              (item.endTime.difference(item.startTime).inMilliseconds));
    }
    setState(() {
      totalDuration = duration;
    });
  }

  void refreshState() async {
    // TOODO: get all history
    var allHistory = await DBContext.instance.getHistoryByDate(widget.picked);
    setState(() {
      if (allHistory.isNotEmpty) {
        // check setstate is required since it is InitState
        history = allHistory;
      } else {
        history = [];
      }
    });
  }

  static Future<SharedPreferences> getSharedPrefereceInstance() async {
    return await SharedPreferences.getInstance();
  }

  @override
  initState() {
    readPreference();
    super.initState();
  }

  @override
  void dispose() {
    DBContext.instance.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    refreshState();
    return Padding(
        padding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 0.0),
        child: Column(
          children: [
            // Expanded(
            //     flex: 2,
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Text(
            //           totalDuration.inHours.toString().padLeft(2, '0') +
            //               ":" +
            //               (totalDuration.inMinutes % 60)
            //                   .toString()
            //                   .padLeft(2, '0') +
            //               ":" +
            //               (totalDuration.inSeconds % 60)
            //                   .toString()
            //                   .padLeft(2, '0'),
            //           style: const TextStyle(fontSize: 30.0),
            //         ),
            //         const SizedBox(
            //           width: 10.0,
            //         ),
            //         IconButton(
            //           onPressed: history.isEmpty
            //               ? null
            //               : () {
            //                   clear();
            //                 },
            //           icon: const Icon(Icons.restore),
            //           color: Colors.red.shade400,
            //         ),
            //       ],
            //     )),
            // const SizedBox(
            //   height: 30.0,
            // ),
            Expanded(
              flex: 18,
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      onLongPress: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Action"),
                          content: const Text("Select the action"),
                          actions: [
                            TextButton(
                              onPressed: () => {
                                Navigator.pushNamed(
                                    context, EditTimerHistory.id,
                                    arguments: history[index])
                              },
                              child: const Text("Edit"),
                            ),
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    if (history[index].id != null) {
                                      DBContext.instance
                                          .delete(history[index].id!);
                                      refreshState();
                                    }
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Delete")),
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Close"))
                          ],
                        ),
                      ),
                      leading: Text(
                        History.getCategoryDisplayName(history[index].category),
                        style: const TextStyle(fontSize: 25.0),
                      ),
                      title: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              history[index].duration,
                              style: const TextStyle(fontSize: 25.0),
                            ),
                          ],
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dateFormat.format(history[index].startTime),
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              dateFormat.format(history[index].endTime),
                              style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Expanded(
              flex: 3,
              child: Card(
                child: Container(
                  color: Colors.grey.shade300,
                  child: Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            flex: 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(History.getCategoryDisplayName(category),
                                    style: const TextStyle(fontSize: 30.0)),
                                Text(time,
                                    style: const TextStyle(fontSize: 30.0)),
                              ],
                            )),
                        Expanded(
                          flex: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextButton(
                                      onPressed: !running
                                          ? () {
                                              start(Category.left);
                                            }
                                          : null,
                                      child: const Text("L",
                                          style: TextStyle(
                                            color: Colors.white,
                                          )),
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(!running
                                                  ? Colors.green.shade400
                                                  : Colors.green.shade200)),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: TextButton(
                                      onPressed: !running
                                          ? () {
                                              start(Category.right);
                                            }
                                          : null,
                                      child: const Text("R",
                                          style: TextStyle(
                                            color: Colors.white,
                                          )),
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(!running
                                                  ? Colors.green.shade400
                                                  : Colors.green.shade200)),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: TextButton(
                                      onPressed: !running
                                          ? () {
                                              start(Category.sleep);
                                            }
                                          : null,
                                      child: const Text("Zzz",
                                          style: TextStyle(
                                            color: Colors.white,
                                          )),
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(!running
                                                  ? Colors.blueAccent.shade400
                                                  : Colors
                                                      .blueAccent.shade200)),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    4.0, 8.0, 4.0, 0.0),
                                child: TextButton(
                                  onPressed: running
                                      ? () {
                                          stop();
                                        }
                                      : null,
                                  child: const Text("Stop",
                                      style: TextStyle(color: Colors.white)),
                                  style: ButtonStyle(
                                      backgroundColor: running
                                          ? MaterialStateProperty.all(
                                              Colors.red.shade400)
                                          : MaterialStateProperty.all(
                                              Colors.red.shade200)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
