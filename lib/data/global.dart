library demo_aqueduct.globals;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:demo_aqueduct/data/definition/owner.dart';

List<Owner> registedOwners =List();
const String appSecret = "3268923f3b1d643634b5ba2d5a47c7e3";
const String appID ="wx95129b9615825957";
String access_token = "";
String page_access_token = "";
num lastTime = 0;
bool menuCreated = false;


Future getAccessToken() async {
  final currentTime =DateTime.now().second;
  if (access_token == "" || (currentTime - lastTime) > 5400) {
    final uri = Uri.https("api.weixin.qq.com", "/cgi-bin/token", {
      "grant_type" :"client_credential",
      "appid" :appID, "secret" :appSecret
    });
    Map<String, dynamic> jsonMap = await _getRespFromUri(uri);
    access_token =jsonMap["access_token"] as String;
    lastTime = DateTime.now().second;
  }

  if (!menuCreated) {

    menuCreated =true;
  }
}

_createMenu() {
  final uri = Uri.https("api.weixin.qq.com", "/cgi-bin/menu/create", {
      "access_token":access_token
    });
  
  
  menuCreated =true;
}

const String auth = "ec2-3-18-145-128.us-east-2.compute.amazonaws.com";
Map<String, dynamic> _getMenu() {
  final commListUri = Uri.http(auth, "/community/list/").toString();
  final bindId = Uri.http(auth, "/owner/to_bind/").toString();
  final listPropertyId =Uri.http(auth, "/owner/list_properties").toString();
  final mngProperty =Uri.http(auth, "/owner/mng_properties").toString();

  Map<String, dynamic> menu = {
    "button":[
      { "name":"公告", "type":"click",
        "key":"V1001_TODAY_MUSIC"
      },
      { "name":"我的小区", "type":"view",
        "url":_getMenuUri(commListUri)
      },
      {
        "我的资金": [
          { "name":"身份信息", "type":"view", 
            "url":_getMenuUri(bindId) },
          { "name":"维修资金查询", "type":"view", 
            "url":_getMenuUri(listPropertyId) },
          { "name":"管理我的房产", "type":"view", 
            "url":_getMenuUri(mngProperty) }
        ]
      }
    ]
  };

  return menu;
}

String _getMenuUri(String redirectUri){
  const wechatAuth = "open.weixin.qq.com";
  const wechatPath = "/connect/oauth2/authorize";

  final menuUrl = Uri.https(wechatAuth, wechatPath, {
    "appid":appID, "redirect_uri":redirectUri, "response_type": "code",
  }).toString();

  return menuUrl;
}

Future<Map<String, dynamic>> 
  _getRespFromUri(Uri uri) async {
    final req =await HttpClient().getUrl(uri);
    // sends the request
    final resp = await req.close(); 

    final jsonStr =await resp.transform(const Utf8Decoder()).toList();
    final jsonMap =json.decode(jsonStr[0]) as Map<String, dynamic>;
    for (String key in jsonMap.keys) {
      print("key:   $key");
      print("value: ${jsonMap[key]}    type:  ${jsonMap[key].runtimeType}");
    }
    return jsonMap;
  }

Future<Map<String, dynamic>> 
  postRespWithData(Uri uri, Map<String, dynamic> params) async {
    final jsonStr = json.encode(params);
    final resp = await http.post(uri.toString(), body: jsonStr);
    
    final jsonStr2 =resp.body;
    final jsonMap =json.decode(jsonStr2) as Map<String, dynamic>;
    for (String key in jsonMap.keys) {
      print("key:   $key");
      print("value: ${jsonMap[key]}    type:  ${jsonMap[key].runtimeType}");
    }
    return jsonMap;
  }


Owner getOwner(String wechatId) {
  for (Owner owner in registedOwners) {
    if (owner.wechatID ==wechatId)
      return owner;
  }

  return null;
}

void delOwner(String wechatId) {
  for (Owner owner in registedOwners) {
    if (owner.wechatID ==wechatId) {
      registedOwners.remove(owner);
      break;
    }
  }
}

bool userExist(String wechatId) {
  return registedOwners.contains(wechatId);
}

void addProperty(String wechatId, String propertyId, String communityId) {
  for (Owner owner in registedOwners) {
    if (owner.wechatID ==wechatId) {

      if (!owner.proertyIds.contains(propertyId)) {
        owner.proertyIds.add(propertyId);

        if (!owner.communityIds.contains(communityId))
          owner.communityIds.add(communityId);
      }
      break;
    }
  }
}

Map<String, dynamic> 
listCommunityIds(String wechatId) {
  for (Owner owner in registedOwners) {
    if (owner.wechatID ==wechatId) {
      final jsonMap =Map<String, dynamic>();
      jsonMap["communityIds"] =owner.communityIds;

      return jsonMap;
    }
  }
  return null;
}

Map<String, dynamic> 
listPropertyIds(String wechatId) {
  for (Owner owner in registedOwners) {
    if (owner.wechatID ==wechatId) {
      final jsonMap =Map<String, dynamic>();
      jsonMap["propertyIds"] =owner.proertyIds;

      return jsonMap;
    }
  }
  return null;
}

void regOwner(String wechatId, { 
  String id = "000000", String idType = "身份证", String name = "秦先生"}) {
  print("some some thing");
  if (wechatId ==null) 
    return;

  bool shouldAdd =true;
  for (Owner owner in registedOwners) {
    if (owner.wechatID ==wechatId) {
      shouldAdd =false;
      break;
    }
  }

  if (shouldAdd) {
    final owner =Owner(wechatId)
        ..ownerName =name
        ..idNo =id
        ..idType =idType;
    registedOwners.add(owner);

    print("reg owner num: ${registedOwners.length}");
  }
}