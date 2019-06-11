import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:snapp_challenge/constants.dart';
import 'package:snapp_challenge/generated/i18n.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

const LatLng _kMapCenter = LatLng(35.6892, 51.3890); // Middle of Tehran

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).map_screen_title,
          style: TextStyle(fontSize: 16),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          )
        ],
        centerTitle: true,
        elevation: 0,
      ),
      drawer: _Drawer(),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            onMapCreated: (controller) => _controller.complete(controller),
            initialCameraPosition:
                const CameraPosition(target: _kMapCenter, zoom: 15.0),
            compassEnabled: true,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            cameraTargetBounds: CameraTargetBounds(
              // Limit map to Iran
              LatLngBounds(
                southwest: LatLng(30, 44),
                northeast: LatLng(36, 60),
              ),
            ),
            minMaxZoomPreference: MinMaxZoomPreference(5, 20),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              child: Card(
                margin: EdgeInsets.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('۳ اسنپ موجود'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(children: <Widget>[
                        Expanded(
                          child: Divider(
                            color: Colors.black38,
                          ),
                        ),
                        Icon(
                          Icons.location_on,
                          color: Constants.green[1],
                          size: 16,
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.black38,
                          ),
                        )
                      ]),
                    ),
                    Text(':مبدا')
                  ],
                ),
              ),
            ),
          ),
          Align(
              alignment: Alignment.center,
              child: _DestinationMarker(
                title: 'مبدا',
                onTap: () {},
              ))
        ],
      ),
    );
  }
}

class _Drawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  padding: EdgeInsets.zero,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        color: Constants.blue[1],
                        height: 120,
                      ),
                      Align(
                        alignment: AlignmentDirectional.bottomStart,
                        child: _CreditDrawerItem(),
                      )
                    ],
                  ),
                ),
                _DrawerItem(
                  title: S.of(context).map_screen_drawer_usr_info,
                  iconData: Icons.person,
                ),
                Divider(),
                _DrawerItem(
                  title: S.of(context).map_screen_drawer_transactions,
                  iconData: Icons.receipt,
                ),
                Divider(),
                _DrawerItem(
                  title: S.of(context).map_screen_drawer_rides,
                  iconData: Icons.directions_car,
                ),
                Divider(),
                _DrawerItem(
                  title: S.of(context).map_screen_drawer_fav_addresses,
                  iconData: Icons.star,
                ),
                Divider(),
                _DrawerItem(
                  title: S.of(context).map_screen_drawer_messages,
                  iconData: Icons.message,
                ),
                Divider(),
                _DrawerItem(
                  title: S.of(context).map_screen_drawer_support,
                  iconData: Icons.help,
                ),
                Divider(),
                _DrawerItem(
                  title: S.of(context).map_screen_drawer_about,
                  iconData: Icons.alternate_email,
                ),
                Divider(),
                _DrawerItem(
                  title: S.of(context).map_screen_drawer_settings,
                  iconData: Icons.settings,
                ),
                Divider(),
                _DrawerItem(
                  title: S.of(context).map_screen_drawer_exit,
                  iconData: Icons.accessibility,
                  textColor: Constants.gray[4],
                  iconColor: Constants.gray[4],
                ),
                Divider(),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            color: Constants.gray[1],
            child: Column(
              children: <Widget>[
                _DrawerItem(
                  title: S.of(context).map_screen_drawer_invite,
                  iconData: Icons.card_giftcard,
                  iconColor: Constants.green[1],
                  textColor: Constants.green[1],
                  iconSize: 18,
                  fontWeight: FontWeight.normal,
                ),
                Divider(),
                _DrawerItem(
                  title: S.of(context).map_screen_drawer_snapp_food_promotion,
                  iconData: Icons.fastfood,
                  iconColor: Constants.red[1],
                  textColor: Constants.red[1],
                  iconSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreditDrawerItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Constants.gray[1],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 12.0),
              child: Icon(Icons.account_balance_wallet),
            ),
            Text(" ۱۰,۰۰۰ ریال"),
            Spacer(),
            MaterialButton(
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              height: 25,
              color: Constants.green[1],
              colorBrightness: Brightness.dark,
              child: Container(
                height: 25,
                child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Icon(
                    Icons.add,
                    size: 16,
                  ),
                  VerticalDivider(color: Colors.white),
                  Text(
                    S.of(context).map_screen_drawer_credit_plus,
                    style: TextStyle(fontSize: 12),
                  ),
                ]),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35),
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String title;
  final IconData iconData;
  final Color iconColor;
  final Color textColor;
  final double iconSize;
  final double textSize;
  final FontWeight fontWeight;

  const _DrawerItem({
    @required this.title,
    @required this.iconData,
    this.textColor,
    this.iconColor,
    this.iconSize,
    this.textSize,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 12.0),
          child: Icon(
            iconData,
            color: iconColor,
            textDirection: TextDirection.ltr,
            size: iconSize,
          ),
        ),
        Text(
          title,
          style: TextStyle(
              color: textColor, fontSize: textSize, fontWeight: fontWeight),
        ),
      ]),
    );
  }
}

class _DestinationMarker extends StatelessWidget {
  final String title;
  final GestureTapCallback onTap;

  _DestinationMarker({@required this.title, @required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: 65,
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            PhysicalModel(
              color: Colors.black,
              shape: BoxShape.circle,
              child: Container(
                width: 55,
                height: 55,
              ),
            ),
            PhysicalModel(
              color: Colors.white,
              shape: BoxShape.circle,
              child: Container(
                width: 50,
                height: 50,
              ),
            ),
            PhysicalModel(
              color: Constants.green[1],
              shape: BoxShape.circle,
              child: Container(
                width: 44,
                height: 44,
              ),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.white),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: PhysicalModel(
                color: Colors.black,
                shape: BoxShape.rectangle,
                elevation: 8,
                child: Container(
                  width: 5,
                  height: 25,
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
