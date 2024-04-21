import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_shopping_client/widgets/appbar.dart';
import 'package:flutter_application_shopping_client/widgets/checkout_bottom.dart';
import 'package:flutter_application_shopping_client/widgets/sucess_easy.dart';

class ScreenAddress extends StatefulWidget {
  const ScreenAddress({super.key});

  @override
  State<ScreenAddress> createState() => _ScreenAddressState();
}

class _ScreenAddressState extends State<ScreenAddress> {
  final searchController = TextEditingController();
  List<Map<String, dynamic>> itemsList = [];
  String searchItem = '';
  bool itemVisibility = false;
  final _formKey = GlobalKey<FormState>();
  final addressController = TextEditingController();
  String currentAddress = '';
  @override
  void initState() {
    searchItem = '';

    super.initState();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchDataStream() {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    Query<Map<String, dynamic>> collection = FirebaseFirestore.instance
        .collection('address')
        .where('user_id', isEqualTo: userId);

    return collection.snapshots();
  }

  Future<void> addAddress() async {
    try {
      ScreenLoader().screenLoaderSuccessFailStart();
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('address').add({
        'user_id': userId,
        'address': addressController.text,
      });
      setState(() {
        addressController.text = '';
      });

      ScreenLoader().screenLoaderDismiss('1', 'Address Added');
    } catch (e) {
      ScreenLoader().screenLoaderDismiss('2', 'Oops. Something went wrong $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const ScreenAppBar(appHeading: 'Adress'),
        floatingActionButton: Visibility(
          visible: !itemVisibility,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                itemVisibility = true;
              });
            },
            tooltip: 'Add Address',
            // ignore: sort_child_properties_last
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            backgroundColor: Colors.indigo,
          ),
        ),
        bottomNavigationBar: ScreenCheckoutBottom(addressId: currentAddress),
        body: Column(
          children: [
            const Text(
              'Choose the Delivery Address',
              style: TextStyle(color: Colors.indigo, fontSize: 25),
            ),
            const Divider(),
            Form(
              key: _formKey,
              child: Visibility(
                visible: itemVisibility,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: TextFormField(
                          controller: addressController,
                          maxLines: 7,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter a valid adress!';
                            } else {
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                            labelText: "Address",
                            fillColor: Colors.blue,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: const BorderSide(),
                            ),
                          )),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              setState(() {
                                itemVisibility = false;
                              });
                            },
                            child: const Text('Cancel')),
                        const SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                addAddress();
                              }
                            },
                            child: const Text('Add New Address')),
                      ],
                    ),
                    const Divider()
                  ],
                ),
              ),
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
                        List<QueryDocumentSnapshot> documents =
                            snapshot.data!.docs;

                        return ListView.separated(
                            itemBuilder: (ctx, index) {
                              final documentId = snapshot.data!.docs[index].id;
                              var data = documents[index].data()
                                  as Map<String, dynamic>;
                              return ListTile(
                                title: Text(data['address']),
                                trailing: Radio(
                                  value: documentId,
                                  groupValue: currentAddress,
                                  onChanged: (value) {
                                    setState(() {
                                      currentAddress = documentId;
                                    });
                                  },
                                ),
                              );
                            },
                            separatorBuilder: (ctx, index) {
                              return const Divider();
                            },
                            itemCount: documents.length);
                      } else {
                        return const Text('');
                      }
                    })),
          ],
        ));
  }
}
