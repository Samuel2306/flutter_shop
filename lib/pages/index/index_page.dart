// material 和 cupertino 是两种风格
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app_demo/pages/home/home_page.dart';
import 'package:flutter_app_demo/pages/category/category_page.dart';
import 'package:flutter_app_demo/pages/cart/cart_page.dart';
import 'package:flutter_app_demo/pages/member/member_page.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';


class IndexPageWidget extends StatefulWidget {
  _IndexPageWidgetState createState() => _IndexPageWidgetState();
}

class _IndexPageWidgetState extends State<IndexPageWidget> {
  int currentIndex = 0;
  var currentPage;

  PageController _pageController;

  final List<BottomNavigationBarItem> bottomTabs = [
    BottomNavigationBarItem(
        icon:Icon(CupertinoIcons.home),
        title:Text('首页')
    ),
    BottomNavigationBarItem(
        icon:Icon(CupertinoIcons.search),
        title:Text('类别')
    ),
    BottomNavigationBarItem(
        icon:Icon(CupertinoIcons.shopping_cart),
        title:Text('购物车')
    ),
    BottomNavigationBarItem(
        icon:Icon(CupertinoIcons.profile_circled),
        title:Text('会员中心')
    ),
  ];

  List<Widget> list = [
    HomePage(),
    CategoryPage(),
    CartPage(),
    MemberPage(),
  ];


  @override
  void initState(){
    currentPage = list[currentIndex];
    _pageController = new PageController();
    _pageController.addListener(() {
      if (currentPage != _pageController.page.round()) {
        setState(() {
          currentPage = _pageController.page.round();
        });
      }
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1344)..init(context);
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 245, 245, 1.0),
      // body: list[currentIndex],
      body: IndexedStack(
        index: currentIndex,
        children: list
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: bottomTabs,
        currentIndex: currentIndex,
        onTap:(int index){
          setState((){
            currentIndex = index;
            currentPage = list[currentIndex];
          });
        },
        type:BottomNavigationBarType.fixed
      ),
    );
  }
}