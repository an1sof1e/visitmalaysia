import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class LocationInfo extends StatefulWidget {
  final Location location;

  const LocationInfo({Key key, this.location}) : super(key: key);

  @override
  _LocationInfoState createState() => _LocationInfoState();
}

class _LocationInfoState extends State<LocationInfo> {
  double screenHeight, screenWidth;
  List<Marker> allMarkers = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    allMarkers.add(Marker(
        markerId: MarkerId('myMarker'),
        draggable: false,
        onTap: () {
          print('Marker Tapped');
        },
        position: LatLng(double.parse(widget.location.latitude),
            double.parse(widget.location.longitude))));

    return Scaffold(
        backgroundColor: Colors.amber,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.amber[800],
          title: Text(widget.location.locName),
        ),
        body: Container(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                Container(
                  height: screenHeight / 3,
                  width: screenWidth / 1.5,
                  child: CachedNetworkImage(
                    fit: BoxFit.fill,
                    imageUrl:
                        "http://slumberjer.com/visitmalaysia/images/${widget.location.imagename}",
                    placeholder: (context, url) =>
                        new CircularProgressIndicator(),
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                  ),
                ),
                SizedBox(height: 6),
                Container(
                    width: screenWidth / 1.1,
                    //height: screenHeight / 2,
                    child: Card(
                        elevation: 6,
                        child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: <Widget>[
                                Table(
                                    defaultColumnWidth: FlexColumnWidth(1.0),
                                    children: [
                                      TableRow(children: [
                                        TableCell(
                                          child: Container(
                                              alignment: Alignment.centerLeft,
                                              height: 80,
                                              child: Text("Description",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ))),
                                        ),
                                        TableCell(
                                            child: Container(
                                          height: 130,
                                          child: Container(
                                              alignment: Alignment.centerLeft,
                                              height: 80,
                                              child: Text(
                                                "" +
                                                    widget.location.description,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              )),
                                        )),
                                      ]),
                                      TableRow(children: [
                                        TableCell(
                                          child: Container(
                                              alignment: Alignment.centerLeft,
                                              height: 200,
                                              child: Text("URL",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ))),
                                        ),
                                        TableCell(
                                            child: Column(children: <Widget>[
                                          GestureDetector(
                                            onTap: () => _launchUrlDialog(),
                                            child: Container(
                                                alignment: Alignment.centerLeft,
                                                height: 200,
                                                child: Text(
                                                  " " + widget.location.url,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                )),
                                          )
                                        ])),
                                      ]),
                                      TableRow(children: [
                                        TableCell(
                                          child: Container(
                                              alignment: Alignment.centerLeft,
                                              height: 80,
                                              child: Text("Address",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ))),
                                        ),
                                        TableCell(
                                            child: Container(
                                          height: 80,
                                          child: Container(
                                              alignment: Alignment.centerLeft,
                                              height: 30,
                                              child: Text(
                                                " " + widget.location.address,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              )),
                                        )),
                                      ]),
                                      TableRow(children: [
                                        TableCell(
                                          child: Container(
                                              alignment: Alignment.centerLeft,
                                              height: 30,
                                              child: Text("Phone",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ))),
                                        ),
                                        TableCell(
                                            child: Column(children: <Widget>[
                                          GestureDetector(
                                              onTap: () => _phoneCallDialog(),
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                height: 50,
                                                child: Text(
                                                    " " +
                                                        widget.location.contact,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    )),
                                              )),
                                        ])),
                                      ]),
                                      /*TableRow(children: [
                                        TableCell(
                                          child: Container(
                                              alignment: Alignment.centerLeft,
                                              height: 80,
                                              child: Text("Google Map",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ))),
                                        ),
                                        TableCell(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            height: 100,
                                            child: GoogleMap(
                                              initialCameraPosition:
                                                  CameraPosition(
                                                target: LatLng(
                                                    double.parse(widget
                                                        .location.latitude),
                                                    double.parse(widget
                                                        .location.longitude)),
                                                zoom: 12,
                                              ),
                                              markers: Set.from(allMarkers),
                                            ),
                                          ),
                                        ),
                                      ]),*/
                                    ]),
                                SizedBox(height: 3),
                              ],
                            )))),
              ],
            ),
          ),
        ));
  }

  _phoneCallDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: new Text(
            "Make a Phone Call " + '?',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                "Yes",
                style: TextStyle(
                  color: Colors.orangeAccent[700],
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
                _phoneCall('tel:' + widget.location.contact);
              },
            ),
            new FlatButton(
              child: new Text(
                "No",
                style: TextStyle(
                  color: Colors.orangeAccent[700],
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }

  _launchUrlDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: new Text(
            "Open Url link " + '?',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                "Yes",
                style: TextStyle(
                  color: Colors.orangeAccent[700],
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
                _lauchUrl('http:' + widget.location.url);
              },
            ),
            new FlatButton(
              child: new Text(
                "No",
                style: TextStyle(
                  color: Colors.orangeAccent[700],
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _phoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _lauchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
