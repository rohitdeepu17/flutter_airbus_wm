import 'package:flutter/material.dart';
import 'package:airbus/screens/login_screen.dart';
import 'package:airbus/screens/registration_screen.dart';
import 'package:animated_text_kit/src/typewriter.dart';

import '../components/rounded_button.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin{

  AnimationController? controller = null;

  double opacity_val = 0.2;

  late Animation animation;

  @override
  void initState(){
    super.initState();

    controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this
    );

    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white).animate(controller!);

    controller?.forward();

    controller?.addListener(() {
      print(controller?.value);
      setState(() {

      });
      opacity_val = controller!.value;

      print(animation.value);
    });
  }

  @override
  void dispose(){
    print('dispose called');
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    //height: (animation != null)? animation.value*100 : 60.0,
                    height: 60.0,
                  ),
                ),
                TypewriterAnimatedTextKit(
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                  ), text: [
                    'Airbus WM'
                ],
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(title: 'Log In', color: Colors.lightBlueAccent, onPressed: (){
              print('login button clicked');
              Navigator.pushNamed(context, LoginScreen.id);
            },),
            RoundedButton(title: 'Register', color: Colors.lightBlueAccent, onPressed: (){
              print('register button clicked');
              Navigator.pushNamed(context, RegistrationScreen.id);
            }),
          ],
        ),
      ),
    );
  }
}

