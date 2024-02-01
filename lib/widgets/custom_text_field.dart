import "package:flutter/material.dart";

class CustomTextField extends StatelessWidget {
  final TextEditingController? editingController;
  final IconData? iconData;
  final String? assetRef;
  final String? labelText;
  final bool isObsecure;
  const CustomTextField(
      {super.key,
      this.editingController,
      this.assetRef,
      this.iconData,
      required this.isObsecure,
      this.labelText});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: editingController,
      decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: iconData != null
              ? Icon(
                  iconData,
                  color: Colors.pink,
                )
              : Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(assetRef.toString()),
                ),
          labelStyle: const TextStyle(fontSize: 18),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.grey)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.grey))),
      obscureText: isObsecure,
    );
  }
}
