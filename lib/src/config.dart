part of changelog;

class ChangelogConfig {
  String grep = '^feat|^fix|^docs|BREAKING';
  String format = '%H%n%s%n%b%n==END==';
  String from = '';
  String to = 'HEAD';

  String appName = "";
  String version = "";
  String versionText = "";
  String repoUrl = "";

  Map _sections = {};

  ChangelogConfig() {
    _sections['Documentation'] = ['doc', 'docs'];
    _sections['Features'] = ['ft', 'feat'];
    _sections['Bug Fixes'] = ['fx', 'fix'];
    _sections['Unknown'] = ['unk'];
    _sections['Breaks'] = [];

    updateGrep();
  }

  updateGrep() {
    List<String> grep = [];
    for (List value in _sections.values) {
      for (var v in value) {
        if (!grep.contains(v)) {
          grep.add("^$v");
        }
      }
    }
    grep.add('BREAKING');
  }

  getSectionFor(String alias) {
    for (var key in _sections.keys) {
      if (_sections[key].contains(alias)) {
        return key;
      }
    }
    return 'Unknown';
  }

  addSection(String title, List<String> alias) {
    _sections[title] = alias != null ? alias : [];
    updateGrep();
  }
}
