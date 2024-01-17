import 'package:firebase_auth/firebase_auth.dart';

String currentUserID = FirebaseAuth.instance.currentUser!.uid;
String fcmServerToken =
    "key=AAAAwe9tmkg:APA91bHkAQrgwpx7AY7eZU4u0_aY1txBu801o7EYDO3SiPd-A1k60L1sauLgQpMklj06_ABPdBGPrWjr5nx3spAQV1ixNwBAPEnF3lzBepF4srM4PPk5qaJMabE_ZB5uTt5RaxSloVeZ";
String? chosenAge;
String? chosenCountry;
String? chosenGender;
