import 'package:flutter/material.dart';
import 'package:provide/provide.dart';
import '../../provide/counter.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Number(),
            MyButton(),
          ],
        ),
      ),
    );
  }
}


class Number extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 200.0),
      /// 获取状态的一种方法：通过Provide小部件获取
      /// 每次通知数据刷新时，builder将会重新构建这个小部件
      ///
      child: Provide<Counter>(
        /// 第二个参数child：假如这个小部件足够复杂，内部有一些小部件是不会改变的，那么我们可以将
        /// 这部分小部件写在Provide的child属性中，让builder不再重复创建这些小部件，以提升性能。

        /// 第三个参数counter：这个参数代表了我们获取的顶层providers中的状态
        builder: (context,child,counter){
          return Text('${counter.value}');
        },
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: RaisedButton(
        onPressed: (){
          /// 第二种获取状态的方式：Provide.value<T>(context)
          Provide.value<Counter>(context).increment();
        },
        child: Text('递增'),
      ),
    );
  }
}

