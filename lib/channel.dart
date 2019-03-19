import 'package:demo_aqueduct/controllers/comm_controller.dart';
import 'package:demo_aqueduct/controllers/wechat_controller.dart';
import 'package:demo_aqueduct/controllers/owner_unbind.dart';
import 'package:demo_aqueduct/controllers/property_controller.dart';
import 'package:demo_aqueduct/controllers/no_property_ctrl.dart';
import 'package:demo_aqueduct/controllers/add_property_controller.dart';
import 'package:demo_aqueduct/data/data_provider.dart';
import 'package:demo_aqueduct/data/global.dart' as globals;
import 'demo_aqueduct.dart';

/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://aqueduct.io/docs/http/channel/.
class DemoAqueductChannel extends ApplicationChannel {
  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  @override
  Future prepare() async {
    logger.onRecord.listen((rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @override
  Controller get entryPoint {
    final router = Router();

    router
      .route("/example")
      .linkFunction((request) async {
        return Response.ok({"key": "value"});
      });

    router.route("/data/[:which]").link(() => DataProvider());

    router.route("/wechat/[:api]").link(() => WechatAuthorizer());

    router.route("/reset").linkFunction((request) async {
        globals.registedOwners.clear();
        return Response.ok("owner clears");
    });

    // 1. 我的小区
    router.route("/community/list/*")
      // openid存在，有小区信息，现实
      //.link(() => CommController("lib/pages/comm_list/"))
      .link(() => FileController("lib/pages/comm_list/"))
      // opid存在，无房产信息，
      .link(() => NoPropertyController("lib/pages/to_bind_properties/"))
      // openid不存在 -> 绑定信息
      .link(() => FileController("lib/pages/to_bind/"));

    // 2. 身份信息
    router.route("/owner/bind/*")
      // openid存在，提示解绑
      //.link(() => OwnerUnbindController("lib/pages/owner_unbind/"))
      // openid不存在，提示绑定
      .link(() => FileController("lib/pages/bind_id/"));

    router.route("/property/list/*")
      .link(() => FileController("lib/pages/m19_choose_method/"));

    router.route("/property/id/*")
      .link(() => FileController("lib/pages/temp/id_input/"));

    router.route("/property/account/*")
      .link(() => FileController("lib/pages/temp/account_input/"));

    // 3.维修资金查询
    /*router.route("/property/list/*")
    .link(() => FileController("lib/pages/property_list/"))
      // 有openid, 有房产
      .link(() => PropertyController("lib/pages/property_list/"))
      // 有openid, 无房产
      .link(() => NoPropertyController("lib/pages/to_bind_properties/"))
      // 无openid
      .link(() => FileController("lib/pages/to_bind/"));*/

    // 4.管理我的房产
    router.route("/property/add/*")
      // 有openid，search页面，选择特定房产之后提示关联
      .link(() => FileController("lib/pages/add_property2/"));
      //.link(() => AddPropertyController("lib/pages/add_property/"))
      // 无openid
      //.link(() => FileController("lib/pages/to_bind/"));

    // 无明显入口
    // hidden1 选择小区之后 会带参数
    router.route("/community/item/*").link(() => FileController("lib/pages/community_entry/"));
    // hidden2 选择入口，这里只有物业投票
    router.route("/community/entry/vote/*").link(() => FileController("lib/pages/community_entry/"));
    // hidden3 3-1 选择特定房产之后
    router.route("/property/details/*").link(() => FileController("lib/pages/property_details/"));

    //router.route("/owner/to_bind/*");
    //router.route("/owner/list_properties/*");

    // temp temp/add_property/
    router.route("/temp/add_property/*").link(() => FileController("lib/pages/temp/add_property/"));
    // temp temp/comm_info/
    router.route("/temp/comm_info/*").link(() => FileController("lib/pages/temp/comm_info/"));
    // temp temp/comm_vote/
    router.route("/temp/comm_vote/*").link(() => FileController("lib/pages/temp/comm_vote/"));
    // temp temp/property_details/ 实际是小区菜单
    router.route("/temp/property_details/*").link(() => FileController("lib/pages/temp/comm_entry/"));


    router.route("/get_menu")
      .linkFunction((request) => Response.ok(globals.getMenu())..contentType =ContentType.json);
    return router;
  }
}