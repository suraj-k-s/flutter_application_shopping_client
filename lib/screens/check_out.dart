import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_shopping_client/screens/screen_login.dart';
import 'package:flutter_application_shopping_client/widgets/sucess_easy.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sticky_footer_scrollview/sticky_footer_scrollview.dart';

class ScreenCheckOut extends StatefulWidget {
  const ScreenCheckOut({super.key});

  @override
  State<ScreenCheckOut> createState() => _ScreenCheckOutState();
}

class _ScreenCheckOutState extends State<ScreenCheckOut> {
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
            cartTotal = cartTotalValue;
          });
        }
      }
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
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white, //change your color here
          ),
          backgroundColor: Colors.indigo,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text('Order Summary',
                  style: TextStyle(color: Colors.white)),
              const SizedBox(
                width: 40,
              ),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.doorbell_outlined,
                    color: Colors.white,
                  )),
              Stack(
                children: <Widget>[
                  IconButton(
                      onPressed: () {
                        ScreenLoader().screenLoaderSuccessFailStart();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => const ScreenCheckOut()));
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
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
        body: ListView(
          children: [
            SizedBox(
              height: 430,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                        itemBuilder: (ctx, index) {
                          final Map<String, dynamic> data = cartItems[index];
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
                                                        data['id'], bookingId);

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
                                                padding: const EdgeInsets.only(
                                                    left: 30,
                                                    right: 30,
                                                    top: 15),
                                                child: TextFormField(
                                                    controller:
                                                        quantityController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Stock cannot be empty!';
                                                      } else {
                                                        return null;
                                                      }
                                                    },
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          "Quantity Value",
                                                      fillColor: Colors.blue,
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25.0),
                                                        borderSide:
                                                            const BorderSide(),
                                                      ),
                                                    )),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .pop();
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    if (quantityController
                                                            .text ==
                                                        '0') {
                                                      Navigator.pop(context);
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                                'Do you really want to delete this item from the cart'),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
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
                                                                child:
                                                                    const Text(
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
                                                  child: const Text('Update'),
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
                              child: ListTile(
                                leading: Image(
                                  image: data['imageUrl'] == null
                                      ? const AssetImage('assets/loading.gif')
                                          as ImageProvider
                                      : NetworkImage(data['imageUrl']),
                                ),
                                title: Row(
                                  children: [
                                    Text(data['item_name']),
                                    Text(
                                      '  \u{20B9}${data['unit_rate']}',
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 18),
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
                              ));
                        },
                        separatorBuilder: (ctx, index) {
                          return const Divider();
                        },
                        itemCount: cartItems.length),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 385,
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
                        const Padding(
                          padding: EdgeInsets.only(left: 60),
                          child: Text(
                            'Cart Total ',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Text(
                          '  \u{20B9}$cartTotal',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 23),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 35),
                          child: ElevatedButton(
                              onPressed: () {}, child: const Text('Check Out')),
                        )
                      ],
                    ),
                  )),
            )
          ],
        ));
  }
}
