library changelog.base;

import 'dart:io';
import 'package:git/git.dart' as git;
import 'package:changelog/src/logentry.dart';

RegExp commitPattern = new RegExp(r"^(.*)\((.*)\):(.*)");
RegExp commitAltPattern = new RegExp(r"^(.*):\s(.*)");
RegExp closesPattern = new RegExp(r"(?:Closes|Fixes|Resolves)\s((?:#(\d+)(?:,\s)?)+)");
RegExp closesIntPattern = new RegExp(r"\d+");

class Opts {
  String grep = '^feat|^fix|^docs|BREAKING';
  String format = '%H%n%s%n%b%n==END==';
  String from = '';
  String to = 'HEAD';

  Map sections = {};

  Opts() {
    sections['Documentation'] = ['doc', 'docs'];
    sections['Features'] = ['ft', 'feat'];
    sections['Bug Fixes'] = ['fx', 'fix'];
    sections['Unknown'] = ['unk'];
    sections['Breaks'] = [];
  }
  getSectionFor(String alias) {
    for(var key in sections.keys) {
      if(sections[key].contains(alias)){
        return key;
      }
    }
    return 'Unknown';
  }
}


getLogEntries(Opts opts, {String workingDir}) async {

  var range = opts.from == null || opts.from.isEmpty ? "HEAD" : "${opts.from}..${opts.to}";

  var arguments = [
    'log',
    '-E',
    '--grep=${opts.grep}',
    '--format=${opts.format}',
    '$range'];

  ProcessResult result = await git.runGit(arguments, processWorkingDir: workingDir);

  String out = result.stdout.toString();

  List<LogEntry> entries = out.split("\n==END==\n").map((raw) => parseRawCommit(raw, opts)).where((entry) => entry != null).toList();
  return entries;
}

LogEntry parseRawCommit(String raw, Opts opts) {
  if(raw == null || raw.isEmpty) {
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
        items.map((item) => closesIntPattern.firstMatch(item))
          .where((match) => match != null)
          .forEach((match) => entry.closes.add(int.parse(match[0])));
     });


  //Extract type, component, type
  var matcher = commitPattern.firstMatch(entry.subject);

  //If component doesn't exist
  if(matcher == null) {
    matcher = commitAltPattern.firstMatch(entry.subject);
    if(matcher == null) {
      print("Incorrect message: ${entry.hash} ${entry.subject}");
      entry.type = opts.getSectionFor("unk");
      return null;
    }
    entry.type = opts.getSectionFor(matcher[1].toLowerCase());
    entry.subject = matcher[2];

    return entry;
  }

  entry.type = opts.getSectionFor(matcher[1].toLowerCase());
  entry.component = matcher[2];
  entry.subject = matcher[3];

  return entry;
}

