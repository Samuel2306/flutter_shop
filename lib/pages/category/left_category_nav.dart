import 'package:flutter/material.dart';
import '../../model/CategoryModel.dart';
import '../../service/service_method.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provide/provide.dart';
import '../../provide/child_category.dart';
//左侧导航菜单
class LeftCategoryNav extends StatefulWidget {
  _LeftCategoryNavState createState() => _LeftCategoryNavState();
}
class _LeftCategoryNavState extends State<LeftCategoryNav> {
  List list = [];
  var listIndex = 0; //索引

  @override
  void initState() {
    _getCategory();
    super.initState();
  }

  Widget _leftInkWel(int index){
    bool isClick=false;
    isClick=(index==listIndex)?true:false;
    return InkWell(
      onTap: (){
        setState(() {
          listIndex=index;
        });
        var childList = list[index].bxMallSubDto;
        print(childList);
        Provide.value<ChildCategory>(context).getChildCategory(childList);
      },
      child: Container(
        height: ScreenUtil().setHeight(100),
        padding:EdgeInsets.only(left:10,top:20),
        decoration: BoxDecoration(
            color: isClick?Colors.black26:Colors.white,
            border:Border(
                bottom:BorderSide(width: 1,color:Colors.black12)
            )
        ),
        child: Text(list[index].mallCategoryName,style: TextStyle(fontSize:ScreenUtil().setSp(28)),),
      ),
    );
  }


  void _getCategory()async{
    await request('getCategory',null).then((val){
      var data = json.decode(val.toString());
      CategoryBigListModel category = CategoryBigListModel.formJson(data['data']);
      setState(() {
        list = category.data;
      });
      // 设置默认值
      Provide.value<ChildCategory>(context).getChildCategory( list[0].bxMallSubDto);
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(list.length);
    return Container(
      width: ScreenUtil().setWidth(180),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(width: 1,color:Colors.black12)
        )
      ),
      child: ListView.builder(
        itemCount:list.length,
        itemBuilder: (context,index){
          return _leftInkWel(index);
        },
      ),
    );
  }
}