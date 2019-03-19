library demo_aqueduct.globals;
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aqueduct/aqueduct.dart';

import 'package:demo_aqueduct/data/definition/owner.dart';

void prepare() {
  getAccessToken();
  final timeout = Duration(seconds:5400);
  Timer.periodic(timeout, (Timer t) => getAccessToken());
}

// key:openid value:access_token, last time,
Map<String, String> tokens = Map();
Map<String, num> tokenTime = Map();

List<Owner> registedOwners =List();
//real one
const String appSecret = "Be91c1df6197e26f129bcf7608aabdb1";
const String appID ="wx10823f9799c7f8dc";
String access_token = "";
String page_access_token = "";
num lastTime = 0;
bool menuCreated = false;


Future<String> getAccessToken() async {
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

  /*if (!menuCreated) {
    await _createMenu();
    menuCreated =true;
  }*/

  return access_token;
}

Future _createMenu() async {
  final uri = Uri.https("api.weixin.qq.com", "/cgi-bin/menu/create", {
      "access_token":access_token
    });
  final params =getMenu();
  final ret = await _postRespWithData(uri, params);
  print("menu created: ${json.encode(ret)}");
  
  menuCreated =true;
}

//const String auth = "ec2-3-18-145-128.us-east-2.compute.amazonaws.com";
const String auth = "3cc658f0.ngrok.io";
Map<String, dynamic> getMenu() {
  final commListUri = Uri.https(auth, "/community/list/").toString();
  final bindId = Uri.https(auth, "/owner/to_bind/").toString();
  final listPropertyId =Uri.https(auth, "/owner/list_properties").toString();
  final mngProperty =Uri.https(auth, "/owner/mng_properties").toString();

  Map<String, dynamic> menu = {
    "button":[
      { "name":"公告", "type":"click",
        "key":"V1001_TODAY_MUSIC"
      },
      { "name":"我的小区", "type":"view",
        "url":_getMenuUri(commListUri)
      },
      {
        "name": "我的资金",
        "sub_button" : [
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
    "scope":"snsapi_base"
  }).toString() + "#wechat_redirect";

  return menuUrl;
}

void regAccessToken(String token) {
  access_token = token;
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
  _postRespWithData(Uri uri, Map<String, dynamic> params) async {
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