class LogEntry {
  String hash;
  String type;
  String subject;
  String component;
  List<int> closes = [];
  List<String> breaks = [];

  toString() =>
      "hash: $hash, type: $type, subject: $subject, component: $component,  closes: $closes";
}
