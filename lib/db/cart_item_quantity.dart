import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartItemQuantity {
  CartItemQuantity._internal();
  static CartItemQuantity instance = CartItemQuantity._internal();
  factory CartItemQuantity() {
    return CartItemQuantity.instance;
  }

  Future<int> getCartItemQuantity() async {
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
    } catch (e)
    // ignore: empty_catches
    {}
    return counter;
  }
}
