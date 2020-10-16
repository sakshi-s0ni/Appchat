import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class MyChat extends StatefulWidget {
  @override
  _MyChatState createState() => _MyChatState();
}

class _MyChatState extends State<MyChat> {
  var msgtextcontroller = TextEditingController();

  var fs = FirebaseFirestore.instance;
  var authc = FirebaseAuth.instance;

  String chatmsg;

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    var signInUser = authc.currentUser.email;
    var _currentPosition;
    var currentAddress;
    var city;
    Future<void> _showMyDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Location'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text("$city"),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    _getAddressFromLatLng() async {
      try {
        List<Placemark> p = await geolocator.placemarkFromCoordinates(
            _currentPosition.latitude, _currentPosition.longitude);

        Placemark place = p[0];

        setState(() {
          currentAddress = "${place.locality}, ${place.country}";
        });
      } catch (e) {
        print(e);
      }
      city = await currentAddress;
      print(currentAddress);
      _showMyDialog();
    }

    _getCurrentLocation() async {
      await geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .then((Position position) {
        setState(() {
          _currentPosition = position;
        });
        print(_currentPosition);
        _getAddressFromLatLng();
      }).catchError((e) {
        print(e);
      });
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('chat'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.location_on),
                onPressed: () {
                  _getCurrentLocation();
                })
          ],
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              StreamBuilder<QuerySnapshot>(
                builder: (context, snapshot) {
                  var msg = snapshot.data.docs;

                  List<Widget> y = [];
                  for (var d in msg) {
                    var msgText = d.data()['text'];
                    var msgSender = d.data()['sender'];
                    var msgWidget = Text("$msgSender: $msgText");
                    y.add(msgWidget);
                  }

                  return Container(
                    child: Column(
                      children: y,
                    ),
                  );
                },
                stream: fs.collection("chat").snapshots(),
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: deviceWidth * 0.70,
                    child: TextField(
                      controller: msgtextcontroller,
                      decoration: InputDecoration(hintText: 'Enter msg ..'),
                      onChanged: (value) {
                        chatmsg = value;
                      },
                    ),
                  ),
                  Container(
                    width: deviceWidth * 0.20,
                    child: FlatButton(
                      child: Text('send'),
                      onPressed: () async {
                        msgtextcontroller.clear();

                        await fs.collection("chat").add({
                          "text": chatmsg,
                          "sender": signInUser,
                        });
                        print(signInUser);
                        _getCurrentLocation();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
