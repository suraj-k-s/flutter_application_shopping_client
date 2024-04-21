import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_shopping_client/screens/item_display.dart';
import 'package:flutter_application_shopping_client/screens/screen_home.dart';
import 'package:flutter_application_shopping_client/widgets/appbar.dart';
import 'package:flutter_application_shopping_client/widgets/cart_total_bottom.dart';
import 'package:flutter_application_shopping_client/widgets/sucess_easy.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_slidable/flutter_slidable.dart';

class ScreenCartDisplay extends StatefulWidget {
  const ScreenCartDisplay({super.key});

  @override
  State<ScreenCartDisplay> createState() => _ScreenCartDisplayState();
}

class _ScreenCartDisplayState extends State<ScreenCartDisplay> {
  String cartQuantity = '';
  final db = FirebaseFirestore.instance;
  String? customerId = '';
  String bookingId = '';
  String userId = '';
  int cartTotal = 0;
  final quantityController = TextEditingController();
  List<Map<String, dynamic>> cartItems = [];
  @override
  void initState() {
    getCartItems();
    getCartQunatity();
    super.initState();
  }

  void getCartQunatity() async {
    final user = FirebaseAuth.instance.currentUser;
    userId = user!.uid;
    String docId = '';
    int counter = 0;
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('bookings')
              .where('user_id', isEqualTo: userId)
              .get();
      for (var doc in querySnapshot.docs) {
        docId = doc.id;
      }
      querySnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('booking_id', isEqualTo: docId)
          .where('cart_status', isEqualTo: '0')
          .get();
      // ignore: unused_local_variable
      for (var doc in querySnapshot.docs) {
        counter++;
      }
      setState(() {
        cartQuantity = counter.toString();
      });
    } catch (e)
    // ignore: empty_catches
    {}
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
              .collection('bookings')
              .where('user_id', isEqualTo: customerId)
              .where('status', isEqualTo: '0')
              .get();

      for (var doc in querySnapshot.docs) {
        bookingId = doc.id;
      }

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          cartItems.clear();
        });
      } else {
        querySnapshot = await FirebaseFirestore.instance
            .collection('cart')
            .where('booking_id', isEqualTo: bookingId)
            .where('cart_status', isEqualTo: '0')
            .get();

        for (var doc in querySnapshot.docs) {
          try {
            Map<String, dynamic>? itemData =
                await getItemDetails(doc['item_id']);
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

  Future<void> deleteCart(String cartId, String bookingId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('cart')
              .where('booking_id', isEqualTo: bookingId)
              .get();
      if (querySnapshot.docs.isNotEmpty) {
        if (querySnapshot.docs.length == 1) {
          //only one item left in the cart with this booking id, so delete it from cart and delete the booking entry too
          await db.collection('cart').doc(cartId).delete();
          await db.collection('bookings').doc(bookingId).delete();
        } else {
          // more than one item found in cart. so delete the single entry
          await db.collection('cart').doc(cartId).delete().then((_) {});
        }
        await getCartItems();
        getCartQunatity();
        ScreenLoader().screenLoaderDismiss('1', 'Item removed from the cart');
      }
    } catch (e) {
      ScreenLoader().screenLoaderDismiss('0', 'Oops. Something went wrong $e');
    }
  }

  Future<void> updateCartItemQuantity(String cartId) async {
    int updatedqty = 0;
    final itemData = FirebaseFirestore.instance.collection('cart').doc(cartId);
    final documentSnapshot = await itemData.get();
    if (documentSnapshot.exists) {
      updatedqty = int.parse(quantityController.text);
      Map<String, dynamic> newItem = {'quantity': updatedqty.toString()};
      try {
        db.collection('cart').doc(cartId).update(newItem).then((_) {});
        setState(() {
          quantityController.text = '0';
        });
        getCartItems();
        ScreenLoader()
            .screenLoaderDismiss('1', 'Item quantity is updated in the cart');
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } catch (e) {
        ScreenLoader()
            .screenLoaderDismiss('0', 'Oops. Something went wrong $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const ScreenAppBar(appHeading: 'Cart'),
        bottomNavigationBar: ScreenCartBottomBar(cartTotal: cartTotal),
        body: ListView(
          children: [
            Column(
              children: [
                cartTotal == 0
                    ? Column(
                        children: [
                          const Image(
                              image: AssetImage('assets/empty_cart.png')),
                          const SizedBox(
                            height: 30,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                ScreenLoader().screenLoaderSuccessFailStart();
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) => const ScreenHome()));
                                ScreenLoader().screenLoaderDismiss('2', '');
                              },
                              child: const Text('Continue Shopping'))
                        ],
                      )
                    : SizedBox(
                        height: 900,
                        child: ListView.separated(
                            itemBuilder: (ctx, index) {
                              final Map<String, dynamic> data =
                                  cartItems[index];
                              return Slidable(
                                  key: Key(data['id']),
                                  startActionPane: ActionPane(
                                      motion: const ScrollMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (ctx) {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Do you want to delete this item from the cart'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text('No'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        ScreenLoader()
                                                            .screenLoaderSuccessFailStart();
                                                        await deleteCart(
                                                            data['id'],
                                                            bookingId);

                                                        // ignore: use_build_context_synchronously
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text('Yes'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          icon: Icons.delete,
                                          label: 'Delete',
                                        ),
                                        SlidableAction(
                                          onPressed: (ctx) {
                                            String itemName = data['item_name'];
                                            setState(() {
                                              quantityController.text =
                                                  data['quantity'];
                                            });
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text(
                                                      'Do you want to update the quantity of $itemName?'),
                                                  content: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 30,
                                                            right: 30,
                                                            top: 15),
                                                    child: TextFormField(
                                                        controller:
                                                            quantityController,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Stock cannot be empty!';
                                                          } else {
                                                            return null;
                                                          }
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          labelText:
                                                              "Quantity Value",
                                                          fillColor:
                                                              Colors.blue,
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        25.0),
                                                            borderSide:
                                                                const BorderSide(),
                                                          ),
                                                        )),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context,
                                                                rootNavigator:
                                                                    true)
                                                            .pop();
                                                      },
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        if (quantityController
                                                                .text ==
                                                            '0') {
                                                          Navigator.pop(
                                                              context);
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                title: const Text(
                                                                    'Do you really want to delete this item from the cart'),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                            'No'),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed:
                                                                        () async {
                                                                      ScreenLoader()
                                                                          .screenLoaderSuccessFailStart();
                                                                      await deleteCart(
                                                                          data[
                                                                              'id'],
                                                                          bookingId);

                                                                      // ignore: use_build_context_synchronously
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child: const Text(
                                                                        'Yes'),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        } else {
                                                          ScreenLoader()
                                                              .screenLoaderSuccessFailStart();
                                                          updateCartItemQuantity(
                                                              data['id']);
                                                        }
                                                      },
                                                      child:
                                                          const Text('Update'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          icon: Icons.update,
                                          label: 'Update',
                                        )
                                      ]),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (ctx) =>
                                                  ScreenItemDisplay(
                                                      itemId:
                                                          data['item_id'])));
                                    },
                                    child: ListTile(
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
                                          //Text(data['quantity']),
                                          Text(data['quantity'])
                                        ],
                                      ),
                                      trailing: IconButton(
                                          onPressed: () {},
                                          tooltip: 'Slide for actions',
                                          icon: const Icon(
                                              Icons.double_arrow_outlined)),
                                    ),
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
