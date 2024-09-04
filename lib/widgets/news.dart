import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';

class News extends StatefulWidget {
  const News({Key? key}) : super(key: key);

  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> {
  String news='';
  String points='';
  _buildNews() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 300,
        width: 500,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  style: TextStyle(color: secondColor),
                  cursorColor: secondColor,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      borderSide:
                          BorderSide(width: 1, color: secondColor),
                    ),
                    border: OutlineInputBorder(
                      borderSide:
                           BorderSide(color: secondColor),
                    ),
                    labelStyle:
                        TextStyle(fontSize: 16, color: secondColor),
                    hintStyle:
                        TextStyle(fontSize: 16, color: secondColor),
                    labelText: 'الخبر',
                    hintText: 'الخبر',
                  ),
                  onChanged: (text) {
                    news = text;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  cursorColor: secondColor,
                  style: TextStyle(color: secondColor),

                  decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(4)),
                        borderSide: BorderSide(
                            width: 1, color: secondColor),
                      ),
                      border: OutlineInputBorder(
                        borderSide:
                             BorderSide(color: secondColor),
                      ),
                      labelStyle: TextStyle(
                          fontSize: 16, color: secondColor),
                      hintStyle: TextStyle(
                          fontSize: 16, color: secondColor),
                      labelText: 'النقاط',
                      hintText: 'النقاط'),
                  onChanged: (text) {
                    points = text;
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all(secondColor),
                ),
                child: const Text(
                  'اضافة',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: (){FirebaseFirestore.instance.collection("news").add(
                    {'news':news,'points':points});},

              )
            ],
          ),
        ),
      ),
    );
  }
  Future<void> getSavedNotificationCount(int news) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('notificationCount', news);

  }
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:  primaryColor,
        appBar: AppBar(
elevation: 2,
          leading:
          kIsWeb?IconButton(icon: Icon(Icons.edit, color: secondColor,),
            onPressed: ()   {

            showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  backgroundColor: primaryColor,
                  content: Stack(
                    children: [
                      _buildNews(),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: IconButton(
                          icon: Icon(Icons.close, color: secondColor),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  )

              );
            },
          );}
          ):
          IconButton(onPressed: ()=>Navigator.of(context).pop(), icon: Icon(Icons.arrow_back,color: secondColor,)),
          backgroundColor:  primaryColor,
          centerTitle: true,
          title:  Text(
            'اخر الاخبار',
            style: TextStyle(
              fontSize: 20,
              fontFamily: '18 Khebrat',
              color: secondColor,
            ),
          ),
        ),
        body: Stack(
          children: [
          Align(
          alignment: Alignment.center,
          child: Opacity(
            opacity: 0.2, // Change this value to adjust the opacity
            child: Image.asset('assets/game.png', fit: BoxFit.cover),
          ),
        ),
             StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("news").snapshots(),
                  builder:
                      (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                            child:
                                CircularProgressIndicator(color: secondColor)),
                      );
                    }else {
                      getSavedNotificationCount(snapshot.data!.docs.length);
                      return new ListView(children: getExpenseItems(snapshot));
                    }
                  }),
        
          ],
        ),
      ),
    );
  }
}

getExpenseItems(AsyncSnapshot<QuerySnapshot> snapshot) {
  return snapshot.data?.docs
      .map((doc) => Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Card(
              color:  secondColor,
              elevation: 1,
              child: new ListTile(
               leading:kIsWeb? IconButton(onPressed: (){doc.reference.delete();}, icon: Icon(Icons.delete,color: Colors.red,),):null,
                  title: new Text(
                    doc["news"],
                    style: TextStyle(color: primaryColor),
                  ),
                  trailing: new Text(
                    doc["points"],
                    style: TextStyle(color: primaryColor),
                  )),
            ),
          )))
      .toList();
}
