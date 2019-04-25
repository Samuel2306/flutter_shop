import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SwiperDiy extends StatelessWidget {
  final List swiperDataList;

  SwiperDiy({this.swiperDataList});

  @override
  Widget build(BuildContext context) {
    print('设备像素密度：${ScreenUtil.pixelRatio},设备高度：${ScreenUtil.screenHeight},设备宽度：${ScreenUtil.screenWidth}');
    return Container(
      height: ScreenUtil().setHeight(333),
      width: ScreenUtil().setWidth(750),
      child: Swiper(
        itemCount: swiperDataList.length,
        itemBuilder: (BuildContext context, int index){
          return Image.network(
            "${swiperDataList[index]['image']}",
            fit: BoxFit.fill
          );
        },
        pagination: SwiperPagination(),
        autoplay: true,
      ),
    );
  }
}


