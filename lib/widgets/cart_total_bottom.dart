import 'package:flutter/material.dart';
import 'package:flutter_application_shopping_client/screens/address.dart';
import 'package:flutter_application_shopping_client/widgets/sucess_easy.dart';
import 'package:sticky_footer_scrollview/sticky_footer_scrollview.dart';

class ScreenCartBottomBar extends StatefulWidget {
  final int cartTotal;
  const ScreenCartBottomBar({super.key, required this.cartTotal});

  @override
  State<ScreenCartBottomBar> createState() => _ScreenCartBottomBarState();
}

class _ScreenCartBottomBarState extends State<ScreenCartBottomBar> {

  @override
  void initState() {
    super.initState();
  
  
  }
  @override
  Widget build(BuildContext context) {
    return SizedBox(
              height: 70,
              child: StickyFooterScrollView(
                  itemCount: 0,
                  itemBuilder: (context, index) {
                    return const Text('');
                  },
                  footer: AppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.indigo,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: Text(
                            widget.cartTotal>0?'Cart Total ':'Empty Cart',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        Text(
                         widget.cartTotal==0?'':'  \u{20B9}${widget.cartTotal}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 23),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: widget.cartTotal==0?Text(''):ElevatedButton(
                              onPressed: () {
                               ScreenLoader().screenLoaderSuccessFailStart();
                               Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>const ScreenAddress()));
                               ScreenLoader().screenLoaderDismiss('2', '');
                              }, child: const Text('Place Order')),
                        )
                      ],
                    ),
                  )),
            );
  }
}