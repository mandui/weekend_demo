import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:aqueduct/aqueduct.dart';

import 'package:demo_aqueduct/data/definition/owner.dart';
import 'package:demo_aqueduct/data/global.dart' as globals;

class NoPropertyController extends FileController implements Recyclable{

  NoPropertyController(String pathOfDirectoryToServe) : super(pathOfDirectoryToServe);

  @Bind.query("code") String code;

  @override
  Future<RequestOrResponse> handle(Request request) async {

    Uri uri = Uri.https("api.weixin.qq.com", "sns/oauth2/access_token", {
      "appid" :globals.appID, "secret":globals.appSecret,
      "code" :code, "grant_type": "authorization_code"
    });

    final req =await HttpClient().getUrl(uri);
    final resp = await req.close(); 
    final jsonStr =await resp.transform(const Utf8Decoder()).toList();
    final jsonMap =json.decode(jsonStr[0]) as Map<String, dynamic>;

    final openid =jsonMap["openid"] as String;

    if (globals.userExist(openid)) {
      if(globals.getOwner(openid).proertyIds.isEmpty)
        return request;
      return Response.ok("openid exist");
    }   
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