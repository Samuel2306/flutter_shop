import 'package:flutter/material.dart';
import './left_category_nav.dart';
import './right_top_category_nav.dart';

class CategoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Center(
            child: Text('商品分类'),
          )
      ),
      body: Container(
        child: Row(
          children: <Widget>[
            LeftCategoryNav(),
            Column(
              children: <Widget>[
                RightTopCategoryNav(),
              ],
            )
          ],
        ),
      ),
    );
  }
}
