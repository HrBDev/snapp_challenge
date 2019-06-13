import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:snapp_challenge/constants.dart';
import 'package:snapp_challenge/generated/i18n.dart';
import 'package:snapp_challenge/utils.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

const LatLng _kMapCenter = LatLng(35.6892, 51.3890); // Middle of Tehran

// Limit map to Iran
LatLngBounds _kIranBounds = LatLngBounds(
  southwest: const LatLng(30, 44),
  northeast: const LatLng(36, 60),
);

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController controller;

  //TODO: implement state management using InheritedWidget or ScopedModel
  bool isDestination = false;
  bool isDestinationSet = false;

  _createHoveringMarker() {
    return Align(
        alignment: Alignment.center,
        child: _DestinationMarker(
          title: isDestination
              ? S.of(context).map_screen_destination
              : S.of(context).map_screen_origin,
          onTap: () {
            if (!isDestination) {
              setState(() {
                isDestination = true;
                //TODO: set origin marker on map(requires asset or use default marker image)
              });
            } else if (isDestination) {
              setState(() {
                isDestinationSet = true;
              });
              //TODO: set destination marker(requires asset or use default marker image)
            }
          },
        ));
  }

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
            compassEnabled: false,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            cameraTargetBounds: CameraTargetBounds(_kIranBounds),
            minMaxZoomPreference: const MinMaxZoomPreference(5, 20),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedCrossFade(
              duration: Duration(milliseconds: 500),
              firstChild: _BottomPanel(
                  key: UniqueKey(),
                  topText: S.of(context).map_screen_origin + ":",
                  bottomText: S.of(context).map_screen_destination + ":"),
              secondChild: _BottomPanel(
                key: UniqueKey(),
                topText:
                    '${Utils.replaceFarsiNumber('3')} ${S.of(context).map_screen_available_snapps}',
                bottomText: S.of(context).map_screen_origin + ":",
              ),
              crossFadeState: isDestination
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
            ),
          ),
          isDestinationSet ? SizedBox.shrink() : _createHoveringMarker(),
        ],
      ),
      bottomSheet: Container(
        height: MediaQuery.of(context).size.height / 3.5,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: isDestinationSet
              ? _ChooseServiceBottomSheet()
              : SizedBox.shrink(),
        ),
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
              addAutomaticKeepAlives: true,
              addRepaintBoundaries: false,
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
            padding: const EdgeInsets.symmetric(vertical: 8.0),
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

class _BottomPanel extends StatelessWidget {
  final String topText;
  final String bottomText;

  _BottomPanel({Key key, @required this.topText, this.bottomText});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(topText),
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
          Text(bottomText)
        ],
      ),
    );
  }
}

class _MyCircleAvatar extends StatelessWidget {
  final String title;
  final String imagePath;

  _MyCircleAvatar({
    @required this.title,
    @required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 1,
        width: 75,
        child: Column(
          children: <Widget>[
            CircleAvatar(
              child: Image.asset(imagePath),
              maxRadius: double.infinity,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 9,
                  wordSpacing: -0.9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ChooseServiceBottomSheet extends StatefulWidget {
  @override
  __ChooseServiceBottomSheetState createState() =>
      __ChooseServiceBottomSheetState();
}

class __ChooseServiceBottomSheetState extends State<_ChooseServiceBottomSheet>
    with SingleTickerProviderStateMixin {
  Animation animation;
  AnimationController animationController;
  bool isAnimationCompleted = false;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: Duration(seconds: 3), vsync: this);

    animation = IntTween(begin: 45000, end: 21000).animate(CurvedAnimation(
        parent: animationController, curve: Curves.fastOutSlowIn));

    animationController.forward();

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isAnimationCompleted = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              _MyCircleAvatar(
                imagePath: 'res/images/bike.png',
                title: 'موتور ویژه مسافر',
              ),
              _MyCircleAvatar(
                imagePath: 'res/images/box.png',
                title: ' موتور ویژه مرسولات',
              ),
              _MyCircleAvatar(
                imagePath: 'res/images/rose.png',
                title: 'ویژه بانوان',
              ),
              _MyCircleAvatar(
                imagePath: 'res/images/eco.png',
                title: 'به‌صرفه و فوری',
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton(
                  child: Text(
                    'کد تخفیف',
                    style: TextStyle(color: Constants.green[1]),
                  ),
                  onPressed: () {},
                ),
                VerticalDivider(
                  color: Colors.black38,
                ),
                Row(
                  children: <Widget>[
                    AnimatedBuilder(
                      animation: animationController,
                      builder: (BuildContext context, Widget child) {
                        return Text(
                          isAnimationCompleted
                              ? '۶۰۰۰۰'
                              : Utils.replaceFarsiNumber(
                                  animation.value.toString()),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                    SizedBox(width: 8.0,),
                    Text('ریال'),
                  ],
                ),
                VerticalDivider(
                  color: Colors.black38,
                ),
                FlatButton(
                  child: Text('گزینه ها',
                      style: TextStyle(color: Constants.green[1])),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 50,
          width: double.infinity,
          color: Constants.blue[1],
          child: Container(
            height: 50,
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 4),
            child: Center(
                child: Text(
              'درخواست اسنپ اکو',
              style: TextStyle(color: Colors.white, fontSize: 18),
            )),
            color: Constants.green[1],
          ),
        )
      ],
    );
  }
}
