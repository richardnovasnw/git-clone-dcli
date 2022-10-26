#! /usr/bin/env dcli

import 'package:args/command_runner.dart';
import 'package:dartcli/git_clone_command.dart';

Future<void> main(List<String> args) async {
  final runner = CommandRunner('dgit', 'dcli git')..addCommand(CloneCommand());
  await runner.run(args);
}
