import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:warzone_companion/main.dart';

class Screen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.history),
            onPressed: (){
              Navigator.pushNamed(context, 'cHistory');
            },
          ),
        ],
        backgroundColor: Colors.grey,
        title: Text(
          'Cloud Stats',
          style: TextStyle(
            fontFamily: 'Graduate',
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
      ),
      body: Container(
        child: StreamBuilder(
          stream: firestore.collection(collections[platform]).doc(GamerTag.replaceAll('%23', '#')).snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot){
            if (!snapshot.hasData){
              return Center(child: CircularProgressIndicator());
            }else if(snapshot.hasError){
              return Center(child: Icon(Icons.error_outline));
            }

            Map<dynamic, dynamic> map = Map.from(snapshot.data.data());
            var keys = map.keys.toList();
            return ListView.builder(
                itemCount: map.length,
                itemBuilder: (BuildContext context, int index){
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                        child: Text(
                          '${keys[index]}: ${map[keys[index]].toString()}',
                          style: TextStyle(
                            fontFamily: 'Graduate',
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),),
                      ),
                      Divider(
                        color: Colors.black,
                        thickness: 2,
                        height: 15,
                        indent: 40,
                        endIndent: 40,
                      ),
                    ],
                  );
                }
            );
          },
        ),
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/friends.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.6), BlendMode.dstATop))),
      ),
    );
  }
}
