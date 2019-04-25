// 在provide中把每一个State称为一个model
// Provide模式中model不再需要继承Model类，只需要实现Listenable，我们在这里使用混入ChangeNotifier的方法，可以不用管理听众。
// 通过 notifyListeners 我们可以通知听众刷新
import 'package:flutter/material.dart';

class Counter with ChangeNotifier {
  int value = 0;
  increment(){
    value++;
    notifyListeners(); // 通知一下监听者
  }
}