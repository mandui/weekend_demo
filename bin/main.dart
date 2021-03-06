import 'package:demo_aqueduct/demo_aqueduct.dart';
import 'package:demo_aqueduct/data/global.dart' as globals;

Future main() async {
  final app = Application<DemoAqueductChannel>()
      ..options.configurationFilePath = "config.yaml"
      ..options.port = 8000;

  final count = Platform.numberOfProcessors ~/ 2;
  await app.start(numberOfInstances: count > 0 ? count : 1);

  print("Application started on port: ${app.options.port}.");
  print("Use Ctrl-C (SIGINT) to stop running the application.");

  //globals.prepare();

}