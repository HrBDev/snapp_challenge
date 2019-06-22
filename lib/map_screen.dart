import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:snapp_challenge/constants.dart';
import 'package:snapp_challenge/generated/i18n.dart';
import 'package:snapp_challenge/my_animations.dart';
import 'package:snapp_challenge/utils.dart';

enum States { origin, destinationSelect, serviceSelect }

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

// Middle of Tehran
const CameraPosition _kInitialPosition = CameraPosition(
  target: LatLng(35.6892, 51.3890),
  zoom: 15,
);

class _MapScreenState extends State<MapScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController controller;
  Size screenSize;

  // Limit map to Iran
  static final _kIranBounds = LatLngBounds(
    southwest: const LatLng(30, 44),
    northeast: const LatLng(36, 60),
  );

  //TODO: Use proper state management
  var state = States.origin;

  _createHoveringMarker() {
    return Align(
        alignment: Alignment.center,
        child: _DestinationMarker(
          title: state == States.destinationSelect
              ? S.of(context).map_screen_destination
              : S.of(context).map_screen_origin,
          onTap: () {
            if (state == States.origin) {
              setState(() => state = States.destinationSelect);
              //TODO: set origin marker on map(requires asset or use default marker image)
            } else if (state == States.destinationSelect) {
              setState(() => state = States.serviceSelect);
              //TODO: set destination marker(requires asset or use default marker image)
            }
          },
        ));
  }

  Future<bool> _onBackPressed() async {
    if (state == States.serviceSelect) {
      setState(() => state = States.destinationSelect);
      return false;
    } else if (state == States.destinationSelect) {
      setState(() => state = States.origin);
      return false;
    } else {
      return true;
    }
  }

  bool _onBackArrowPressed() {
    if (state == States.serviceSelect) {
      setState(() => state = States.destinationSelect);
      return false;
    } else if (state == States.destinationSelect) {
      setState(() => state = States.origin);
      return false;
    } else {
      return true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          bottom: state == States.serviceSelect
              ? PreferredSize(
                  preferredSize: Size.fromHeight(56.0),
                  child: SlideDown(
                    child: Container(
                      constraints: BoxConstraints.expand(height: 56),
                      color: Constants.blue[1],
                      child: Center(
                        child: Text(
                          'اسنپ به:',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                )
              : PreferredSize(
                  child: SizedBox.shrink(),
                  preferredSize: Size.fromHeight(0),
                ),
          title: Text(
            state == States.origin
                ? S.of(context).map_screen_title
                : (state == States.destinationSelect
                    ? 'کجا می‌روید ؟'
                    : 'سفر سلامت'),
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: state == States.serviceSelect ? 0.0 : 1.0,
              child: SizedBox(
                height: 56,
                child: IconButton(
                  icon: Icon(
                    Icons.search,
                  ),
                  onPressed: () {},
                ),
              ),
            ),
            AnimatedCrossFade(
              sizeCurve: Curves.easeInOutBack,
              firstCurve: Curves.decelerate,
              secondCurve: Curves.decelerate,
              firstChild: SizedBox(
                height: 56,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    textDirection: TextDirection.ltr,
                  ),
                  onPressed: () {
                    if (_onBackArrowPressed()) {
                      SystemNavigator.pop();
                    }
                  },
                ),
              ),
              secondChild: SizedBox(),
              crossFadeState: (state == States.serviceSelect ||
                      state == States.destinationSelect)
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: Duration(milliseconds: 500),
            ),
          ],
          centerTitle: true,
          elevation: 0,
          primary: true,
          brightness: Brightness.light,
        ),
        drawer: _Drawer(),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              mapType: MapType.normal,
              onMapCreated: (controller) => _controller.complete(controller),
              initialCameraPosition: _kInitialPosition,
              compassEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              cameraTargetBounds: CameraTargetBounds(_kIranBounds),
              minMaxZoomPreference: const MinMaxZoomPreference(5, 20),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: state != States.serviceSelect
                  ? AnimatedCrossFade(
                      duration: Duration(milliseconds: 750),
                      firstChild: _BottomPanel(
                          topText: S.of(context).map_screen_origin + ":",
                          bottomText:
                              S.of(context).map_screen_destination + ":"),
                      secondChild: _BottomPanel(
                        topText:
                            '${Utils.replaceFarsiNumber(math.Random().nextInt(10).toString())} ${S.of(context).map_screen_available_snapps}',
                        bottomText: S.of(context).map_screen_origin + ":",
                      ),
                      crossFadeState: state == States.destinationSelect
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                    )
                  : SizedBox.shrink(),
            ),
            state == States.serviceSelect
                ? SizedBox.shrink()
                : _createHoveringMarker(),
          ],
        ),
        bottomSheet: SlideUp(
          child: Container(
            height: screenSize.height / 3.5,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: state == States.serviceSelect
                  ? _ChooseServiceBottomSheet()
                  : SizedBox(),
            ),
          ),
        ),
      ),
      onWillPop: _onBackPressed,
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
                  onTap: () {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
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
            Text(" ۱۰,۰۰۰ ریال", style: TextStyle(fontSize: 16)),
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
  final GestureTapCallback onTap;

  const _DrawerItem({
    @required this.title,
    @required this.iconData,
    this.textColor,
    this.iconColor,
    this.iconSize,
    this.textSize,
    this.fontWeight = FontWeight.bold,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
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
      ),
      onTap: onTap,
    );
  }
}

class _DestinationMarker extends StatelessWidget {
  final String title;
  final GestureTapCallback onTap;

  _DestinationMarker({@required this.title, @required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: 80,
        height: 130,
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Positioned(
              top: 0,
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
                ],
              ),
            ),
            Positioned(
              top: 55,
              child: PhysicalModel(
                elevation: 100,
                color: Colors.black,
                shape: BoxShape.rectangle,
                child: Container(
                  width: 5,
                  height: 13,
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
  _ChooseServiceBottomSheetState createState() =>
      _ChooseServiceBottomSheetState();
}

class _ChooseServiceBottomSheetState extends State<_ChooseServiceBottomSheet>
    with SingleTickerProviderStateMixin {
  Animation _animation;
  AnimationController _animController;
  Size screenSize;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    final curve = CurvedAnimation(
      parent: _animController,
      curve: Curves.fastOutSlowIn,
    );

    _animation = IntTween(begin: 65000, end: 21000).animate(curve);

    _animController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
              // TODO: Implement selection
              _MyCircleAvatar(
                imagePath: 'res/images/bike.png',
                title: S.of(context).map_screen_bike_description,
              ),
              _MyCircleAvatar(
                imagePath: 'res/images/box.png',
                title: S.of(context).map_screen_box_description,
              ),
              _MyCircleAvatar(
                imagePath: 'res/images/rose.png',
                title: S.of(context).map_screen_rose_description,
              ),
              _MyCircleAvatar(
                imagePath: 'res/images/eco.png',
                title: S.of(context).map_screen_eco_description,
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
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
                    Container(
                      child: AnimatedBuilder(
                        animation: _animController,
                        builder: (BuildContext context, Widget child) {
                          return Text(
                            _animController.status == AnimationStatus.completed
                                ? '۶۰۰۰۰'
                                : Utils.replaceFarsiNumber(
                                    _animation.value.toString()),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      width: 50,
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      'ریال',
                      style: TextStyle(color: Constants.gray[3]),
                    ),
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
            margin: EdgeInsets.symmetric(horizontal: screenSize.width / 4),
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
