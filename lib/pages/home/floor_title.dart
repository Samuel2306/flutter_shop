// 楼层标题组件
import 'package:flutter/material.dart';

class FloorTitle extends StatelessWidget {
  final String picture_address; // 图片地址
  FloorTitle({Key key, this.picture_address}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8.0,16.0,8.0,16.0),
      child: Image.network(picture_address),
    );
  }
}