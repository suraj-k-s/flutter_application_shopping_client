import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_shopping_client/screens/item_display.dart';
import 'package:flutter_application_shopping_client/widgets/appbar.dart';
import 'package:flutter_application_shopping_client/widgets/sucess_easy.dart';
import 'package:timeline_tile/timeline_tile.dart';
// ignore: depend_on_referenced_packages

class ScreenOrderDetails extends StatefulWidget {
  final bookingId;
  const ScreenOrderDetails({super.key, required this.bookingId});

  @override
  State<ScreenOrderDetails> createState() => _ScreenOrderDetailsState();
}

class _ScreenOrderDetailsState extends State<ScreenOrderDetails> {
  String deliveryStatus = '';
  String cartQuantity = '';
  final db = FirebaseFirestore.instance;
  String? customerId = '';
  String bookingId = '';
  String userId = '';
  int cartTotal = 0;
  bool orderReceived = false;
  bool itemPacked = false;
  bool itemShipped = false;
  bool itemTransit = false;
  bool outForDelivery = false;
  bool delivered = false;
  bool orderCancelled = false;
  final quantityController = TextEditingController();
  List<Map<String, dynamic>> cartItems = [];
  @override
  void initState() {
    getCartItems();

    super.initState();
  }

  Future<void> getCartItems() async {
    int cartTotalValue = 0;
    bookingId = '';
    try {
      List<Map<String, dynamic>> cart = [];
      final user = FirebaseAuth.instance.currentUser;
      customerId = user?.uid.toString();

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('cart')
              .where('booking_id', isEqualTo: widget.bookingId)
              .where('cart_status',
                  whereIn: ['1', '2', '3', '4', '5', '6', '7']).get();

      for (var doc in querySnapshot.docs) {
        try {
          Map<String, dynamic>? itemData = await getItemDetails(doc['item_id']);
          if (itemData != null) {
            cart.add({
              'id': doc.id,
              'booking_id': doc['booking_id'],
              'cart_status': doc['cart_status'],
              'date': doc['date'],
              'item_id': doc['item_id'],
              'quantity': doc['quantity'],
              'item_name': itemData['item_name'],
              'unit_rate': itemData['unit_rate'],
              'imageUrl': itemData['imageUrl']
            });
          }
         
          cartTotalValue +=
              int.parse(doc['quantity']) * int.parse(itemData?['unit_rate']);
        } catch (e)
        // ignore: empty_catches
        {}

        setState(() {
          cartItems = cart;
        });
      }
      setState(() {
        cartTotal = cartTotalValue;
      });
    } catch (e) {
      ScreenLoader().screenLoaderDismiss('0', 'Oops.Something went wrong $e');
    }
  }

  Future<Map<String, dynamic>?> getItemDetails(String itemId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('items')
          .doc(itemId)
          .get();
      if (docSnapshot.exists) {
        final itemName = docSnapshot.data()?['item_name'];
        final unitRate = docSnapshot.data()?['unit_rate'];
        final imageUrl = docSnapshot.data()?['imageUrl'];
        return {
          'item_name': itemName,
          'unit_rate': unitRate,
          'imageUrl': imageUrl
        };
      } else {
        return null;
      }
    } catch (e) {
      ScreenLoader().screenLoaderDismiss('0', 'Oops Something went wrong $e');
    }
    return null;
  }

  

  Future<void> deleteItemOrder(String docId) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('cart').doc(docId);
      await userDoc.update({'cart_status': '7'});
       getCartItems();
      setState(() {
        deliveryStatus='7';
      });
      ScreenLoader().screenLoaderDismiss('1', 'This order is cancelled');
     
    } catch (e) {
      ScreenLoader().screenLoaderDismiss('2', 'Oops. Something went wrong $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const ScreenAppBar(appHeading: 'Order Summary'),
        body: ListView(
          children: [
            Column(
              children: [
                cartTotal == 0
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        height: 900,
                        child: ListView.separated(
                            itemBuilder: (ctx, index) {
                              final Map<String, dynamic> data =
                                  cartItems[index];
                                deliveryStatus=data['cart_status'];
                              return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (ctx) => ScreenItemDisplay(
                                                itemId: data['item_id'])));
                                  },
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: Image(
                                          image: data['imageUrl'] == null
                                              ? const AssetImage(
                                                      'assets/loading.gif')
                                                  as ImageProvider
                                              : NetworkImage(data['imageUrl']),
                                        ),
                                        title: Row(
                                          children: [
                                            Text(data['item_name']),
                                            Text(
                                              '  \u{20B9}${data['unit_rate']}',
                                              style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 18),
                                            ),
                                          ],
                                        ),
                                        subtitle: Row(
                                          children: [
                                            Text('Qty- ${data['quantity']}'),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20),
                                              child: Text(
                                                deliveryStatus == '7'
                                                    ? 'Order Cancelled'
                                                    : (deliveryStatus ==
                                                            '1'
                                                        ? 'Order Received'
                                                        : (deliveryStatus ==
                                                                '2'
                                                            ? 'Item Packed'
                                                            : (deliveryStatus ==
                                                                    '3'
                                                                ? 'Item Picked'
                                                                : (deliveryStatus ==
                                                                        '4'
                                                                    ? 'In Transit'
                                                                    : (deliveryStatus ==
                                                                            '5'
                                                                        ? 'Out for Delivery'
                                                                        : 'Delivered'))))),
                                                style: const TextStyle(
                                                    color: Colors.indigo),
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: Visibility(
                                          visible: deliveryStatus == '7'
                                              ? false
                                              : true,
                                          child: IconButton(
                                              onPressed: () {
                                                if(deliveryStatus=='7')
                                                {
                                                  print('no');
                                                }
                                                else
                                                {
                                                  showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title:
                                                          const Text('Alert'),
                                                      content: const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 20),
                                                        child: Text(
                                                          'Do you want to delete this order',
                                                          style: TextStyle(
                                                              color: Colors.red,
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child:
                                                              const Text('No'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            ScreenLoader()
                                                                .screenLoaderSuccessFailStart();
                                                            deleteItemOrder(
                                                                data['id']);
                                                                 print(deliveryStatus);
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child:
                                                              const Text('Yes'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                                }
                                              },
                                              tooltip: 'Slide for actions',
                                              icon: const Icon(Icons.delete)),
                                        ),
                                      ),
                                    ],
                                  ));
                            },
                            separatorBuilder: (ctx, index) {
                              return const Divider();
                            },
                            itemCount: cartItems.length),
                      ),
              ],
            ),
          ],
        ));
  }
}
