library changelog.example;

import 'package:changelog/changelog.dart';

main() async {
  ChangelogConfig opts = new ChangelogConfig();
  opts.addSection('Refactor', ['refactor']);

  List<LogEntry> entries = await getLogEntries(opts);

  entries.forEach(print);
}
