import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LeaderPhone extends StatelessWidget {

  final String leaderImage; // 店长图片
  final String leaderPhone; // 店长图片

  LeaderPhone({this.leaderImage,this.leaderPhone});

  void _launchURL() async {
    String url = 'tel:'+leaderPhone;
    // canLaunch用来判断当前设备是否支持特定的url格式
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: _launchURL,
        child: Image.network(leaderImage),
      )
    );
  }
}
