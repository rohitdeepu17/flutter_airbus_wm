
import 'package:flutter/material.dart';
import 'package:airbus/components/rounded_button.dart';
import 'package:airbus/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:airbus/screens/chat_screen.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  String email = "";
  String password = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Hero(
              tag: 'logo',
              child: Container(
                height: 200.0,
                child: Image.asset('images/logo.png'),
              ),
            ),
            SizedBox(
              height: 48.0,
            ),
            TextField(
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
              onChanged: (value) {
                //Do something with the user input.
                email = value;
              },
              style: TextStyle(
                color: Colors.black
              ),
              decoration: kTextFieldDecoration.copyWith(hintText: 'Enter your email.'),
            ),
            SizedBox(
              height: 8.0,
            ),
            TextField(
              obscureText: true,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black
              ),
              onChanged: (value) {
                //Do something with the user input.
                password = value;
              },
              decoration: kTextFieldDecoration.copyWith(hintText: 'Enter your password'),
            ),
            SizedBox(
              height: 24.0,
            ),
            RoundedButton(title: 'Register', color: Colors.blueAccent, onPressed: () async{
                print(email);
                print(password);
                try{
                  final newUser = await _auth.createUserWithEmailAndPassword(email: email, password: password);
                  if(newUser != null){
                    Navigator.pushNamed(context, DashboardScreen.id, arguments: email);
                  }
                }catch(e){
                  print(e);
                }
            })
          ],
        ),
      ),
    );
  }
}
