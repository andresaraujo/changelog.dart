// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library changelog.test;

import 'dart:async';
import 'package:test/test.dart';
import 'package:mockable_filesystem/mock_filesystem.dart';
import 'package:changelog/changelog.dart';

main() {
  ChangelogConfig opts = new ChangelogConfig();
  group("Parse", (){

    test("parseRawCommit should be null when invalid string", () {
      var commit = parseRawCommit("", opts);
      expect(commit, isNull);
    });

    test("should parse a raw commit", () {

      var msg = '''9b1aff905b638aa274a5fc8f88662df446d374bd
      feat(scope): broadcast \$destroy event on scope destruction
      perf testing shows that in chrome this change adds 5-15% overhead
      when destroying 10k nested scopes where each scope has a \$destroy listener''';

      var commit = parseRawCommit(msg, opts);
      expect(commit, isNotNull);
      expect(commit.type, equals('Features'));
      expect(commit.hash, equals('9b1aff905b638aa274a5fc8f88662df446d374bd'));
      expect(commit.subject, equals('broadcast \$destroy event on scope destruction'));
      expect(commit.body, equals('perf testing shows that in chrome this change adds 5-15% overhead\n' +
      'when destroying 10k nested scopes where each scope has a \$destroy listener'));
    });

    test("should parse closed issues", () {

      var msg = '''13f31602f396bc269076ab4d389cfd8ca94b20ba
      feat(ng-list): Allow custom separator
      bla bla bla
      Closes #123
      Closes #25
      ''';

      var commit = parseRawCommit(msg, opts);
      expect(commit, isNotNull);
      expect(commit.closes[0], 123);
      expect(commit.closes[1], 25);
    });

    test("should parse breaking changes", () {

      var msg = '''13f31602f396bc269076ab4d389cfd8ca94b20ba
      feat(ng-list): Allow custom separator
      bla bla bla

      BREAKING CHANGE: first breaking change
      something else

      another line with more info
      ''';

      var commit = parseRawCommit(msg, opts);
      expect(commit, isNotNull);
      expect(commit.breaks, 'first breaking change\nsomething else\n\nanother line with more info\n');
    });
  });

  group("writer", () {
    var config = new ChangelogConfig()
    ..repoUrl = "https://github.com/user"
    ..version = "0.1.0"
    ..versionText = "deceptive peanut"
    ..appName = "myApp";

    setUp(() {
      fileSystem = new MockFileSystem();
    });

    test('should create a section', () {
      var sectionTitle = "Features";
      var entries = getSampleEntries('writer').where((i) => i.type == 'Features').toList();

      var section = {
        'writer': entries
      };
      var result = new StringBuffer();
      writeSection(result, sectionTitle, section, config, printCommitLinks: false);

      expect(result.toString(), '\n## Features\n\n- **writer:**\n'+
      '  - broadcast \$destroy event on scope destruction\n' +
      '  - broadcast \$destroy event on scope destruction\n\n');
    });

    test('should create a section with commit links', () {
      var sectionTitle = "Features";
      var entries = getSampleEntries('writer').where((i) => i.type == 'Features').toList();

      var section = {
        'writer': entries
      };

      var result = new StringBuffer();
      writeSection(result, sectionTitle, section, config, printCommitLinks: true);

      expect(result.toString(), '\n## Features\n\n- **writer:**\n'+
      '  - broadcast \$destroy event on scope destruction\n' +
      '  ([9b1aff90](https://github.com/user/commits/9b1aff905b638aa274a5fc8f88662df446d374bd),\n'
      ' closes: [#200](https://github.com/user/issues/200), [#58](https://github.com/user/issues/58))\n'
      '  - broadcast \$destroy event on scope destruction\n' +
      '  ([9b1aff90](https://github.com/user/commits/9b1aff905b638aa274a5fc8f88662df446d374bd))\n\n');
    });

    test('write', () {
      var f = fileSystem.getFile('/CHANGELOG.md');
      expect(f, isNotNull);
      expect(f.existsSync(), isFalse);

      writeChangelog(f, getSampleEntries("comp"), config);

      expect(f.existsSync(), isTrue);
      expect(f.readAsStringSync(),
      '<a name="0.1.0">myApp</a>\n' +
      '# 0.1.0 deceptive peanut (${currentDate()})\n' +
      '\n\n## Features\n\n'+
      '- **comp_1:** broadcast \$destroy event on scope destruction\n' +
      '  ([9b1aff90](https://github.com/user/commits/9b1aff905b638aa274a5fc8f88662df446d374bd),\n' +
      ' closes: [#200](https://github.com/user/issues/200), [#58](https://github.com/user/issues/58))\n' +
      '- **comp_2:** broadcast \$destroy event on scope destruction\n' +
      '  ([9b1aff90](https://github.com/user/commits/9b1aff905b638aa274a5fc8f88662df446d374bd))\n\n\n' +
      '## Bug Fixes\n\n' +
      '- **comp_3:** broadcast \$destroy event on scope destruction\n' +
      '  ([9b1aff90](https://github.com/user/commits/9b1aff905b638aa274a5fc8f88662df446d374bd))\n' +
      '\n');
    });
  });
}

List<LogEntry> getSampleEntries(String component) {
  int count = 1;
  LogEntry commit = new LogEntry()
  ..type = 'Features'
  ..hash = '9b1aff905b638aa274a5fc8f88662df446d374bd'
  ..component = '${component}_${count++}'
  ..closes = [200, 58]
  ..subject = 'broadcast \$destroy event on scope destruction'
  ..body = 'perf testing shows that in chrome this change adds 5-15% overhead\n' +
  'when destroying 10k nested scopes where each scope has a \$destroy listener';

  LogEntry commit2 = new LogEntry()
    ..type = 'Features'
    ..hash = '9b1aff905b638aa274a5fc8f88662df446d374bd'
    ..component = '${component}_${count++}'
    ..subject = 'broadcast \$destroy event on scope destruction'
    ..body = 'perf testing shows that in chrome this change adds 5-15% overhead\n' +
  'when destroying 10k nested scopes where each scope has a \$destroy listener';

  LogEntry commit3 = new LogEntry()
    ..type = 'Bug Fixes'
    ..hash = '9b1aff905b638aa274a5fc8f88662df446d374bd'
    ..component = '${component}_${count++}'
    ..subject = 'broadcast \$destroy event on scope destruction'
    ..body = 'perf testing shows that in chrome this change adds 5-15% overhead\n' +
  'when destroying 10k nested scopes where each scope has a \$destroy listener';

  return [commit, commit2, commit3];
}