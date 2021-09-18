import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:myapp/model/history.dart';
import 'package:intl/intl.dart';

class AppTimer extends StatefulWidget {
  const AppTimer({Key? key}) : super(key: key);

  @override
  _AppTimerState createState() => _AppTimerState();
}

class _AppTimerState extends State<AppTimer> {
  bool running = false;
  String time = "00:00:00";
  Stopwatch swatch = Stopwatch();
  DateFormat dateFormat = DateFormat.jms();

  Duration totalDuration = const Duration(seconds: 0);
  String totalTime = "00:00:00";

  late DateTime startTime;
  List<Histroy> history = [];

  void runner() {
    if (swatch.isRunning) {
      Timer(const Duration(seconds: 1), () {
        setState(() {
          time = swatch.elapsed.inHours.toString().padLeft(2, '0') +
              ":" +
              (swatch.elapsed.inMinutes % 60).toString().padLeft(2, '0') +
              ":" +
              (swatch.elapsed.inSeconds % 60).toString().padLeft(2, '0');
        });
        runner();
      });
    }
  }

  void start() {
    if (!swatch.isRunning) {
      swatch.start();
      setState(() {
        running = true;
      });
      runner();
      startTime = DateTime.now();
    }
  }

  void pause() {
    if (swatch.isRunning) {
      swatch.stop();
    }
    setState(() {
      running = false;
    });
  }

  void stop() {
    if (swatch.isRunning) {
      pause();
    }
    swatch.reset();
    var endTime = DateTime.now();
    var difference = endTime.difference(startTime);
    var diffTime = difference.inHours.toString().padLeft(2, '0') +
        ":" +
        (difference.inMinutes % 60).toString().padLeft(2, '0') +
        ":" +
        (difference.inSeconds % 60).toString().padLeft(2, '0');
    setState(() {
      var his = Histroy(startTime, endTime, diffTime);
      history.add(his);
      time = "00:00:00";
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

  void totalHistoryDuration() {
    var duration = const Duration(seconds: 0);
    totalTime = "00:00:00";
    for (var item in history) {
      duration += Duration(
          seconds: (item.endTime.difference(item.startTime).inSeconds));
    }
    setState(() {
      totalDuration = duration;
    });
  }

  @override
  void initState() {
    running = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 0.0),
        child: Column(
          children: [
            Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      totalDuration.inHours.toString().padLeft(2, '0') +
                          ":" +
                          (totalDuration.inMinutes % 60)
                              .toString()
                              .padLeft(2, '0') +
                          ":" +
                          (totalDuration.inSeconds % 60)
                              .toString()
                              .padLeft(2, '0'),
                      style: const TextStyle(fontSize: 30.0),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    IconButton(
                      onPressed: history.isEmpty
                          ? null
                          : () {
                              clear();
                            },
                      icon: const Icon(Icons.restore),
                      color: Colors.red.shade400,
                    ),
                  ],
                )),
            const SizedBox(
              height: 30.0,
            ),
            Expanded(
              flex: 18,
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.alarm,
                        size: 40.0,
                      ),
                      title: Center(
                        child: Text(
                          history[index].duration,
                          style: const TextStyle(fontSize: 25.0),
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
                        const SizedBox(
                          width: 30.0,
                        ),
                        Expanded(
                            flex: 4,
                            child: Text(time,
                                style: const TextStyle(fontSize: 30.0))),
                        Expanded(
                          flex: 2,
                          child: TextButton(
                            onPressed: !running
                                ? () {
                                    start();
                                  }
                                : null,
                            child: const Text("Start",
                                style: TextStyle(
                                  color: Colors.white,
                                )),
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    !running
                                        ? Colors.green.shade400
                                        : Colors.green.shade200)),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          flex: 2,
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
                        SizedBox(
                          width: 20.0,
                        )
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
