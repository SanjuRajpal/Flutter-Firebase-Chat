import 'package:flutter/material.dart';

class Snackbar {
  static void show(GlobalKey<ScaffoldState> state, String message) {
    state.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
