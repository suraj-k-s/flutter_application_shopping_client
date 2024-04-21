import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_shopping_client/screens/item_display.dart';
import 'package:flutter_application_shopping_client/widgets/sucess_easy.dart';

class ScreenSearch extends StatefulWidget {
  const ScreenSearch({super.key});

  @override
  State<ScreenSearch> createState() => _ScreenSearchState();
}

class _ScreenSearchState extends State<ScreenSearch> {
  final searchController = TextEditingController();
  List<Map<String, dynamic>> itemsList = [];
  String searchItem = '';
  String cartQuantity = '';
  @override
  void initState() {
    searchItem = '';
    getCartQunatity();
    super.initState();
  }

  void gotoItem(String itemId) {
    ScreenLoader().screenLoaderSuccessFailStart();
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => ScreenItemDisplay(
              itemId: itemId,
            )));
    ScreenLoader().screenLoaderDismiss('2', '');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchDataStream() {
    if (searchItem == '') {
      Query<Map<String, dynamic>> collection = FirebaseFirestore.instance
          .collection('items')
          .orderBy('item_lower_case', descending: false);

      return collection.snapshots();
    } else {
      Query<Map<String, dynamic>> collection = FirebaseFirestore.instance
          .collection('items')
          .where('item_lower_case', isGreaterThanOrEqualTo: searchItem)
          .where('item_lower_case', isLessThan: '${searchItem}z')
          .orderBy('item_lower_case', descending: false);

      return collection.snapshots();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        // backgroundColor: Colors.grey[200],
        body: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
                child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        searchItem = searchController.text;
                      });
                    },
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: "Search your items here",
                      fillColor: Colors.blue,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: const BorderSide(),
                      ),
                    )),
              ),
            ),
          ],
        ),
        const Divider(
          thickness: 2,
        ),
        Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: fetchDataStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // return CircularProgressIndicator();
                  }
                  if (snapshot.data != null) {
                    List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

                    return GridView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // number of items in each row
                          mainAxisSpacing: 8.0, // spacing between rows
                          crossAxisSpacing: 8.0, // spacing between columns
                        ),
                        padding: const EdgeInsets.all(
                            8.0), // padding around the grid
                        itemCount: documents.length,
                        itemBuilder: (ctx, index) {
                          final documentId = snapshot.data!.docs[index].id;
                          var data =
                              documents[index].data() as Map<String, dynamic>;

                          return GestureDetector(
                            onTap: () => gotoItem(documentId),
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.red,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20))),
                              child: Center(
                                child: Column(
                                  children: [
                                    Image(
                                      image: NetworkImage(data['imageUrl']),
                                      height: 120,
                                      width: 150,
                                    ),
                                    Text(
                                      data['item_name'],
                                      // ignore: prefer_const_constructors
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 23,
                                          color: Colors.blue),
                                    ),
                                    Container(
                                        width: 100,
                                        decoration: const BoxDecoration(
                                            color: Colors.purple,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        child: Center(
                                          child: Text(
                                            data['unit_rate'],
                                            // ignore: prefer_const_constructors
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  } else {
                    return const Text('');
                  }
                })),
      ],
    ));
  }
}
