import 'package:date/view/auth/onBoarding/onBoardingScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/auth_controller.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  bool showProgressBar = false;
  var controllerAuth = Get.put(AuthenticationController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
            child: Column(
          children: [
            const SizedBox(height: 100),
            Image.asset(
              'assets/images/trademark.png',
              width: 300,
            ),
            const Text(
              "Welcome",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              " Login now to find your best Match",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 25,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 30,
              height: 50,
              child: CustomTextField(
                  editingController: emailTextEditingController,
                  iconData: Icons.email_outlined,
                  isObsecure: false,
                  labelText: "beki@gmail.com"),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 30,
              height: 50,
              child: CustomTextField(
                  editingController: passwordTextEditingController,
                  iconData: Icons.email_outlined,
                  isObsecure: true,
                  labelText: "******"),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: MediaQuery.of(context).size.width - 30,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.all(Radius.circular(12))),
              child: InkWell(
                onTap: () {
                  if (emailTextEditingController.text.trim().isNotEmpty &&
                      passwordTextEditingController.text.trim().isNotEmpty) {
                    controllerAuth.loginUser(
                        emailTextEditingController.text.trim(),
                        passwordTextEditingController.text.trim());
                  } else {
                    Get.snackbar(
                        "Email/Password is missing", "please fill all fields");
                  }
                },
                child: Center(
                    child: Text(
                  "Login",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                )),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                InkWell(
                  onTap: () {
                    // Get.to(SignUpScreen());
                    Get.to(OnboardingScreen());
                  },
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.pinkAccent,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            showProgressBar == true
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                  )
                : Container()
          ],
        )),
      ),
    );
  }
}
