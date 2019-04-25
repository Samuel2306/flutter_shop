import 'package:flutter/material.dart';
import 'package:provide/provide.dart';
import './provide/counter.dart';
import './provide/child_category.dart';
import 'package:flutter_app_demo/pages/index/index_page.dart';


void main() {
  var counter = Counter();
  var childCategory = ChildCategory();
  var providers = Providers();
  // ProviderNode封装了InheritWidget，并且提供了 一个providers容器用于放置状态（provide）
  // Provider<Counter>.value将counter包装成了_ValueProvider，简而言之就是包装成了一个provider
  // provide方法就是将新的provider添加到providers这容器里面
  providers
    ..provide(Provider<Counter>.value(counter))
    ..provide(Provider<ChildCategory>.value(childCategory));
  runApp(ProviderNode(child: new MyApp(), providers: providers));
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: '百姓生活+',
        theme: ThemeData.light(),
        home: IndexPageWidget()
    );
  }
}
