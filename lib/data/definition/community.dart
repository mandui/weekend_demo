import 'dart:convert';

class Community {
  
  Community(this.commId);

  // key
  String commId;

  // others
  CommunityInfo info;
  List<CommunityEvent> publicEvents =List();
  List<CommunityEvent> maintenanceEvents =List();
}

class CommunityInfo {
  String name;
  String addr;
  String manager;
  num area;

  String toJsonStr() {
    final jsonMap =Map<String, dynamic>();
    jsonMap["小区名称"] =name;
    jsonMap["小区地址"] =addr;
    jsonMap["占地面积"] =area;
    jsonMap["物业管理公司"] =manager;

    return json.encode(jsonMap);
  }
}

class CommunityEvent {
  String desc;
  String date;
  List<Choice> choices;
}

class Choice {
  String choiceDesc;
  num areaPercent;
  num ownerPercent;
}