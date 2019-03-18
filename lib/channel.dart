import 'package:demo_aqueduct/data/data_provider.dart';
import 'demo_aqueduct.dart';
import 'package:demo_aqueduct/controllers/comm_controller.dart';
import 'package:demo_aqueduct/controllers/wechat_controller.dart';

import 'package:demo_aqueduct/data/global.dart' as globals;

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

  /// Construct the request channel.
  ///
  /// Return an instance of some [Controller] that will be the initial receiver
  /// of all [Request]s.
  ///
  /// This method is invoked after [prepare].
  @override
  Controller get entryPoint {
    final router = Router();

    // Prefer to use `link` instead of `linkFunction`.
    // See: https://aqueduct.io/docs/http/request_controller/
    router
      .route("/example")
      .linkFunction((request) async {
        return Response.ok({"key": "value"});
      });

    router.route("/data/[:which]").link(() => DataProvider());

    router.route("/wechat/[:api]").link(() => WechatAuthorizer());

    //router.route("/temp/page01/*").link(() => FileController("lib/page_01/"));
    //router.route("/temp/page02/*").link(() => FileController("lib/page_02/"));
    
    router.route("/community/list/*")
      .link(() => CommController("lib/pages/to_bind/"))
      .link(() => FileController("lib/pages/to_bind/"));

    //router.route("/owner/to_bind/*");
    //router.route("/owner/list_properties/*");

    router.route("/get_menu")
      .linkFunction((request) => Response.ok(globals.getMenu())..contentType =ContentType.json);
    return router;
  }
}