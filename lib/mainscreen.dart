import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:toast/toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trulyasia/location.dart';
import 'package:trulyasia/locationinfo.dart';

void main() => runApp(MainScreen());

class MainScreen extends StatefulWidget {
  //final User user;
  //const MainScreen ({Key key, this.user}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List locationdata;
  double screenHeight, screenWidth;
  bool _visible = false;
  //String curstate = "Recent";

  List locationList;
  String thestate;

  List _dropDownState = [
    "Johor",
    "Kedah",
    "Kelantan",
    "Perak",
    "Selangor",
    "Melaka",
    "Negeri Sembilan",
    "Pahang",
    "Perlis",
    "Penang",
    "Sabah",
    "Sarawak",
    "Terengganu"
  ];

  String curstate = "Kedah";
  //bool sort = false;
  //bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    loadPref();
  }

  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    //TextEditingController _prdController = new TextEditingController();

    if (locationdata == null) {
      return Scaffold(
        //theme: ThemeData.dark(),
        //debugShowCheckedModeBanner: false,
        //home: Scaffold(
        backgroundColor: Colors.amber,
        appBar: AppBar(
          title: Text('Destinations'),
        ),
        body: Container(
            child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(
                height: 10,
              ),
              Text(
                "Loading . . .",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              )
            ],
          ),
        )),
      );
    } else {
      //return WillPopScope(
      //onWillPop: _onBackPressed,
      return Scaffold(
        backgroundColor: Colors.amber,
        //drawer: mainDrawer(context),
        appBar: AppBar(
          backgroundColor: Colors.amber[800],
          //elevation: 0.5,
          //title: Container(
          //padding: EdgeInsets.only(left: 70),
          title:
              Text("Best Destinations", style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            IconButton(
              icon: _visible
                  ? new Icon(Icons.expand_more)
                  : new Icon(Icons.expand_less),
              onPressed: () {
                setState(() {
                  if (_visible) {
                    _visible = false;
                  } else {
                    _visible = true;
                  }
                });
              },
            ),
          ],
        ),
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              //TableCell(
              //Container(
              //height: 40,
              Container(
                //height: 20,
                child: DropdownButton(
                  hint: Text('State', style: TextStyle(color: Colors.black)),
                  value: thestate,
                  onChanged: (newValue) {
                    setState(() {
                      thestate = newValue;
                      print(thestate);
                    });
                    _sortItem(thestate);
                  },
                  items: _dropDownState.map((thestate) {
                    return DropdownMenuItem(
                      child: new Text(
                        thestate,
                        style: TextStyle(color: Colors.black),
                      ),
                      value: thestate,
                    );
                  }).toList(),
                ),
              ),

              Text(curstate,
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: (screenWidth / screenHeight) / 0.80,
                  children: List.generate(locationdata.length, (index) {
                    return Container(
                        child: Card(
                      elevation: 10,
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => _onLocationInfo(index),
                              child: Container(
                                height: screenWidth / 2.5,
                                width: screenWidth / 2.5,
                                child: ClipOval(
                                    child: CachedNetworkImage(
                                  fit: BoxFit.fill,
                                  imageUrl:
                                      "http://slumberjer.com/visitmalaysia/images/${locationdata[index]['imagename']}",
                                  placeholder: (context, url) =>
                                      new CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      new Icon(Icons.error),
                                )),
                              ),
                            ),
                            Text(locationdata[index]['loc_name'] + ",",
                                maxLines: 1,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            Text(
                              locationdata[index]['state'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ));
                  }),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  _onLocationInfo(int index) async {
    print(locationdata[index]['loc_name']);
    Location location = new Location(
        pid: locationdata[index]['pid'],
        locName: locationdata[index]['loc_name'],
        state: locationdata[index]['state'],
        description: locationdata[index]['description'],
        latitude: locationdata[index]['latitude'],
        longitude: locationdata[index]['longitude'],
        url: locationdata[index]['url'],
        contact: locationdata[index]['contact'],
        address: locationdata[index]['address'],
        imagename: locationdata[index]['imagename']);

    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => LocationInfo(
                  location: location,
                )));
    //_loadData();
  }

  void _loadData() {
    String urlLoadJobs =
        "http://slumberjer.com/visitmalaysia/load_destinations.php";
    http.post(urlLoadJobs, body: {}).then((res) {
      setState(() {
        print(res.body);
        var extractdata = json.decode(res.body);
        locationdata = extractdata["locations"];
        //_sortItem(curstate);
      });
    }).catchError((err) {
      print(err);
    });
  }

  void _sortItem(String state) {
    try {
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: true);
      pr.style(message: "Searching . . .");
      pr.show();
      String urlLoadJobs =
          "http://slumberjer.com/visitmalaysia/load_destinations.php";
      http.post(urlLoadJobs, body: {
        "state": state,
      }).then((res) {
        setState(() {
          curstate = state;
          var extractdata = json.decode(res.body);
          locationdata = extractdata["locations"];
          FocusScope.of(context).requestFocus(new FocusNode());
          pr.hide();
        });
      }).catchError((err) {
        print(err);
        pr.hide();
      });
      pr.hide();
    } catch (e) {
      Toast.show("Error", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  Future<bool> _onBackPressed() {
    savepref(true);
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            title: new Text(
              'Are you sure?',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            content: new Text(
              'Do you want to exit an App',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                  onPressed: () {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                  child: Text(
                    "Exit",
                    style: TextStyle(
                      color: Color.fromRGBO(101, 255, 218, 50),
                    ),
                  )),
              MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Color.fromRGBO(101, 255, 218, 50),
                    ),
                  )),
            ],
          ),
        ) ??
        false;
  }

  Future<void> loadPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String state = (prefs.getString('state')) ?? '';
    setState(() {
      this.curstate = state;
    });
  }

  void savepref(bool value) async {
    String state = curstate;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value) {
      //save preference
      await prefs.setString('state', state);
      Toast.show("Preferences have been saved", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    } else {
      //delete preference
      await prefs.setString('state', '');
      Toast.show("Preferences have removed", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }
}
