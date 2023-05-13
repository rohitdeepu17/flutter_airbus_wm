import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:airbus/components/ItemCount.dart';
import 'package:airbus/components/file_upload_button.dart';
import 'package:airbus/components/horizontal_bar_chart.dart';
import 'package:airbus/components/simple_bar_chart.dart';
import 'package:airbus/utils/user_roles.dart';
import 'package:flutter/material.dart';

import 'package:charts_flutter/flutter.dart' as charts;

import 'package:airbus/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class DashboardScreen extends StatefulWidget {
  static String id = 'chat_screen';

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _auth = FirebaseAuth.instance;

  late User loggedInUser;

  String messageText = '';
  final messageTextController = TextEditingController();

  final _firebaseStorage = FirebaseFirestore.instance;
  String currentUser = 'vaibhavshaw028@gmail.com';

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
        if(loggedInUser!= null && loggedInUser.email!= null && loggedInUser.email!.isNotEmpty){
          //currentUser = loggedInUser.email!;
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  /*void getMessages() async{
    print('called getMessages');
    final messages = await _firebaseStorage.collection('messages').get();
    for(var message in messages.docs){
      print(message.get('text'));
      print(message.get('sender'));
    }
  }*/

  void messagesStream() async {
    await for (var snapshot
        in _firebaseStorage.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.get('text'));
        print(message.get('sender'));
      }
    }
  }

  List _items = [];

  Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/sample_data.json');
    final data = await json.decode(response);
    setState(() {
      var stage_array = data["fabrication"];
      //var stage_array = data["sub-assembly"];
      //var stage_array = data["assembly"];
      _items.clear();
      for (var item in stage_array) {
        print(item);
        _items.add(item);
      }
    });
  }

  void insertDataIntoFirebaseFabrication() {
    for (var item in _items) {
      _firebaseStorage.collection('fabrication').add({
        'item': item['item'],
        'item_id': item['item id'],
        'raw_material': item['raw material'],
        'quantity': item['Quantity'],
        'in_date': item['in date'],
        'out_date': item['out date']
      });
    }
  }

  void insertDataIntoFirebaseSubAssembly() {
    for (var item in _items) {
      _firebaseStorage.collection('sub_assembly').add({
        'assembly_id': item['Assembly ID'],
        'item_id': item['Item ID'],
        'process': item['process'],
        'machine_id': item['Machine ID'],
        'start_date': item['start date'],
        'end_date': item['end date'],
        'is_redundant': false
      });
    }
  }

  void insertDataIntoFirebaseAssembly() {
    for (var item in _items) {
      _firebaseStorage.collection('assembly').add({
        'process_id': item['Process ID'],
        'process': item['process'],
        'machine_id': item['Machine ID'],
        'start_date': item['Start Date'],
        'end_date': item['END DATE'],
        'is_redundant': false
      });
    }
  }

  HashMap<String, int> itemsCount = new HashMap();

  /// Create one series with sample hard coded data.
  static List<charts.Series<ItemCount, String>> _createData(List<ItemCount> data) {

    return [
      new charts.Series<ItemCount, String>(
        id: 'Count',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        fillColorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        insideLabelStyleAccessorFn: (_, __) => charts.TextStyleSpec(color: charts.Color(r:255,g:255,b:255)),
        outsideLabelStyleAccessorFn: (_, __) => charts.TextStyleSpec(color: charts.Color(r:255,g:255,b:255)),
        domainFn: (ItemCount sales, _) => sales.item,
        measureFn: (ItemCount sales, _) => sales.count,
        data: data,
      )
    ];
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<ItemCount, String>> _createDataHorizontal(List<ItemCount> data) {

    return [
      new charts.Series<ItemCount, String>(
          id: 'Count',
          domainFn: (ItemCount sales, _) => sales.item,
          measureFn: (ItemCount sales, _) => sales.count,
          data: data,
          // Set a label accessor to control the text of the bar label.
          labelAccessorFn: (ItemCount sales, _) =>
          '${sales.item}')
    ];
  }

  @override
  Widget build(BuildContext context) {
    var decodedData = jsonDecode('{"a":1, "b":2}');
    print(decodedData['a']);
    print(decodedData['b']);

    final String? user_email = ModalRoute.of(context as BuildContext)?.settings.arguments.toString();
    print('user email from arguments : $user_email');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                //readJson();
                //getMessages();
                //messagesStream();
                //Implement logout functionality
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡ Dashboard'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
                stream: _firebaseStorage
                    .collection(getCollectionBasedOnRole(
                        getCurrentUserRole(user_email)))
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    print('snapshot has data');
                    final messages = snapshot.data?.docs.reversed;
                    itemsCount.clear();
                    String collectionName = getCollectionBasedOnRole(
                        getCurrentUserRole(user_email));
                    print('reached here. checking all data in collection. chekcing length');
                    print(messages!.length);

                    for (var message in messages!) {
                      print(message.toString());
                      print(message.data().toString());
                      String messageText = "";
                      if (collectionName == 'fabrication') {
                        if(message.get('item')!=null)
                          messageText = message.get('item');
                      } else if (collectionName == 'sub_assembly') {
                        if(message.get('process')!=null)
                          messageText = message.get('process');
                      } else {
                        if(message.get('process')!=null)
                          messageText = message.get('process');
                      }
                      if(messageText == null)
                        print('message text is null');
                      else
                        print(messageText);
                      if (!itemsCount.containsKey(messageText))
                        itemsCount[messageText] = 1;
                      else
                        itemsCount[messageText] = itemsCount[messageText]! + 1;
                    }
                  }
                  print('itemsCount : ${itemsCount.toString()}');
                  List<ItemCount> chartData = [];
                  for(var key in itemsCount.keys){
                    if(key!=null && key.isNotEmpty)
                      chartData.add(ItemCount(key, itemsCount[key]!));
                  }
                  //return Expanded(child: SimpleBarChart(_createData(chartData), animate: false));
                  return Expanded(child: HorizontalBarLabelChart(_createDataHorizontal(chartData), animate: false,));
                  //return Expanded(child: SimpleBarChart.withSampleData());
                }),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FileUploadButton(),
                  ElevatedButton(
                    onPressed: () {
                      messageTextController.clear();
                      //Implement send functionality.
                      /*_firebaseStorage.collection('messages').add(
                          {'text': messageText, 'sender': loggedInUser.email});*/

                      //insert data into firebase on click of send
                      //insertDataIntoFirebaseFabrication();
                      //insertDataIntoFirebaseSubAssembly();
                      //insertDataIntoFirebaseAssembly();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

UserRoles getCurrentUserRole(String? email) {
  print(email);
  if (email == null) return UserRoles.UNKNOWN;

  if (email == "rohitdeepu17@gmail.com") {
    return UserRoles.FABRICATION_USER;
  } else if (email == "vinaylingam18@gmail.com")
    return UserRoles.DATA_OFFICER;
  else if (email == "vaibhavshaw028@gmail.com")
    return UserRoles.SUB_ASSEMBLY_USER;
  else if (email == "simranjha4402@gmail.com")
    return UserRoles.ASSEMBLY_USER;

  return UserRoles.FABRICATION_USER;
}

String getCollectionBasedOnRole(UserRoles userRoles) {
  switch (userRoles) {
    case UserRoles.DATA_OFFICER:
      return 'fabrication';
    case UserRoles.FABRICATION_USER:
      return 'fabrication';
    case UserRoles.SUB_ASSEMBLY_USER:
      return 'sub_assembly';
    case UserRoles.ASSEMBLY_USER:
      return 'assembly';
    case UserRoles.UNKNOWN:
      return 'fabrication';
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Material(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0)),
              elevation: 5.0,
              color: Colors.lightBlueAccent,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Text(
                  '$text',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ))
        ],
      ),
    );
  }

  MessageBubble(this.sender, this.text, this.isMe);
}
