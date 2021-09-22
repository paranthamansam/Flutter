import 'package:flutter/material.dart';
import 'package:myapp/db/context.dart';
import 'package:myapp/model/user.dart';

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
          primarySwatch: Colors.amber,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text("Flutter"),
            centerTitle: true,
          ),
          body: const Center(
            child: UserList(),
          ),
        ));
  }
}

class UserList extends StatefulWidget {
  const UserList({Key? key}) : super(key: key);

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  @override
  void dispose() {
    DBContext.instance.close();
    super.dispose();
  }

  void loadTemp() async {
    var users = const [
      User(id: 1, name: "paranthaman", level: 2),
      User(id: 2, name: "paranthaman", level: 3),
      User(id: 3, name: "paranthaman", level: 1),
      User(id: 4, name: "paranthaman", level: 5),
    ];
    List<User> allUser = [];
    for (var element in users) {
      var user = await DBContext.instance.create(element);
      allUser.add(user);
    }
    for (var item in allUser) {
      print("User Id : ${item.id}");
    }
  }

  void readUsers() async {
    var users = await DBContext.instance.getall();
    for (var item in users) {
      print(item.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: [
          TextButton(
            onPressed: () {
              loadTemp();
            },
            child: const Text("Load Default data"),
          ),
          TextButton(
            onPressed: () {
              readUsers();
            },
            child: const Text("Read all users"),
          ),
        ],
      ),
    );
  }
}
