// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_shopping_client/widgets/appbar.dart';
import 'package:flutter_application_shopping_client/widgets/item_bottom_navigation.dart';
import 'package:flutter_application_shopping_client/widgets/sucess_easy.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

// ignore: must_be_immutable
class ScreenItemDisplay extends StatefulWidget {
  String itemId;

  ScreenItemDisplay({
    Key? key,
    required this.itemId,
  }) : super(key: key);

  @override
  State<ScreenItemDisplay> createState() => _ScreenItemDisplayState();
}

class _ScreenItemDisplayState extends State<ScreenItemDisplay> {
  var userId = '';
  String cartQuantity = '';
  final db = FirebaseFirestore.instance;
  String hsn = 'Loading';
  String imageUrl = '';
  String itemName = 'Loading';
  String unitRate = 'Loading';
  final quantityController = TextEditingController();
  String itemStock = '';

  @override
  void initState() {
    getItemDetails(widget.itemId);

    super.initState();
  }

  void getCartQunatity() async {
    final user = FirebaseAuth.instance.currentUser;
    String userId = user!.uid;
    String docId = '';
    int counter = 0;
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('bookings')
              .where('user_id', isEqualTo: userId)
              .where('status', isEqualTo: '0')
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

  Future<void> getItemDetails(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    userId = user!.uid;
    final userDoc = FirebaseFirestore.instance.collection('items').doc(id);
    userDoc.get().then((documentSnapshot) {
      if (documentSnapshot.exists) {
        final itemData = documentSnapshot.data();

        setState(() {
          hsn = itemData?['hsn'];
          imageUrl = itemData?['imageUrl'];
          itemName = itemData?['item_name'];
          unitRate = itemData?['unit_rate'];
          itemStock = itemData!['quantity'].toString();
        });
      }
    });
  }

  Future<void> addBooking(String userId, String itemId, String quantity) async {
    String docId = '';
    bool isAlreadyBooked = false;
    try {
      ScreenLoader().screenLoaderSuccessFailStart();
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('bookings')
              .where('user_id', isEqualTo: userId)
              .get();

      for (var doc in querySnapshot.docs) {
        if (doc['status'] == '0') {
          isAlreadyBooked = true;
          docId = doc.id;
        }
      }
      if (!isAlreadyBooked) {
        final df = DateFormat('dd-MM-yyyy');
        String bookingDate = '';
        bookingDate = df.format(DateTime.now());
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        DocumentReference itemRef = await firestore.collection('bookings').add({
          'date': bookingDate,
          'user_id': userId,
          'status': '0',

          // Add more fields as needed
        });

        docId = itemRef.id;
      }

      addCart(docId, itemId, quantity);
    } catch (e) {
      ScreenLoader().screenLoaderDismiss('0', 'Oops. Something went wrong $e');
    }
  }

  Future<void> addCart(String bookingId, String itemId, String quantity) async {
    bool isAlreadyCart = false;

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('cart')
              .where('booking_id', isEqualTo: bookingId)
              .get();
      for (var doc in querySnapshot.docs) {
        if (doc['item_id'] == itemId) {
          isAlreadyCart = true;
        }
      }
      if (isAlreadyCart) {
        ScreenLoader()
            .screenLoaderDismiss('0', 'This Item is already in the Cart!');
      } else {
        if (int.parse(itemStock) >= int.parse(quantity)) {
          final df = DateFormat('dd-MM-yyyy');
          String orderDate = '';
          orderDate = df.format(DateTime.now());
          final FirebaseFirestore firestore = FirebaseFirestore.instance;
          await firestore.collection('cart').add({
            'booking_id': bookingId,
            'date': orderDate.toString(),
            'item_id': itemId,
            'cart_status': '0',
            'quantity': quantity.toString()
            // Add more fields as needed
          });

          ScreenLoader().screenLoaderDismiss('1', 'Item is added to the cart');
        } else {
          ScreenLoader().screenLoaderDismiss('0',
              'Sorry, There is not enough quantity. Try with lesser quantity');
        }
      }
    } catch (e) {
      ScreenLoader().screenLoaderDismiss('0', 'Oops. Something went wrong $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ScreenAppBar(appHeading: 'Easy Buy'),
      bottomNavigationBar:
          ItemBottomNavigationBar(userId: userId, itemId: widget.itemId),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: ListView(
          children: [
            Image(
              image: imageUrl == ''
                  ? const AssetImage(
                      'assets/loading.gif',
                    ) as ImageProvider
                  : NetworkImage(
                      imageUrl,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                  child: Text(
                itemName,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ),
            const Divider(),
            const Center(
                child: Text(
              'MRP \u{20B9}55499',
              style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  fontFamily: 'Georgia',
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                  color: Colors.purple),
            )),
            Center(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GlowText(
                  'Special Price \u{20B9}$unitRate',
                  glowColor: Colors.yellow,
                  blurRadius: 10,
                  style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.bold,
                      fontSize: 23,
                      color: Colors.indigo),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.purple,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              quantityController.text = '1';
                            });
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Enter Quantity'),
                                  content: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 30, right: 30, top: 15),
                                    child: TextFormField(
                                        controller: quantityController,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Quantity cannot be empty!';
                                          } else {
                                            return null;
                                          }
                                        },
                                        decoration: InputDecoration(
                                          labelText: "Quantity",
                                          fillColor: Colors.blue,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            borderSide: const BorderSide(),
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
                                        addBooking(
                                          userId,
                                          widget.itemId,
                                          quantityController.text,
                                        );

                                        getCartQunatity();
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                      },
                                      child: const Text('Add To Cart'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.shopping_cart_checkout))),
                ),
              ],
            )),
            const Divider(),
            const Padding(
              padding: EdgeInsets.only(left: 30, top: 20),
              child: Text(
                'Product Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 30, top: 10),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_right_sharp),
                      Text('Sales Package'),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Laptop, Power Adaptor')
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30, top: 10),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_right_sharp),
                      Text('Model Number'),
                      SizedBox(
                        width: 10,
                      ),
                      Text('HeroBook Plus')
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30, top: 10),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_right_sharp),
                      Text('Part Number'),
                      SizedBox(
                        width: 10,
                      ),
                      Text('CWI629')
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30, top: 10),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_right_sharp),
                      Text('Model Name'),
                      SizedBox(
                        width: 10,
                      ),
                      Text('HeroBook Plus')
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30, top: 10),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_right_sharp),
                      Text('Color'),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Grey')
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.only(left: 30, top: 10),
              child: Text(
                'Ratings and Reviews',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      CircularPercentIndicator(
                        radius: 30.0,
                        lineWidth: 5.0,
                        percent: .8,
                        center: const Text("80%"),
                        progressColor: Colors.green,
                      ),
                      const Text(
                        'Performance',
                        style: TextStyle(color: Colors.green),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      CircularPercentIndicator(
                        radius: 30.0,
                        lineWidth: 5.0,
                        percent: .9,
                        center: const Text("90%"),
                        progressColor: Colors.pink,
                      ),
                      const Text(
                        'Battery',
                        style: TextStyle(color: Colors.pink),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      CircularPercentIndicator(
                        radius: 30.0,
                        lineWidth: 5.0,
                        percent: .72,
                        center: const Text("72%"),
                        progressColor: Colors.yellow,
                      ),
                      const Text(
                        'Design',
                        style: TextStyle(color: Colors.yellow),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      CircularPercentIndicator(
                        radius: 30.0,
                        lineWidth: 5.0,
                        percent: .88,
                        center: const Text("88%"),
                        progressColor: Colors.blue,
                      ),
                      const Text(
                        'Design',
                        style: TextStyle(color: Colors.blue),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
