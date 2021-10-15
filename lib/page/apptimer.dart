import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:myapp/model/history.dart';
import 'package:intl/intl.dart';
import 'package:myapp/db/context.dart';
import 'package:myapp/page/edit_timer_history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/utils/date.dart';
import 'package:percent_indicator/percent_indicator.dart';

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

  TextStyle titleStyle = const TextStyle(
      color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold);
  TextStyle hrsStyle = const TextStyle(
      color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.bold);

  late DateTime startTime;
  List<History> history = [];

  void runner() {
    if (running) {
      Timer(const Duration(seconds: 1), () {
        if (running) {
          setState(() {
            time = Date.duration(startTime, DateTime.now());
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
    var diffTime = Date.duration(startTime, endTime);
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

  Widget totalCard(Category category, Color percentColor) {
    Duration time = const Duration();
    if (history.isNotEmpty) {
      history.map((e) {
        if (e.category == category) {
          time +=
              Duration(seconds: (e.endTime.difference(e.startTime).inSeconds));
        }
      }).toList();
    }
    var tMin = 24 * 60;
    var percent = time.inMinutes / tMin;
    return Column(
      children: [
        CircularPercentIndicator(
          circularStrokeCap: CircularStrokeCap.round,
          backgroundColor: Colors.white,
          animation: true,
          animationDuration: 1200,
          radius: 60.0,
          lineWidth: 7.0,
          percent: percent,
          footer:
              Text(History.getCategoryDisplayName(category), style: titleStyle),
          center: Text(
              "${(time.inHours).toString().padLeft(2, '0')}:${(time.inMinutes % 60).toString().padLeft(2, '0')}",
              style: hrsStyle),
          progressColor: percentColor,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    refreshState();
    return Column(
      children: [
        Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.indigo,
                  gradient: LinearGradient(colors: [
                    Colors.pink,
                    Colors.purple,
                  ]),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(16))),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      totalCard(Category.left, Colors.purple),
                      totalCard(Category.right, Colors.green.shade500),
                      totalCard(Category.sleep, Colors.indigo.shade500)
                    ],
                  ),
                ],
              ),
            )),
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
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushNamed(context, EditTimerHistory.id,
                                arguments: history[index]);
                          },
                          child: const Text("Edit"),
                        ),
                        TextButton(
                            onPressed: () {
                              setState(() {
                                if (history[index].id != null) {
                                  DBContext.instance.delete(history[index].id!);
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
                    style: const TextStyle(
                        fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  title: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          history[index].duration,
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700),
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
          flex: 4,
          child: Card(
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.indigo,
                  gradient: LinearGradient(colors: [
                    Colors.pink,
                    Colors.purple,
                  ]),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
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
                                style: TextStyle(
                                    color: Colors.grey.shade200,
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold)),
                            Text(time,
                                style: TextStyle(
                                    color: Colors.grey.shade200,
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold)),
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
                                              : Colors.blueAccent.shade200)),
                                ),
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                            ],
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 0.0),
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
    );
  }
}
