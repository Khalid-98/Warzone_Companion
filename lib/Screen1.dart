import 'package:flutter/material.dart';
import 'package:warzone_companion/main.dart';

class Screen1 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.history),
            onPressed: (){
              Navigator.pushNamed(context, 'History');
            },
          ),
        ],
        backgroundColor: Colors.grey,
        title: Text(
          'Local Stats',
          style: TextStyle(
            fontFamily: 'Graduate',
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
      ),
      body: Container(
        child: FutureBuilder(
          future: query(gamerTag.text, tables[platform]),
          builder: (context, AsyncSnapshot<Map<dynamic,dynamic>> snapshot){
            if (!snapshot.hasData){
              return Center(child: CircularProgressIndicator());
            }else if(snapshot.hasError){
              return Center(child: Icon(Icons.error_outline));
            }

            Map<dynamic, dynamic> map = Map.from(snapshot.data);
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
              },
            );
          },
        ),
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/solo.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.6), BlendMode.dstATop))),
      ),
    );
  }
}
