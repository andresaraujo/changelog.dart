part of changelog;

class LogEntry {
  String hash;
  String type;
  String subject;
  String component;
  String body;
  List<int> closes = [];
  String breaks;

  toString() =>
      "hash: $hash, type: $type, subject: $subject, component: $component, body: $body, closes: $closes";
}
