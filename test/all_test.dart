// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library changelog.test;

import 'package:test/test.dart';
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
  });
}
