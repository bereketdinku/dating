import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  String? uid;
  String? imageProfile;
  String? name;
  String? email;

  String? password;
  int? age;
  String? gender;
  String? phoneNo;
  String? city;
  String? country;
  int? publishedDateTime;
  String? profession;
  String? religion;
  List<String>? interests;
  Person(
      {this.uid,
      this.imageProfile,
      this.age,
      this.gender,
      this.city,
      this.country,
      this.name,
      this.phoneNo,
      this.profession,
      this.publishedDateTime,
      this.religion,
      this.email,
      this.password,
      this.interests});
  static Person fromDataSnapshot(DocumentSnapshot snapshot) {
    var dataSnapshot = snapshot.data() as Map<String, dynamic>;
    return Person(
        uid: dataSnapshot['uid'],
        name: dataSnapshot['name'],
        age: dataSnapshot['age'],
        email: dataSnapshot['email'],
        password: dataSnapshot['password'],
        gender: dataSnapshot['gender'],
        imageProfile: dataSnapshot['imageProfile'],
        city: dataSnapshot['city'],
        country: dataSnapshot['country'],
        phoneNo: dataSnapshot['phoneNo'],
        publishedDateTime: dataSnapshot['publishedDateTime'],
        religion: dataSnapshot['religion'],
        interests: dataSnapshot['interests']);
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "imageProfile": imageProfile,
        "name": name,
        "age": age,
        "city": city,
        "country": country,
        "email": email,
        "gender": gender,
        "phoneNo": phoneNo,
        "profession": profession,
        "publishedDateTime": publishedDateTime,
        "religion": religion,
        "interests": interests
      };
}
