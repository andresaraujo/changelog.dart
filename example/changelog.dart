library changelog.example;

import 'package:changelog/changelog.dart';
import 'dart:io';

main() async {
  ChangelogConfig config = new ChangelogConfig()
  ..repoUrl = "https://github.com/andresaraujo/changelog.dart"
  ..appName = "changelog.dart"
  ..addSection('Refactor', ['refactor']);


  List<LogEntry> entries = await getLogEntries(config);
  File f = new File("CHANGELOG.md");
  f.writeAsStringSync("asd");
  print(f.existsSync());
  writeChangelog(f, entries, config);
}
