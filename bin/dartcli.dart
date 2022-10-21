#! /usr/bin/env dcli

import 'package:dartcli/git_clone.dart' as git;

void main(List<String> arguments) {
  // n.runBrowser('https://google.com');
  git.gitClone(arguments);
}
