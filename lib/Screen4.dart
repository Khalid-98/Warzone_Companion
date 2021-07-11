import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:warzone_companion/main.dart';

class Screen4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HistoryPageC(),
    );
  }
}

class HistoryPageC extends StatefulWidget {
  @override
  _HistoryPageCState createState() => _HistoryPageCState();
}

class _HistoryPageCState extends State<HistoryPageC> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Cloud History',
            style: TextStyle(
              fontFamily: 'Graduate',
              fontWeight: FontWeight.bold,
            ),),
          backgroundColor: Colors.grey,
        ),
       body: ListView.separated(
         itemCount: collections.length,
         itemBuilder: (BuildContext context, int index){
           return StreamBuilder(
             stream: firestore.collection(collections[index]).snapshots(),
             builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
               if (!snapshot.hasData){
                 return Center(child: CircularProgressIndicator());
               }else if(snapshot.hasError){
                 return Center(child: Icon(Icons.error_outline));
               }

               List<ListTile> statsWidgets = [];
               var stats = snapshot.data.docs;
               for (var stat in stats){
                 Map<dynamic, dynamic> map = stat.data();
                 var keys = map.keys.toList();
                 var values = map.values.toList();

                 var statsWidget =
                 ListTile(
                   leading: IconButton(
                     icon: Icon(Icons.update),
                     onPressed: (){
                       setState(() {
                         firestore.collection(collections[index]).doc(stat.id).update({
                           'platform': 'UPDATED',
                         });
                       });
                     },
                   ),
                   trailing: IconButton(
                       icon: Icon(Icons.delete),
                       onPressed: () {
                         setState(() {
                           firestore.collection(collections[index]).doc(stat.id).delete();
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
                 statsWidgets.add(statsWidget);
               }
               return ListView(
                 shrinkWrap: true,
                 children: statsWidgets,
               );
             },
           );
         },
         separatorBuilder: (BuildContext context, int index) => const Divider(),
       ),
    );
  }
}



