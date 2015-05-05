// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library changelog.example;

import 'package:changelog/changelog.dart';

main() async {
  Opts opts = new Opts();

  List<LogEntry> entries = await getLogEntries(opts, workingDir: '~/tmp/angular.io/router');

  entries.forEach(print);
}

final closesStr = """
13f31602f396bc269076ab4d389cfd8ca94b20ba
feat(ng-list): Allow custom separator
bla bla bla

Closes #123, #158
Closes #25
==END==
13f31602f396bc269076ab4d389cfd8ca94b20ba
fix(ng-lists): Allows custom separator
bla bla bla

Closes #77, #770
Closes #66
==END==
13f31602f396bc269076ab4d389cfd8ca94b20ba
merge(qwe): asd

==END==
13f31602f396bc269076ab4d389cfd8ca94b20ba
mergez
""";