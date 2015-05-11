import 'package:grinder/grinder.dart';
//import 'dart:io';

//Map get _env => Platform.environment;

main(args) => grind(args);

@Task()
analyze() {
  new PubApp.local('tuneup')..run(['check']);
}

@Task()
test() {
  new PubApp.local('test').run([]);
}

@DefaultTask()
@Depends(analyze, test)
analyzeTest() => null;
