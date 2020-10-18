import 'package:flutter/material.dart';

class Validators {
  static final RegExp _emailRegex = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  bool validUser(String email) {
    if (isEmpty(email)) return false;
    if (email.length <=4) {
      return false;
    } else {
      return true;
    }
  }

  bool validPass(String pass) {
    if (isEmpty(pass)) return false;
    if (pass.length>4) {
      return true;
    } else {
      return false;
    }
  }
  static bool isEmpty(Object text) {
    if (text is String) return text == null || text.isEmpty;
    if (text is List) return text == null || text.isEmpty;
    return text == null;
  }
}
