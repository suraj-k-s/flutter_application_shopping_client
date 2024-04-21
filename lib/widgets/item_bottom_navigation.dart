import 'package:flutter/material.dart';
import 'package:flutter_application_shopping_client/screens/orders.dart';

import 'package:flutter_application_shopping_client/screens/screen_home.dart';
import 'package:flutter_application_shopping_client/widgets/sucess_easy.dart';

// ignore: must_be_immutable
class ItemBottomNavigationBar extends StatefulWidget {
  String userId='';
  String itemId='';
   ItemBottomNavigationBar({super.key,required this.userId, required this.itemId});

  @override
  State<ItemBottomNavigationBar> createState() => _ItemBottomNavigationBarState();
}

class _ItemBottomNavigationBarState extends State<ItemBottomNavigationBar> {
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
                      color: Colors.purple,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                    child: IconButton(onPressed: (){
                 
                    }, icon: const Icon(Icons.shopping_cart_checkout))
                  ),
                  label: 'Add to Cart'),
               BottomNavigationBarItem(
                  icon: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.green,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                    child: IconButton(onPressed: (){}, icon: const Icon(Icons.shopping_bag))
                  ), label: 'Pay with EMI'),
               BottomNavigationBarItem(
                  icon: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.pink,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                    child: IconButton(onPressed: (){
                      ScreenLoader().screenLoaderSuccessFailStart();
                     
                      Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>const ScreenOrders()));
                      ScreenLoader().screenLoaderDismiss('2', '');
                    }, icon: const Icon(Icons.published_with_changes_rounded))
                  ), label: 'Orders'),
            ]);
      },
    );
  }
}
