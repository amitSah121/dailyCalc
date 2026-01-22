import 'package:flutter/widget_previews.dart';
import 'package:flutter/material.dart'; // For Material widgets

@Preview(name: 'My Sample Text')
Widget mySampleText() {
  return ListView.builder(itemBuilder: (context, i){
    return Text(i.toString());
  });
}
