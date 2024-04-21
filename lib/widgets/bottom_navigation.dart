import 'package:flutter/material.dart';
import 'package:flutter_application_shopping_client/screens/orders.dart';
import 'package:flutter_application_shopping_client/screens/screen_home.dart';
import 'package:flutter_application_shopping_client/screens/serach.dart';
import 'package:flutter_application_shopping_client/widgets/sucess_easy.dart';

class BottomNavigation extends StatefulWidget {
 
   BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  @override
 
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ScreenHome.selectedIndex,
      builder: (BuildContext context, int updateIndex, Widget? _) {
        return BottomNavigationBar(
            selectedItemColor: Colors.purple,
            unselectedItemColor: Colors.grey,
            currentIndex: updateIndex,
            onTap: (newIndex) {
              ScreenHome.selectedIndex.value = newIndex;
            },
            // ignore: prefer_const_literals_to_create_immutables
            items: [
              BottomNavigationBarItem(
                  icon: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.green,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: IconButton(
                          onPressed: () {
                            ScreenLoader().screenLoaderSuccessFailStart();

                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) => const ScreenSearch()));
                            ScreenLoader().screenLoaderDismiss('2', '');
                          }, icon: const Icon(Icons.search))),
                  label: 'Search'),
              BottomNavigationBarItem(
                  icon: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.pink,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: IconButton(
                          onPressed: () {
                            ScreenLoader().screenLoaderSuccessFailStart();

                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) => const ScreenOrders()));
                            ScreenLoader().screenLoaderDismiss('2', '');
                          },
                          icon: const Icon(
                              Icons.shopping_bag_sharp))),
                  label: 'Orders'),
               BottomNavigationBarItem(
                  icon: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.pink,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: IconButton(
                          onPressed: () {
                            ScreenLoader().screenLoaderSuccessFailStart();

                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) => const ScreenOrders()));
                            ScreenLoader().screenLoaderDismiss('2', '');
                          },
                          icon: const Icon(
                              Icons.published_with_changes_rounded))),
                  label: 'Orders'),
            ]);
      },
    );
  }
}
