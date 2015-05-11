part of changelog;

const  EMPTY_COMPONENT     = '\$\$';

writeChangelog(io.File file, List<LogEntry> entries, ChangelogConfig config) {
  Map sections = {};

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
  content.write('<a name="${config.version}">${config.appName}</a>\n# ${config.version} ${config.versionText} (${currentDate()})\n\n');

  sections.forEach((sectionName, Map section) {
    if(section.isNotEmpty) {
      writeSection(content, sectionName, sections[sectionName], config, printCommitLinks: true);
    }
  });

  file.writeAsStringSync(content.toString(), mode: io.FileMode.APPEND);
}

writeSection(StringBuffer content, String title, Map section, ChangelogConfig config, {printCommitLinks : false}) {

  var prefix = "-";

  content.write("\n## $title\n\n");
  section.forEach((component, List<LogEntry> entries) {
    bool nested = (section[component] as List).length > 1;

    if(component != 'Unknown') {
      if(nested) {
        content.write("- **$component:**\n");
        prefix = '  -';
      }else {
        prefix = '- **${component}:**';
      }
    }

    entries.forEach((entry) {
      if(printCommitLinks){
        content.write("$prefix ${entry.subject}\n  (${linkToCommit(entry.hash, config.repoUrl)}");
        if(entry.closes.length > 0) {
          content.write(",\n   ${entry.closes.join(', ')}");
        }
        content.write(")\n");
      }else {
        content.write("$prefix ${entry.subject}\n");
      }
    });
  });
  content.write("\n");
}

String linkToCommit(String hash, repoUrl) {
  return "[${hash.substring(0,8)}](${repoUrl}/commits/$hash)";
}

String currentDate() {
  return new DateFormat('yyyy-MM-dd').format(new DateTime.now());
}