import 'package:flutter/material.dart';
import 'package:provide/provide.dart';
import '../../provide/counter.dart';

class MemberPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Number()
          ],
        )
      ),
    );
  }
}

class Number extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 200.0),
      child: Provide<Counter>(
        builder: (context,child,counter){
          return Text('${counter.value}');
        },
      ),
    );
  }
}