#! /usr/bin/env dcli

import 'package:args/command_runner.dart';
import 'package:dartcli/nativewit_template_clone.dart';

Future<void> main(List<String> args) async {
  // final runner = CommandRunner('dgit', 'dcli git')..addCommand(CloneCommand());
  final nativewit = CommandRunner('nativewit', 'nativewit git')
    ..addCommand(NativewitTemplateClone());
  // await runner.run(args);
  await nativewit.run(args);
}
