part of changelog;

const EMPTY_COMPONENT = '\$\$';

writeChangelog(io.File file, List<LogEntry> entries, ChangelogConfig config) {
  /*Map sections = {};

  config._sections.keys.forEach((key) => sections[key] = {});
  sections['BREAKS'] = {};

  entries.forEach((entry) {
    Map<String, List> section = sections[entry.type];
    var component = entry.component != null ? entry.component :  EMPTY_COMPONENT;

    if(section != null) {
      section[component] = section[component] != null ? section[component] : [];
      section[component].add(entry);
    }

    if(entry.breaks != null) {
      sections['breaks'][component] =  sections['breaks'][component] != null ? sections['breaks'][component] : [];
      sections['breaks'][component].add(
          new LogEntry()
            ..subject = "due to [${entry.hash.substring(0,8)}](${config.repoUrl}/commits/${entry.hash}),\n ${entry.breaks}"
            ..hash = entry.hash
            ..closes = []
      );
    }
  });
  StringBuffer content = new StringBuffer();

  //header
  content.write('<a name="${config.version}">${config.appName}</a>\n# ${config.version} ${config.versionText} (${currentDate()})\n\n');

  sections.forEach((sectionName, Map section) {
    if(section.isNotEmpty) {
      writeSection(content, sectionName, sections[sectionName], config, printCommitLinks: true);
    }
  });*/

  StringBuffer content = new StringBuffer();
  var newContent = buildContentToWrite(content, entries, config);

  List<int> oldContent = file.readAsBytesSync();
  file.writeAsStringSync(newContent, mode: io.FileMode.WRITE);
  if (oldContent.length > 0) file.writeAsStringSync(UTF8.decode(oldContent),
      mode: io.FileMode.APPEND);
}

String buildContentToWrite(
    StringBuffer content, List<LogEntry> entries, ChangelogConfig config) {
  Map sections = {};

  config._sections.keys.forEach((key) => sections[key] = {});
  sections['BREAKS'] = {};

  entries.forEach((entry) {
    Map<String, List> section = sections[entry.type];
    var component = entry.component != null ? entry.component : EMPTY_COMPONENT;

    if (section != null) {
      section[component] = section[component] != null ? section[component] : [];
      section[component].add(entry);
    }

    if (entry.breaks != null) {
      sections['breaks'][component] = sections['breaks'][component] != null
          ? sections['breaks'][component]
          : [];
      sections['breaks'][component].add(new LogEntry()
        ..subject =
        "due to [${entry.hash.substring(0,8)}](${config.repoUrl}/commits/${entry.hash}),\n ${entry.breaks}"
        ..hash = entry.hash
        ..closes = []);
    }
  });
  StringBuffer content = new StringBuffer();

  //header
  content.write(
      '<a name="${config.version}">${config.appName}</a>\n# ${config.version} ${config.versionText} (${currentDate()})\n\n');

  sections.forEach((sectionName, Map section) {
    if (section.isNotEmpty) {
      writeSection(content, sectionName, sections[sectionName], config,
          printCommitLinks: true);
    }
  });

  return content.toString();
}

writeSection(
    StringBuffer content, String title, Map section, ChangelogConfig config,
    {printCommitLinks: false}) {
  var prefix = "-";

  content.write("\n## $title\n\n");
  section.forEach((component, List<LogEntry> entries) {
    bool nested = (section[component] as List).length > 1;

    if (component != 'Unknown') {
      if (nested) {
        content.write("- **$component:**\n");
        prefix = '  -';
      } else {
        prefix = '- **${component}:**';
      }
    }

    entries.forEach((entry) {
      if (printCommitLinks) {
        content.write(
            "$prefix ${entry.subject}\n  (${linkToCommit(entry.hash, config.repoUrl)}");
        if (entry.closes.length > 0) {
          content.write(
              ",\n closes: ${entry.closes.map((i) => linkToIssue(i, config.repoUrl)).join(', ')}");
        }
        content.write(")\n");
      } else {
        content.write("$prefix ${entry.subject}\n");
      }
    });
  });
  content.write("\n");
}

String linkToCommit(String hash, repoUrl) {
  return "[${hash.substring(0,8)}](${repoUrl}/commit/$hash)";
}

String linkToIssue(int issue, String repoUrl) {
  bool repoExist = repoUrl != null && repoUrl.isNotEmpty;
  return repoExist ? "[#${issue}](${repoUrl}/issues/$issue)" : "#issue";
}

String currentDate() {
  return new DateFormat('yyyy-MM-dd').format(new DateTime.now());
}
