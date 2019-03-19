import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:aqueduct/aqueduct.dart';
import 'package:crypto/crypto.dart';
import 'package:demo_aqueduct/data/global.dart' as globals;

class WechatAuthorizer extends ResourceController {
  
  static const String token = "ExprMandui";
  @Bind.query('id_type') String idType;

  @Operation.get()
  Future<RequestOrResponse> checkFromWechat (
    @Bind.query('signature') String signature,
    @Bind.query('nonce') String nonce,
    @Bind.query('timestamp') String timestamp,
    @Bind.query('echostr') String echostr) async {

    if (fromWechat(timestamp, nonce, signature)) {
      return request;
      //return Response.ok(echostr)..contentType = ContentType.text;
    }
    // I wonder weather is always called

    return Response.unauthorized();
  }

  // todo add refresh every 90 min
  @Operation.post() 
  Future<Response> replyMessages() async {
    return Response.ok("body");
  }

  // FOR TEST PART ------------------------------------------------
  @Operation.get("api")
  Future<Response> testWechatAPI() async {
    final apiType = request.path.variables['api'];
    print("testWechatAPI: $apiType");

    Map<String, dynamic> retMap;
    switch (apiType) {
      case "access_token":
        //retMap = {"access_token": await globals.getAccessToken()}; break;
        retMap =await getAccessToken(); break;
      case "wechat_server_ip":
        retMap =await getWechatServerIP(); break;
      case "network_detect":
        retMap =await detectNetworkStatus(); break;
        break;
      case "create_menu":
        await _createMenu(); break;
      default:
        return Response.ok("$apiType api test is not currently supported.");
    }

    final title = "API: $apiType";
    final contents = json.encode(retMap);
    return Response.ok("$title\n$contents")..contentType =ContentType.text;
  }

  
  // util functions ----------------------------------------------
  Future<Map<String, dynamic>> detectNetworkStatus(
    {String action ="all", String checkOperator ="DEFAULT"}) async {

    final uri = Uri.https("api.weixin.qq.com", "/cgi-bin/callback/check", {
      "access_token" :globals.access_token
    });
    final params = Map<String, String>();
    params["action"] = action;
    params["check_operator"] = checkOperator;
    
    return postRespWithData(uri, params);
  }

  Future<Map<String, dynamic>> 
  getWechatServerIP() async {
    final uri = Uri.https("api.weixin.qq.com", "/cgi-bin/getcallbackip", {
      "access_token" :globals.access_token
    });
    return getRespFromUri(uri);
  }

  Future<Map<String, dynamic>> 
  getAccessToken() async {
    Uri uri;
    if (idType != null && idType == "expr") {
      uri = Uri.https("api.weixin.qq.com", "/cgi-bin/token", {
      "grant_type" :"client_credential",
      "appid" :globals.exprAppId, "secret" : globals.exprAppSecret
    });

    } else {
      uri = Uri.https("api.weixin.qq.com", "/cgi-bin/token", {
      "grant_type" :"client_credential",
      "appid" :globals.appID, "secret" : globals.appSecret
      });
    }

    return getRespFromUri(uri);
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
 
  Future<Map<String, dynamic>> 
  getRespFromUri(Uri uri) async {
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

  bool fromWechat(String timestamp, String nonce, String signature) {
    final tokenArr = List<String>(3);
    tokenArr[0] =token;
    tokenArr[1] =timestamp;
    tokenArr[2] =nonce;
    tokenArr.sort();
    final String contactStr =tokenArr[0] + tokenArr[1] + tokenArr[2];

    final bytes = utf8.encode(contactStr);
    final digest = sha1.convert(bytes).toString();

    return digest ==signature;
  }

  Future _createMenu() async {
    final uri = Uri.https("api.weixin.qq.com", "/cgi-bin/menu/create", {
        "access_token":globals.access_token
      });
    final params =_getMenu();
    final ret = await postRespWithData(uri, params);
    print("menu created: ${json.encode(ret)}");
}

final auth = "www.imandui.com";
Map<String, dynamic> _getMenu() {
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
    "appid":globals.appID, "redirect_uri":redirectUri, "response_type": "code",
  }).toString();

  return menuUrl;
}

}