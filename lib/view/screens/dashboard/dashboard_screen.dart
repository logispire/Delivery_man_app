import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sixam_mart_delivery/controller/auth_controller.dart';
import 'package:sixam_mart_delivery/controller/order_controller.dart';
import 'package:sixam_mart_delivery/helper/notification_helper.dart';
import 'package:sixam_mart_delivery/helper/route_helper.dart';
import 'package:sixam_mart_delivery/main.dart';
import 'package:sixam_mart_delivery/util/app_constants.dart';
import 'package:sixam_mart_delivery/util/dimensions.dart';
import 'package:sixam_mart_delivery/view/base/custom_alert_dialog.dart';
import 'package:sixam_mart_delivery/view/screens/dashboard/widget/bottom_nav_item.dart';
import 'package:sixam_mart_delivery/view/screens/dashboard/widget/new_request_dialog.dart';
import 'package:sixam_mart_delivery/view/screens/home/home_screen.dart';
import 'package:sixam_mart_delivery/view/screens/profile/profile_screen.dart';
import 'package:sixam_mart_delivery/view/screens/request/order_request_screen.dart';
import 'package:sixam_mart_delivery/view/screens/order/order_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;

  const DashboardScreen({Key? key, required this.pageIndex}) : super(key: key);

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  PageController? _pageController;
  int _pageIndex = 0;
  late List<Widget> _screens;
  final _channel = const MethodChannel('com.sixamtech/app_retain');
  late StreamSubscription _stream;

  //Timer _timer;
  //int _orderCount;

  @override
  void initState() {
    super.initState();

    _pageIndex = widget.pageIndex;

    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      const HomeScreen(),
      OrderRequestScreen(onTap: () => _setPage(0)),
      const OrderScreen(),
      const ProfileScreen(),
    ];

    if (kDebugMode) {
      print('dashboard call');
    }
    _stream = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // if(Get.find<OrderController>().latestOrderList != null) {
      //   _orderCount = Get.find<OrderController>().latestOrderList.length;
      // }
      if (kDebugMode) {
        print("dashboard onMessage: ${message.data}/ ${message.data['type']}");
      }
      String? type = message.notification!.bodyLocKey;
      String? orderID = message.notification!.titleLocKey;
      if (type != 'assign' &&
          type != 'new_order' &&
          type != 'message' &&
          type != 'order_request' &&
          type != 'order_status') {
        NotificationHelper.showNotification(
            message, flutterLocalNotificationsPlugin);
      }
      /*Get.find<OrderController>().getCurrentOrders();
      Get.find<OrderController>().getLatestOrders();*/
      //Get.find<OrderController>().getAllOrders();
      if (type == 'new_order' || type == 'order_request') {
        //_orderCount = _orderCount + 1;
        Get.find<OrderController>().getCurrentOrders();
        Get.find<OrderController>().getLatestOrders();
        Get.dialog(NewRequestDialog(
            isRequest: true,
            onTap: () => _navigateRequestPage(),
            orderId: int.parse(message.data['order_id'].toString())));
      } else if (type == 'assign' && orderID != null && orderID.isNotEmpty) {
        Get.find<OrderController>().getCurrentOrders();
        Get.find<OrderController>().getLatestOrders();
        Get.dialog(NewRequestDialog(
            isRequest: false,
            orderId: int.parse(message.data['order_id'].toString()),
            onTap: () {
              // _setPage(0);
              Get.offAllNamed(RouteHelper.getOrderDetailsRoute(
                  int.parse(orderID),
                  fromNotification: true));
            }));
      } else if (type == 'block') {
        Get.find<AuthController>().clearSharedData();
        Get.find<AuthController>().stopLocationRecord();
        Get.offAllNamed(RouteHelper.getSignInRoute());
      }
    });

    // _timer = Timer.periodic(Duration(seconds: 30), (timer) async {
    //   await Get.find<OrderController>().getLatestOrders();
    //   int _count = Get.find<OrderController>().latestOrderList.length;
    //   if(_orderCount != null && _orderCount < _count) {
    //     Get.dialog(NewRequestDialog(isRequest: true, onTap: () => _navigateRequestPage()));
    //   }else {
    //     _orderCount = Get.find<OrderController>().latestOrderList.length;
    //   }
    // });
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _timer?.cancel();
  // }

  void _navigateRequestPage() {
    if (Get.find<AuthController>().profileModel != null &&
        Get.find<AuthController>().profileModel!.active == 1 &&
        Get.find<OrderController>().currentOrderList != null &&
        Get.find<OrderController>().currentOrderList!.isEmpty) {
      _setPage(1);
    } else {
      if (Get.find<AuthController>().profileModel == null ||
          Get.find<AuthController>().profileModel!.active == 0) {
        Get.dialog(CustomAlertDialog(
            description: 'you_are_offline_now'.tr,
            onOkPressed: () => Get.back()));
      } else {
        //Get.dialog(CustomAlertDialog(description: 'you_have_running_order'.tr, onOkPressed: () => Get.back()));
        _setPage(1);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();

    _stream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_pageIndex != 0) {
          _setPage(0);
          return false;
        } else {
          if (GetPlatform.isAndroid &&
              Get.find<AuthController>().profileModel!.active == 1) {
            _channel.invokeMethod('sendToBackground');
            return false;
          } else {
            return true;
          }
        }
      },
      child: Scaffold(
        bottomNavigationBar: GetPlatform.isDesktop
            ? const SizedBox()
            : BottomAppBar(
                elevation: 5,
                notchMargin: 5,
                child: Container(
                  color: ColorConstants.secondary,
                  padding: const EdgeInsets.only(
                      top: 12, bottom: 12, left: 15, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => _setPage(0),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(maxHeight: 35),
                        icon: Image.asset(
                          "assets/icons/home.png",
                          height: 23,
                          color: getBottomIconColor(_pageIndex == 0),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _navigateRequestPage();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(maxHeight: 35),
                        icon: Image.asset(
                          "assets/icons/order_request.png",
                          height: 23,
                          color: getBottomIconColor(_pageIndex == 1),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _setPage(2),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(maxHeight: 35),
                        icon: Image.asset(
                          "assets/icons/my_orders.png",
                          height: 23,
                          color: getBottomIconColor(_pageIndex == 2),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _setPage(3),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(maxHeight: 35),
                        icon: Image.asset(
                          "assets/icons/profile.png",
                          height: 23,
                          color: getBottomIconColor(_pageIndex == 3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: _screens.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _screens[index];
          },
        ),
      ),
    );
  }

  Color getBottomIconColor(bool isSelected) {
    if (isSelected) {
      return ColorConstants.primary;
    } else {
      return Colors.white;
    }
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }
}
