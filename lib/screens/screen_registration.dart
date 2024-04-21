import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_shopping_client/widgets/sucess_easy.dart';

class ScreenRegistration extends StatefulWidget {
  const ScreenRegistration({super.key});

  @override
  State<ScreenRegistration> createState() => _ScreenRegistrationState();
}

class _ScreenRegistrationState extends State<ScreenRegistration> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController cpassController = TextEditingController();
  TextEditingController mobController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
        backgroundColor: Colors.purple,
        title: const Text(
          'Create an Account',
          style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ),
      body: Form(
          key: _formKey,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 15),
                child: TextFormField(
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a valid emial adress!';
                      } else if (!RegExp(
                              r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email address';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      labelText: "Email",
                      fillColor: Colors.blue,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: const BorderSide(),
                      ),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 15),
                child: TextFormField(
                    controller: passController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password Cannot be empty!';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      labelText: "Password",
                      fillColor: Colors.blue,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: const BorderSide(),
                      ),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 15),
                child: TextFormField(
                    controller: cpassController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password cannot be empty!';
                      } else {
                        return null;
                      }
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      fillColor: Colors.blue,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: const BorderSide(),
                      ),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 15),
                child: TextFormField(
                    controller: mobController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a valid Mobile Number!';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      labelText: "Mobile Number",
                      fillColor: Colors.blue,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: const BorderSide(),
                      ),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.indigo,
                            fixedSize: const Size(125, 50),
                            textStyle: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        child: const Text('Cancel')),
                    const SizedBox(
                      width: 30,
                    ),
                    TextButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            registerUser();
                          }
                        },
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.indigo,
                            fixedSize: const Size(125, 50),
                            textStyle: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                        child: const Text('Signup'))
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Future<void> registerUser() async {
    try {
      ScreenLoader().screenLoaderSuccessFailStart();
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passController.text,
      );
      await addUserData(userCredential.user!.uid);
    } catch (e) {
      ScreenLoader().screenLoaderDismiss('0', 'Oops. Something went wrong! $e');
    }
  }

  Future<void> addUserData(String userId) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('users_client').doc(userId).set({
        'email': emailController.text,
        'password': passController.text,
        'mobile': mobController.text
        // Add more fields as needed
      });
      ScreenLoader()
          .screenLoaderDismiss('1', 'Hey! You are successfully registered!');
    } catch (e) {
      ScreenLoader().screenLoaderDismiss('0', 'Oops. Something went wrong. $e');
    }
  }
}
