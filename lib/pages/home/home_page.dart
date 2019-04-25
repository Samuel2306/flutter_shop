import 'package:flutter/material.dart';
import '../../service/service_method.dart';
import 'dart:convert';
import '../common/swiper.dart';
import './top_navigator.dart';
import './ad_banner.dart';
import './leader_phone.dart';
import './recommend.dart';
import './floor_title.dart';
import './floor_content.dart';
import './below_content.dart';

import 'package:flutter_easyrefresh/easy_refresh.dart';



class HomePage extends StatefulWidget {
  _HomePageState createState() => new _HomePageState();
}

// https://time.geekbang.org/serv/v1/column/newAll
class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin{
  int page;
  List<Map> hotGoodsList = [];
  var data1 = '';

  @override
  bool get wantKeepAlive =>true;
  @override
  void initState() {
    page = 1;
    _getHotGoods();
    super.initState();
    // print('111111111111111111111111111');
  }
  void _getHotGoods(){
    var formData = {
      'page': page
    };
    request('homePageBelowContent',formData).then((val){
      var data=json.decode(val.toString());
      List<Map> newGoodsList = (data['data'] as List ).cast();
      setState(() {
        hotGoodsList.addAll(newGoodsList);
        page++;
      });
    });
  }

  @override
  Widget build(BuildContext context){
    GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('百姓生活+'),
        )
      ),
      // FutureBuilder动态组件
      body: FutureBuilder(
        future: request('homePageContent',{
          'lon': '115.02932',
          'lat': '35.76189'
        }),
        builder: (context, snapshot){
          // data1 = json.decode(snapshot.data);
          // snapshot.hasData判断有没有返回数据
          if(snapshot.hasData){
            var data = json.decode(snapshot.data);
            // print(data);
            List<Map> swiper = (data['data']['slides'] as List).cast();
            List<Map> navigatorList = (data['data']['category'] as List).cast();
            String adPicture = data['data']['advertesPicture']['PICTURE_ADDRESS'];
            String leaderImage = data['data']['shopInfo']['leaderImage'];
            String leaderPhone = data['data']['shopInfo']['leaderPhone'];
            List<Map> recommendList = (data['data']['recommend'] as List).cast(); // 商品推荐


            String floor1Title =data['data']['floor1Pic']['PICTURE_ADDRESS'];//楼层1的标题图片
            String floor2Title = data['data']['floor2Pic']['PICTURE_ADDRESS'];//楼层1的标题图片
            String floor3Title = data['data']['floor3Pic']['PICTURE_ADDRESS'];//楼层1的标题图片
            List<Map> floor1 = (data['data']['floor1'] as List).cast(); //楼层1商品和图片
            List<Map> floor2 = (data['data']['floor2'] as List).cast(); //楼层1商品和图片
            List<Map> floor3 = (data['data']['floor3'] as List).cast(); //楼层1商品和图片


            return EasyRefresh(
              child: ListView(
                children: <Widget>[
                  SwiperDiy(swiperDataList: swiper),
                  TopNavigator(navigatorList: navigatorList),
                  AdBanner(adPicture: adPicture),
                  LeaderPhone(leaderImage: leaderImage, leaderPhone: leaderPhone),
                  Recommend(recommendList:recommendList),
                  FloorTitle(picture_address:floor1Title),
                  FloorContent(floorGoodsList:floor1),
                  FloorTitle(picture_address:floor2Title),
                  FloorContent(floorGoodsList:floor2),
                  FloorTitle(picture_address:floor3Title),
                  FloorContent(floorGoodsList:floor3),
                  HotGoods(hotGoodsList: hotGoodsList),
                ],
              ),
              loadMore: ()async{
                print('开始加载更多');
                _getHotGoods();
              },
              refreshFooter: ClassicsFooter(
                key:_footerKey,
                bgColor:Colors.white,
                textColor: Colors.pink,
                moreInfoColor: Colors.pink,
                showMore: true,
                noMoreText: '',
                moreInfo: '加载中',
                loadReadyText:'上拉加载....'
              ),
            );
          }else{
            return Container(
              child: Center(
                child: Text('数据加载中...'),
              )
            );
          }
        },
      ),
    );
  }

}



