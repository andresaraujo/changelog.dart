part of changelog;

class ChangelogConfig {
  String grep = '^feat|^fix|^docs|BREAKING';
  String format = '%H%n%s%n%b%n==END==';
  String from = '';
  String to = 'HEAD';

  Map sections = {};

  ChangelogConfig() {
    sections['Documentation'] = ['doc', 'docs'];
    sections['Features'] = ['ft', 'feat'];
    sections['Bug Fixes'] = ['fx', 'fix'];
    sections['Unknown'] = ['unk'];
    sections['Breaks'] = [];
  }
  getSectionFor(String alias) {
    for (var key in sections.keys) {
      if (sections[key].contains(alias)) {
        return key;
      }
    }
    return 'Unknown';
  }
}
