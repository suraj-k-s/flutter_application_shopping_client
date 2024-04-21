import 'package:flutter/material.dart';
import 'package:flutter_application_shopping_client/screens/account.dart';
import 'package:flutter_application_shopping_client/screens/orders.dart';
import 'package:flutter_application_shopping_client/screens/serach.dart';
import 'package:flutter_application_shopping_client/widgets/appbar.dart';
import 'package:flutter_application_shopping_client/widgets/bottom_navigation.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({super.key});
  static ValueNotifier<int> selectedIndex = ValueNotifier(0);

  @override
  State<ScreenHome> createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  final page = const [ScreenSearch(), ScreenOrders(), ScreenAccount()];
  String cartQuantity = '';
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ScreenAppBar(appHeading: 'Home-Search'),
      bottomNavigationBar: BottomNavigation(),
      body: SafeArea(
          child: ValueListenableBuilder(
              valueListenable: ScreenHome.selectedIndex,
              builder: (BuildContext context, int newIndex, _) {
                return page[newIndex];
              })),
    );
  }
}

class ScreenCancelledOrders {
  const ScreenCancelledOrders();
}

class ScreenCompletedOrders {
  const ScreenCompletedOrders();
}

class ScreenOnGoingOrders {
  const ScreenOnGoingOrders();
}
