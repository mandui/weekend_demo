import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:aqueduct/aqueduct.dart';

import 'package:demo_aqueduct/data/definition/owner.dart';
import 'package:demo_aqueduct/data/global.dart' as globals;

class AddPropertyController extends FileController implements Recyclable{

  AddPropertyController(String pathOfDirectoryToServe) : super(pathOfDirectoryToServe);

  @Bind.query("code") String code;

  @override
  Future<RequestOrResponse> handle(Request request) async {
    //https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET
    //&code=CODE&grant_type=authorization_code
    Uri uri = Uri.https("api.weixin.qq.com", "sns/oauth2/access_token", {
      "appid" :globals.appID, "secret":globals.appSecret,
      "code" :code, "grant_type": "authorization_code"
    });

    final req =await HttpClient().getUrl(uri);
    final resp = await req.close(); 
    final jsonStr =await resp.transform(const Utf8Decoder()).toList();
    final jsonMap =json.decode(jsonStr[0]) as Map<String, dynamic>;

    final openid =jsonMap["openid"] as String;

    if (globals.userExist(openid))    
      return Response.ok("community ctrl: exist, and has properties");
    else 
      return request;
  }

  

  @override
  // TODO: implement recycledState
  get recycledState => null;

  @override
  void restore(state) {
    // TODO: implement restore
  }
  
}