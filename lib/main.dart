import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:http/http.dart' as HQ;
import 'package:warzone_companion/Screen3.dart';
import 'package:warzone_companion/database_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:warzone_companion/device_info.dart';
import 'package:workmanager/workmanager.dart';
import 'Screen1.dart';
import 'Screen2.dart';
import 'Screen3.dart';
import 'Screen4.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  var turkey = tz.getLocation('Europe/Istanbul');
  tz.setLocalLocation(turkey);
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// ignore: non_constant_identifier_names
int Time;
String unit;

showNotification() async {
  print('showing notification');
  var android = new AndroidNotificationDetails(
    'id',
    'channel ',
    'description',
    priority: Priority.high,
    importance: Importance.max,
    playSound: true,


  );
  var iOS = new IOSNotificationDetails();
  var platform = new NotificationDetails(
    android: android,
    iOS: iOS,
    macOS: null,
  );
  await flutterLocalNotificationsPlugin.show(
    0,
    'Warzone Companion',
    'Database Updated',
    platform,
  );
}

List<NotificationActionButton> actionButtons = [
  NotificationActionButton(
    key: 'action1',
    label: 'Action1',

  ),
  NotificationActionButton(
    key: 'action2',
    label: 'Action2',
  ),
];

showANotification(){
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 10,
          channelKey: 'channel',
          title: 'Warzone Companion',
          body: 'Database Updated',

      ),
    actionButtons: actionButtons,
  );

}

Future<void> scheduleNotification() async {
  var scheduledNotificationDateTime;

  if(unit == 'Seconds'){
    scheduledNotificationDateTime =
        tz.TZDateTime.now(tz.local).add(Duration(seconds: Time));
    DateTime.now().add(Duration(seconds: Time));
  }else if(unit == 'Minutes'){
    scheduledNotificationDateTime =
        tz.TZDateTime.now(tz.local).add(Duration(minutes: Time));
    DateTime.now().add(Duration(minutes: Time));
  }else if(unit == 'Hours'){
    scheduledNotificationDateTime =
        tz.TZDateTime.now(tz.local).add(Duration(hours: Time));
    DateTime.now().add(Duration(hours: Time));
  }

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'channel id',
    'channel name',
    'channel description',
    priority: Priority.high,
    importance: Importance.max,
    playSound: true,
  );
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
    macOS: null,
  );
  await flutterLocalNotificationsPlugin.zonedSchedule(
    1,
    'Warzone Companion',
    'Scheduled Notification',
    scheduledNotificationDateTime,
    platformChannelSpecifics,
    uiLocalNotificationDateInterpretation: null,
    androidAllowWhileIdle: false,
  );
}

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    switch (task) {
      case simpleTaskKey:
        await update_database();
        break;
      case simplePeriodicTask:
        await update_database();
        break;
    }
    return true;
  });
}

var stats;
final firestore = FirebaseFirestore.instance;
final handler = Handler.instance;
// ignore: non_constant_identifier_names
String GamerTag;
int platform;
var gamerTag = TextEditingController();
final List<String> platforms = ['battle', 'psn', 'xbl'];
final List<String> collections = ['battle_stats', 'psn_stats', 'xbox_stats'];
final List<String> tables = [Handler.table1, Handler.table2, Handler.table3];
const simplePeriodicTask = "simplePeriodicTask";
const simpleTaskKey = "simpleTask";
// ignore: non_constant_identifier_names
Map<String, dynamic> cloud_data() => {
  'tag' : GamerTag,
  'platform' : platforms[platform],
  'contracts' : 10,
  'cash' : 561612,
  'top 10' : 3,
  'top 5' : 1,
};

Map<String, String> authorization() => {
      'x-rapidapi-key': '53a6b8a6demsh690a6ea33cec3bdp1df24djsn5bbabe911ff0',
      'x-rapidapi-host': 'call-of-duty-modern-warfare.p.rapidapi.com',
    };

Future getStats(String gamerTag, String platform) async {
  HQ.Response response = await HQ.get(
      'https://call-of-duty-modern-warfare.p.rapidapi.com/warzone/$gamerTag/$platform',
      headers: authorization());
  print(response.statusCode);
  stats = response.body;
  return stats;
}

// ignore: non_constant_identifier_names
void start() async{
  GamerTag = gamerTag.text;
  //await getStats(GamerTag, platforms[platform]);
  insert();
  insert_cloud();
}
// ignore: non_constant_identifier_names
void insert_cloud() {
  firestore.collection(collections[platform]).doc(GamerTag.replaceAll('%23', '#')).set(cloud_data());
}

void insert() async{
  Map<String, dynamic> row = {
    Handler.columnTag : GamerTag,
    Handler.columnPlatform : platforms[platform],
    Handler.columnWins : 62,
    Handler.columnKills : 556,
    Handler.columnDeaths : 357,
    Handler.columnDowns : 338
  };
    await handler.insert(row, tables[platform]);
    print('inserted user: ${row[Handler.columnTag]}');
}

Future<Map> query(String tag, String table) async{
  final row = await handler.query(tag, table);
  if (row.isEmpty){
    print('user not found');
  }
  //print(row.asMap()[0]);
  return row.asMap()[0];
}

Future<List<Map>> queryTable(String table) async{
  //print('Viewing $table');
  final allRows = await handler.queryAll(table);
  if (allRows.isEmpty){
    print('Table is empty');
  }
  //allRows.forEach((row) => print(row));
    return allRows;
}

void update(String table, String tag) async {
  Map<String, dynamic> row = {
    Handler.columnTag : tag,
    Handler.columnPlatform: 'Updated',
  };
  final result = await handler.update(row, table);
  if (result == 0){
    print('user not found');
  }else {
    print('updated user ${row[Handler.columnTag]}');
  }
}

void deleteUser(String tag, String table) async {
  final result = await handler.delete(tag, table);
  if (result == 0){
    print('user not found');
  }else {
    print('deleted user $tag');
  }
}

void deleteTable(String table) async {
   await handler.deleteAll(table);
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _configureLocalTimeZone();
  var initializationSettingsAndroid =
  AndroidInitializationSettings('mipmap/ic_launcher');
  var initializationSettingsIOs = IOSInitializationSettings();
  var initSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOs,
    macOS: null,
  );

  flutterLocalNotificationsPlugin.initialize(
    initSettings,
  );
  Workmanager.initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  AwesomeNotifications().initialize(
      null, [
        NotificationChannel(
            channelKey: 'channel',
            channelName: 'notifications',
            channelDescription: 'Notification channel for Warzone Communications',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white,
          importance: NotificationImportance.Max,

        ),
      ],
  );
  runApp(Warzone());
}

class Warzone extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'Home',
      routes: {
        'Home': (context) => Screen0(),
        'Stats': (context) => Screen1(),
        'cStats': (context) => Screen2(),
        'History': (context) => Screen3(),
        'cHistory': (context) => Screen4(),
        'device info': (context) => INFO(),
      },
    );
  }
}

class Screen0 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WelcomePage(),
    );
  }
}

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  bool showScheduler;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    showScheduler = false;
  }

  void show(){
    setState(() {
      showScheduler = !showScheduler;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          children: <Widget>[
            Container(
              width: double.infinity,
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 175, 0, 25),
              child: Center(
                child: Text(
                  'Enter Your Gamertag, Soldier!',
                  style: TextStyle(
                    fontFamily: 'Graduate',
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 45.0),
              color: Colors.white,
              child: Center(
                child: TextField(
                  controller: gamerTag,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Gamertag'),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(15),
              child: Center(
                child: Text(
                  'Choose Your Platform',
                  style: TextStyle(
                    fontFamily: 'Graduate',
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  MaterialButton(
                    onPressed: () {
                      final snackBar = SnackBar(
                        content: Text('Battle.net'),
                      );
                      setState(() {
                        platform = 0;
                      });
                      start();
                      //Scaffold.of(context).showSnackBar(snackBar);
                    },
                    shape: CircleBorder(),
                    child: CircleAvatar(
                      radius: 30.0,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage('images/battle.png'),
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      final snackBar = SnackBar(
                        content: Text('PlayStationNetwork'),
                      );
                      setState(() {
                        platform = 1;
                      });
                      start();
                      //Scaffold.of(context).showSnackBar(snackBar);
                    },
                    color: Colors.white,
                    textColor: Colors.white,
                    shape: CircleBorder(),
                    child: CircleAvatar(
                      radius: 30.0,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage('images/ps.png'),
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      final snackBar = SnackBar(
                        content: Text('XboxLive'),
                      );
                      setState(() {
                        platform = 2;
                      });
                      start();
                      //Scaffold.of(context).showSnackBar(snackBar);
                    },
                    color: Colors.white,
                    textColor: Colors.white,
                    shape: CircleBorder(),
                    child: CircleAvatar(
                      radius: 30.0,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage('images/xbox.png'),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 110),
              child: MaterialButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'Stats');
                },
                color: Colors.grey,
                textColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  'Show Local Stats',
                  style: TextStyle(
                    fontFamily: 'Graduate',
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 110),
              child: MaterialButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'cStats');
                },
                color: Colors.grey,
                textColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  'Show Cloud Stats',
                  style: TextStyle(
                    fontFamily: 'Graduate',
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/background.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.6), BlendMode.dstATop))),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey,
        child: Icon(Icons.settings, color: Colors.black,),
        tooltip: 'Settings',
        onPressed: (){
          _scaffoldKey.currentState.openDrawer();
        },
      ),
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 120,
              child: DrawerHeader(
                padding: EdgeInsets.fromLTRB(15, 30, 50, 20),
                child: Text('Settings',
                  style: TextStyle(
                  fontFamily: 'Graduate',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                ),),
                decoration: BoxDecoration(
                  color: Colors.grey,
                ),
              ),
            ),
            ListTile(
              title: Text('Update Database',
                style: TextStyle(
                  fontFamily: 'Graduate',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                )),
              onTap: () {
                Workmanager.registerOneOffTask(
                  "1",
                  simpleTaskKey,
                );
              },
            ),
            ListTile(
              title: Text('Schedule Database Update',
                  style: TextStyle(
                    fontFamily: 'Graduate',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  )),
              onTap: () {
                Workmanager.registerPeriodicTask(
                  "2",
                  simplePeriodicTask,
                  frequency: Duration(minutes: 15),
                  initialDelay: Duration(seconds: 5),
                );
                print('Database Update scheduled for 15 minutes');
              },
            ),
            ListTile(
              title: Text('Cancel Database Update',
                  style: TextStyle(
                    fontFamily: 'Graduate',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  )),
              onTap: () {
                Workmanager.cancelAll();
                print('Cancelled Database Update');
              },
            ),
            ListTile(
              title: Text('Schedule Notification',
                  style: TextStyle(
                    fontFamily: 'Graduate',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  )),
              onTap: () {
                show();
              },
            ),
            Visibility(
              visible: showScheduler,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      DropdownButton<menu1>(
                        hint: Text('Select Unit',
                            style: TextStyle(
                              fontFamily: 'Graduate',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            )),
                        value: choice1,
                        onChanged: (menu1 value){
                          setState(() {
                            choice1 = value;
                            unit = value.time;
                          });
                        },
                        items: time1.map((menu1 time){
                          return DropdownMenuItem<menu1>(
                            value: time,
                            child: Text(time.time),
                          );
                        },
                        ).toList(),
                      ),
                      SizedBox(
                        width: 30,
                      ),
                      DropdownButton<menu2>(
                        hint: Text('Select Time',
                            style: TextStyle(
                              fontFamily: 'Graduate',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            )),
                        value: choice2,
                        onChanged: (menu2 value){
                          setState(() {
                            choice2 = value;
                            Time = value.time;
                          });
                        },
                        items: time2.map((menu2 time){
                          return DropdownMenuItem<menu2>(
                            value: time,
                            child: Text(time.time.toString()),
                          );
                        },
                        ).toList(),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                    alignment: Alignment.centerLeft,
                    child: RaisedButton(
                      onPressed: scheduleNotification,
                      child: new Text(
                        'schedule notification',
                          style: TextStyle(
                            fontFamily: 'Graduate',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          )),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Device Information',
                  style: TextStyle(
                    fontFamily: 'Graduate',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  )),
              onTap: () {
                Navigator.pushNamed(context, 'device info');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: non_constant_identifier_names
void update_DB(Map<String, dynamic> row) async{
  await handler.insert(row, Handler.table1);
  print('inserted user: ${row[Handler.columnTag]}');
}
// ignore: non_constant_identifier_names
Future<void> update_database() async{
  print('working...');
  update_list.forEach((element) => update_DB(element));
  showANotification();
}

// ignore: non_constant_identifier_names
List<Map<String, dynamic>> update_list = [GhostLead, Chob, ImpaaG,
  Hotmamasauce, jochaa1, Gu11y_b0y99];

// ignore: non_constant_identifier_names
Map<String, dynamic> GhostLead = {
  Handler.columnTag : 'GhostLead#21443',
  Handler.columnPlatform : 'battle',
  Handler.columnWins : 62,
  Handler.columnKills : 556,
  Handler.columnDeaths : 357,
  Handler.columnDowns : 338
};

// ignore: non_constant_identifier_names
Map<String, dynamic> Chob = {
  Handler.columnTag : 'Chob#21309',
  Handler.columnPlatform : 'battle',
  Handler.columnWins : 262,
  Handler.columnKills : 1556,
  Handler.columnDeaths : 657,
  Handler.columnDowns : 338
};

// ignore: non_constant_identifier_names
Map<String, dynamic> ImpaaG = {
  Handler.columnTag : 'ImpaaG',
  Handler.columnPlatform : 'xbl',
  Handler.columnWins : 162,
  Handler.columnKills : 856,
  Handler.columnDeaths : 407,
  Handler.columnDowns : 468
};

// ignore: non_constant_identifier_names
Map<String, dynamic> Hotmamasauce = {
  Handler.columnTag : 'Hotmamasauce',
  Handler.columnPlatform : 'xbl',
  Handler.columnWins : 262,
  Handler.columnKills : 1556,
  Handler.columnDeaths : 657,
  Handler.columnDowns : 338
};

Map<String, dynamic> jochaa1 = {
  Handler.columnTag : 'jochaa1',
  Handler.columnPlatform : 'psn',
  Handler.columnWins : 88,
  Handler.columnKills : 666,
  Handler.columnDeaths : 287,
  Handler.columnDowns : 338
};

// ignore: non_constant_identifier_names
Map<String, dynamic> Gu11y_b0y99 = {
  Handler.columnTag : 'Gu11y_b0y99',
  Handler.columnPlatform : 'psn',
  Handler.columnWins : 90,
  Handler.columnKills : 404,
  Handler.columnDeaths : 287,
  Handler.columnDowns : 200
};

// ignore: camel_case_types
class menu1{
  const menu1(this.time);
  final String time;
}
// ignore: camel_case_types
class menu2{
  const menu2(this.time);
  final int time;
}

menu1 choice1;
menu2 choice2;

List<menu1> time1 = <menu1>[const menu1('Seconds'),const menu1('Minutes'),const menu1('Hours')];
List<menu2> time2 = <menu2>[const menu2(5),const menu2(10),const menu2(15),const menu2(20)];

