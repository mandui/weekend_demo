import 'package:aqueduct/aqueduct.dart';

import 'package:demo_aqueduct/data/definition/owner.dart';
import 'package:demo_aqueduct/data/global.dart' as globals;

class ManagePropertyController extends FileController implements Recyclable {

  ManagePropertyController(String pathOfDirectoryToServe) : super(pathOfDirectoryToServe);

  @Bind.query("wechatId") String wechatId;

  @override
  Future<RequestOrResponse> handle(Request request) async {
    
    final owner =globals.getOwner(wechatId);

    if (owner == null) 
      return request;

    if (owner.communityIds.isEmpty)
      return request;

    return Response.ok("property ctrl: owner exist, and has properties");
  }

  @override
  // TODO: implement recycledState
  get recycledState => null;

  @override
  void restore(state) {
    // TODO: implement restore
  }
  
}