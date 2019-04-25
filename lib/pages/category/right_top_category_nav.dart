import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provide/provide.dart';
import '../../provide/child_category.dart';
import '../../model/CategoryModel.dart';

class RightTopCategoryNav extends StatefulWidget {
  @override
  _RightTopCategoryNavState createState() => _RightTopCategoryNavState();
}

class _RightTopCategoryNavState extends State<RightTopCategoryNav> {

  List navList = [
    '全部',
    '名酒',
    '宝丰',
    '北京二锅头',
    '大明',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Provide<ChildCategory>(
        builder: (context,child,childCategory){
          return Container(
            height: ScreenUtil().setHeight(80),
            width: ScreenUtil().setWidth(570),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    bottom: BorderSide(width: 1,color: Colors.black12)
                )
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: childCategory.childCategoryList.length,
              // itemCount: navList.length,
              itemBuilder: (context,index){
                return _rightInkWell(childCategory.childCategoryList[index]);
              },
            )
          );
        }
      ),
    );
  }

  Widget _rightInkWell(BxMallSubDto item){
    return InkWell(
      onTap: (){},
      child: Container(
        padding:EdgeInsets.fromLTRB(5.0,10.0,5.0,10.0),
        child: Text(
          item.mallSubName,
          style: TextStyle(
            fontSize:ScreenUtil().setSp(28),
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

