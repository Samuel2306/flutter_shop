import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:io';
import '../config/service_url.dart';

// 获取首页主体内容
Future getHomePageContent() async{
  try{
    // print('开始获取首页数据');
    Response response;
    Dio dio = new Dio();
    dio.options.contentType = ContentType.parse("application/x-www-form-urlencoded");
    var formData = {
      'lon': '115.02932',
      'lat': '35.76189'
    };
    response = await dio.post(servicePath['homePageContent'],data:formData);
    if(response.statusCode == 200){
      return response.data;
    }else{
      throw Exception('后端接口出现异常');
    }
  }catch(e){
    return print('ERROR: ==========> ${e}');
  }
}

// 获得商城首页火爆专区数据
Future getHomePageBelowContent() async{
  try{
    // print('开始获取火爆专区数据');
    Response response;
    Dio dio = new Dio();
    dio.options.contentType = ContentType.parse("application/x-www-form-urlencoded");
    int page = 1;
    response = await dio.post(servicePath['homePageBelowContent'],data:page);
    if(response.statusCode == 200){
      return response.data;
    }else{
      throw Exception('后端接口出现异常');
    }
  }catch(e){
    return print('ERROR: ==========> ${e}');
  }
}


Future request(url,formData) async{
  Dio dio;
  void setProxy() {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      // config the http client
      client.findProxy = (uri) {
        //proxy all request to localhost:8888
        return "PROXY 10.143.33.24:8666";
      };
      // you can also create a new HttpClient to dio
      // return new HttpClient();
    };
  }
  try{
    // print('开始获取数据...............');
    Response response;
    dio = new Dio();
    dio.options.contentType=ContentType.parse("application/x-www-form-urlencoded");
    // setProxy();

    if(formData==null){
      response = await dio.post(servicePath[url]);
    }else{
      response = await dio.post(servicePath[url],data:formData);
    }
    if(response.statusCode==200){
      
      return response.data;
    }else{
      throw Exception('后端接口出现异常，请检测代码和服务器情况.........');
    }
  }catch(e){
    return print('ERROR:======>${e}');
  }
}