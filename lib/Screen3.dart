import 'package:flutter/material.dart';
import 'package:warzone_companion/main.dart';
import 'package:warzone_companion/database_handler.dart';

class Screen3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HistoryPage(),
    );
  }
}

class HistoryPage extends StatefulWidget {

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

final List<String> tables = [Handler.table1, Handler.table2, Handler.table3];

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: Text('Local History',
        style: TextStyle(
          fontFamily: 'Graduate',
          fontWeight: FontWeight.bold,
        ),),
        backgroundColor: Colors.grey,
      ),
       body: ListView.separated(
         itemCount: tables.length,
         itemBuilder: (BuildContext context, int index1){
           return FutureBuilder(
             future: queryTable(tables[index1]),
             builder: (context, AsyncSnapshot<List<Map>> snapshot){
               if (!snapshot.hasData){
                 return Center(child: CircularProgressIndicator());
               }else if(snapshot.hasError){
                 return Center(child: Icon(Icons.error_outline));
               }

               return ListView.builder(
                 shrinkWrap: true,
                 itemCount: snapshot.data.length,
                 itemBuilder: (BuildContext context, int index2){
                   Map<dynamic, dynamic> map = Map.from(snapshot.data.asMap()[index2]);
                   var keys = map.keys.toList();
                   var values = map.values.toList();
                   return new ListTile(
                     leading: IconButton(
                       icon: Icon(Icons.update),
                       onPressed: (){
                         setState(() {
                           update(tables[index1], values[0]);
                         });
                       },
                     ),
                     trailing: IconButton(
                       icon: Icon(Icons.delete),
                       onPressed: () {
                         setState(() {
                           deleteUser(values[0], tables[index1]);
                         });
                       }
                     ),
                     title: Text('${keys[0]}: ${values[0]} || ${keys[1]}: ${values[1].toString()}',
                       style: TextStyle(
                         fontFamily: 'Graduate',
                         fontWeight: FontWeight.bold,
                       ),),
                     subtitle: Text('${keys[2]}: ${values[2].toString()} || '
                         '${keys[3]}: ${values[3].toString()} || ${keys[4]}: ${values[4].toString()} || '
                         '${keys[5]}: ${values[5].toString()}',
                       style: TextStyle(
                         fontFamily: 'Graduate',
                       ),),
                   );
                 },
               );
             },
           );
         },
         separatorBuilder: (BuildContext context, int index) => const Divider(),
       ),
    );
  }
}

