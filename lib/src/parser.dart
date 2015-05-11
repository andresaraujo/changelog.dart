part of changelog;

RegExp commitPattern = new RegExp(r"^(.*)\((.*)\):(.*)");
RegExp commitAltPattern = new RegExp(r"^(.*):\s(.*)");
RegExp closesPattern =
    new RegExp(r"(?:Closes|Fixes|Resolves)\s((?:#(\d+)(?:,\s)?)+)");
RegExp closesIntPattern = new RegExp(r"\d+");
RegExp breakingPattern = new RegExp(r"BREAKING CHANGE:([\s\S]*)");

getLogEntries(ChangelogConfig config, {String workingDir}) async {
  var range = config.from == null || config.from.isEmpty
      ? "HEAD"
      : "${config.from}..${config.to}";

  var arguments = [
    'log',
    '-E',
    '--grep=${config.grep}',
    '--format=${config.format}',
    '$range'
  ];

  ProcessResult result =
      await git.runGit(arguments, processWorkingDir: workingDir);

  String out = result.stdout.toString();

  List<LogEntry> entries = out
      .split("\n==END==\n")
      .map((raw) => parseRawCommit(raw, config))
      .where((entry) => entry != null)
      .toList();
  return entries;
}

LogEntry parseRawCommit(String raw, ChangelogConfig opts) {
  if (raw == null || raw.isEmpty) {
    return null;
  }

  final lines = raw.split('\n');
  final entry = new LogEntry();

  entry.hash = lines.removeAt(0);
  entry.subject = lines.removeAt(0);

  //Extract closes
  lines
      .map((line) => closesPattern.firstMatch(line))
      .where((match) => match != null)
      .map((match) => match[0].split(','))
      .forEach((List items) {
    items
        .map((item) => closesIntPattern.firstMatch(item))
        .where((match) => match != null)
        .forEach((match) => entry.closes.add(int.parse(match[0])));
  });

  entry.body = lines.map((line) => line.trim()).join('\n');

  var matcher;

  //Extract breaking changes
  matcher = breakingPattern.firstMatch(raw);
  if(matcher != null) {
    entry.breaks = matcher[1].split('\n').map((line) => line.trim()).join('\n');
  }

  //Extract type, component, type
  matcher = commitPattern.firstMatch(entry.subject);

  //If component doesn't exist
  if (matcher == null) {
    matcher = commitAltPattern.firstMatch(entry.subject);
    if (matcher == null) {
      print("Incorrect message: ${entry.hash} ${entry.subject}");
      entry.type = opts.getSectionFor("unk");
      return null;
    }
    entry.type = opts.getSectionFor(matcher[1].toLowerCase().trim());
    entry.subject = matcher[2].trim();

    return entry;
  }

  entry.type = opts.getSectionFor(matcher[1].toLowerCase().trim());
  entry.component = matcher[2].trim();
  entry.subject = matcher[3].trim();

  return entry;
}
