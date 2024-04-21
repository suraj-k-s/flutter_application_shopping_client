import 'package:flutter/material.dart';
import 'package:flutter_application_shopping_client/db/cart_item_quantity.dart';
import 'package:flutter_application_shopping_client/screens/cart_display.dart';
import 'package:flutter_application_shopping_client/screens/screen_home.dart';
import 'package:flutter_application_shopping_client/screens/screen_login.dart';
import 'package:flutter_application_shopping_client/widgets/sucess_easy.dart';

class ScreenAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String appHeading;
  const ScreenAppBar({super.key, required this.appHeading});

  @override
  State<ScreenAppBar> createState() => _ScreenAppBarState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(50);
}

class _ScreenAppBarState extends State<ScreenAppBar> {
  String cartQuantity = '';

  Future<void> getCartQuantity() async {
    int quantity = await CartItemQuantity().getCartItemQuantity();
    setState(() {
      cartQuantity = quantity.toString();
    });
  }

  @override
  void initState() {
    super.initState();
    getCartQuantity(); // Call getCartQuantity here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
        backgroundColor: Colors.indigo,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(widget.appHeading,
                style: const TextStyle(color: Colors.white)),
            const SizedBox(
              width: 40,
            ),
            IconButton(
                onPressed: () {
                  ScreenLoader().screenLoaderSuccessFailStart();
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const ScreenHome()));
                  ScreenLoader().screenLoaderDismiss('2', '');
                },
                icon: const Icon(
                  Icons.home,
                  color: Colors.white,
                )),
            Stack(
              children: <Widget>[
                IconButton(
                    onPressed: () {
                      ScreenLoader().screenLoaderSuccessFailStart();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => const ScreenCartDisplay()));
                      ScreenLoader().screenLoaderDismiss('2', '');
                    },
                    icon: const Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                    )),
                Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red[400],
                    ),
                    child: Text(cartQuantity,
                        style: const TextStyle(color: Colors.white))),
              ],
            ),
            IconButton(
                onPressed: () {
                  final snackBar = SnackBar(
                    backgroundColor: Colors.indigo,
                    content: const Text(
                      'Are you sure?',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    action: SnackBarAction(
                      label: 'Yes. Exit the app',
                      onPressed: () {
                        ScreenLoader().screenLoaderSuccessFailStart();
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const ScreenLogin()),
                            (Route<dynamic> route) => false);
                        ScreenLoader().screenLoaderDismiss('2', '');
                      },
                    ),
                  );

                  // Find the ScaffoldMessenger in the widget tree
                  // and use it to show a SnackBar.
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                icon: const Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                ))
          ],
        ),
      ),
    );
  }
}
