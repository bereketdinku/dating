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
  String? profileHeading;
  String? lookingForImagePartner;
  int? publishedDateTime;
  String? height;
  String? width;
  String? bodyType;
  String? drink;
  String? smoke;
  String? martialStatus;
  String? haveChildren;
  String? noOfChildren;
  String? profession;
  String? employementStatus;
  String? income;
  String? livingSituation;
  String? willingToRelocate;
  String? relationshipType;
  String? nationality;
  String? education;
  String? languageSpoken;
  String? religion;
  String? ethnicity;
  Person(
      {this.uid,
      this.imageProfile,
      this.age,
      this.gender,
      this.bodyType,
      this.city,
      this.country,
      this.drink,
      this.education,
      this.employementStatus,
      this.ethnicity,
      this.haveChildren,
      this.height,
      this.income,
      this.languageSpoken,
      this.livingSituation,
      this.lookingForImagePartner,
      this.martialStatus,
      this.name,
      this.nationality,
      this.noOfChildren,
      this.phoneNo,
      this.profession,
      this.profileHeading,
      this.publishedDateTime,
      this.relationshipType,
      this.religion,
      this.smoke,
      this.width,
      this.willingToRelocate,
      this.email,
      this.password});
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
        bodyType: dataSnapshot['bodyType'],
        city: dataSnapshot['city'],
        country: dataSnapshot['country'],
        drink: dataSnapshot['dink'],
        education: dataSnapshot['education'],
        employementStatus: dataSnapshot['employementStatus'],
        ethnicity: dataSnapshot['ethnicity'],
        haveChildren: dataSnapshot['haveChildren'],
        height: dataSnapshot['height'],
        income: dataSnapshot['income'],
        livingSituation: dataSnapshot['livingSituation'],
        languageSpoken: dataSnapshot['languageSpoken'],
        martialStatus: dataSnapshot['martialStatus'],
        nationality: dataSnapshot['nationality'],
        noOfChildren: dataSnapshot['noOfChildren'],
        phoneNo: dataSnapshot['phoneNo'],
        profession: dataSnapshot['profession'],
        profileHeading: dataSnapshot['profileHeading'],
        publishedDateTime: dataSnapshot['publishedDateTime'],
        relationshipType: dataSnapshot['relationshipType'],
        religion: dataSnapshot['religion'],
        smoke: dataSnapshot['smoke'],
        width: dataSnapshot['width'],
        willingToRelocate: dataSnapshot['willingToRelocate']);
  }

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "imageProfile": imageProfile,
        "name": name,
        "age": age,
        "bodyType": bodyType,
        "city": city,
        "country": country,
        "drink": drink,
        "education": education,
        "email": email,
        "employementStatus": employementStatus,
        "ethnicity": ethnicity,
        "gender": gender,
        "haveChildren": haveChildren,
        "height": height,
        "income": income,
        "languageSpoken": languageSpoken,
        "livingSituation": livingSituation,
        "martialStatus": martialStatus,
        "nationality": nationality,
        "phoneNo": phoneNo,
        "profession": profession,
        "profileHeading": profileHeading,
        "publishedDateTime": publishedDateTime,
        "relationshipType": relationshipType,
        "religion": religion,
        "smoke": smoke,
        "width": width,
        "willingToRelocate": willingToRelocate,
      };
}
