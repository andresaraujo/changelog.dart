library changelog.example;

import 'package:changelog/changelog.dart';

main() async {
  ChangelogConfig opts = new ChangelogConfig();

  List<LogEntry> entries = await getLogEntries(opts);

  entries.forEach(print);
}
