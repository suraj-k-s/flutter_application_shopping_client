// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_shopping_client/screens/orders.dart';
import 'package:sticky_footer_scrollview/sticky_footer_scrollview.dart';
import 'package:flutter_application_shopping_client/widgets/sucess_easy.dart';

class ScreenCheckoutBottom extends StatefulWidget {
  final String addressId;
  const ScreenCheckoutBottom({
    Key? key,
    required this.addressId,
  }) : super(key: key);

  @override
  State<ScreenCheckoutBottom> createState() => _ScreenCheckoutBottomState();
}

class _ScreenCheckoutBottomState extends State<ScreenCheckoutBottom> {
  String? customerId = '';
  String? bookingId = '';
  @override
  void initState() {
    super.initState();
  }

  Future<void> placeOrder() async {
    ScreenLoader().screenLoaderSuccessFailStart();
    String itemStock = '0';
    try {
      final user = FirebaseAuth.instance.currentUser;
      customerId = user?.uid.toString();
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('bookings')
              .where('user_id', isEqualTo: customerId)
              .get();

      for (var doc in querySnapshot.docs) {
        bookingId = doc.id;
      }
      final userDoc =
          FirebaseFirestore.instance.collection('bookings').doc(bookingId);
      await userDoc.update({'address_id': widget.addressId, 'status': '1'});
      querySnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('booking_id', isEqualTo: bookingId)
          .get();
      for (var doc in querySnapshot.docs) {
        final userDoc =
            FirebaseFirestore.instance.collection('cart').doc(doc.id);
        await userDoc.update({'cart_status': '1'});
      }
      for (var doc in querySnapshot.docs) {
        final itemData =
            FirebaseFirestore.instance.collection('items').doc(doc['item_id']);
        itemData.get().then((documentSnapshot) async {
          final userData = documentSnapshot.data();
          itemStock = userData!['quantity'].toString();
          final userDoc = FirebaseFirestore.instance
              .collection('items')
              .doc(doc['item_id']);
          userDoc.update(
              {'quantity': int.parse(itemStock) - int.parse(doc['quantity'])});
        });
      }
      // ignore: use_build_context_synchronously
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (ctx) => const ScreenOrders()));
      ScreenLoader()
          .screenLoaderDismiss('1', 'Your Order Has been place Successfully!');
    } catch (e) {
      ScreenLoader().screenLoaderDismiss('2', 'OOps. Something went wrong. $e');
    }
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
            title: Center(
              child: ElevatedButton(
                  onPressed: () {
                    if (widget.addressId == '') {
                      ScreenLoader().screenLoaderDismiss(
                          '0', 'Please select an address to continue');
                    } else {
                      placeOrder();
                    }
                  },
                  child: const Text('Place Order')),
            ),
          )),
    );
  }
}
