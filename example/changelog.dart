library changelog.example;

import 'package:changelog/changelog.dart';

main() async {
  Opts opts = new Opts();

  List<LogEntry> entries = await getLogEntries(opts);

  entries.forEach(print);
}
