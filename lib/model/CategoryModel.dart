class CategoryBigModel {
  String mallCategoryId; // 类别编号
  String mallCategoryName; // 类别名称
  List<dynamic> bxMallSubDto;        //小类列表
  String image;             //类别图片
  Null comments;          //列表描述

  //构造函数
  CategoryBigModel({
    this.mallCategoryId,
    this.mallCategoryName,
    this.comments,
    this.image,
    this.bxMallSubDto
  });

  factory CategoryBigModel.fromJson(dynamic json){
    return CategoryBigModel(
        mallCategoryId:json['mallCategoryId'],
        mallCategoryName:json['mallCategoryName'],
        comments:json['comments'],
        image:json['image'],
        bxMallSubDto:json['bxMallSubDto']
    );
  }
}


class CategoryBigListModel {
  List<CategoryBigModel> data;
  CategoryBigListModel(this.data);
  factory CategoryBigListModel.formJson(List json){
    return CategoryBigListModel(
        json.map((i)=>CategoryBigModel.fromJson((i))).toList()
    );
  }
}


class BxMallSubDto {
  String mallSubId;
  String mallCategoryId;
  String mallSubName;
  String comments;

  BxMallSubDto({this.mallSubId, this.mallCategoryId, this.mallSubName, this.comments});

  BxMallSubDto.fromJson(Map<String, dynamic> json) {
    mallSubId = json['mallSubId'];
    mallCategoryId = json['mallCategoryId'];
    mallSubName = json['mallSubName'];
    comments = json['comments'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mallSubId'] = this.mallSubId;
    data['mallCategoryId'] = this.mallCategoryId;
    data['mallSubName'] = this.mallSubName;
    data['comments'] = this.comments;
    return data;
  }
}