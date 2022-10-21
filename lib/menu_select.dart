/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:math';

import 'package:dcli/dcli.dart';

import 'git_clone.dart';

Repository _noFormat<Repository>(Repository option) => option;

/// Displays a menu with each of the provided [options], prompts
/// the user to select an option and returns the selected option.
///
/// e.g.
/// ```dart
/// var colors = [Color('Red'), Color('Green')];
/// var color = menu( 'Please select a color', options: colors);
/// ```
/// Results in:
///```
/// 1) Red
/// 2) Green
/// Please select a color:
/// ```
///
/// [menu] will display an error if the user enters a non-valid
/// response and then redisplay the prompt.
///
/// Once a user selects a valid option, that option is returned.
///
/// You may provide a [limit] which will cause the
/// menu to only display the first [limit] options passed.
///
/// If you pass a [format] lambda then the [format] function
/// will be called for for each option and the resulting format
/// used to display the option in the menu.
///
/// e.g.
/// ```dart
///
/// var colors = [Color('Red'), Color('Green')];
/// var color = menu(prompt: 'Please select a color'
///   , options: colors, format: (color) => color.name);
/// ```
///
/// If [format] is not passed [option.toString()] will be used
/// as the format for the menu option.
///
/// When a [limit] is applied the menu will display the first [limit]
/// options. If you specify [fromStart: false] then the menu will display the
/// last [limit] options.
///
/// If you pass a [defaultOption] the matching option is highlighted
/// in green in the menu
/// and if the user hits enter without entering a value the [defaultOption]
/// is returned.
///
/// If the [defaultOption] does not match any the supplied [options]
/// then an ArgumentError is thrown.
///
/// If the app is not attached to a terminal then the menu will not be
/// displayed and the [defaultOption] will be returned.
/// If there is no [defaultOption] then the first [options] will be returned.
///
Repository menu<T>({
  required String prompt,
  required List<Repository> options,
  Repository? defaultOption,
  int? limit,
  Repository Function(Repository)? format,
  bool fromStart = true,
}) {
  if (options.isEmpty) {
    throw ArgumentError(
      'The list of [options] passed to menu(options: ) was empty.',
    );
  }
  limit ??= options.length;
  // ignore: parameter_assignments
  limit = min(options.length, limit);
  format ??= _noFormat;

  if (!Terminal().hasTerminal) {
    if (defaultOption == null) {
      return options.first;
    }
    return defaultOption;
  }

  var displayList = options;
  if (fromStart == false) {
    // get the last [limit] options
    displayList = options.sublist(min(options.length, options.length - limit));
  }

  // on the way in we check that the default value acutally exists in the list.
  String? defaultIndex;
  // display each option.
  for (var i = 1; i <= limit; i++) {
    final option = displayList[i - 1];

    if (option == defaultOption) {
      defaultIndex = i.toString();
    }
    final desc = format(option);
    final no = '$i'.padLeft(3);
    if (defaultOption != null && defaultOption == option) {
      /// highlight the default value.
      print(green('$no) ${desc.name}'));
    } else {
      print(blue('$no) ${desc.name}'));
    }
  }

  if (defaultOption != null && defaultIndex == null) {
    throw ArgumentError(
      "The [defaultOption] ${defaultOption.toString()} doesn't match any "
      'of the passed [options].'
      ' Check the == operator for ${options[0].runtimeType}.',
    );
  }

  var valid = false;

  var index = -1;

  // loop until the user enters a valid selection.
  while (!valid) {
    final selected =
        ask(prompt, defaultValue: defaultIndex, validator: _MenuRange(limit));
    if (selected.isEmpty) {
      continue;
    }
    valid = true;
    index = int.parse(selected);
  }

  return options[index - 1];
}

class _MenuRange extends AskValidator {
  const _MenuRange(this.limit);
  @override
  String validate(String line) {
    final finalline = line.trim();
    final value = num.tryParse(finalline);
    if (value == null) {
      throw AskValidatorException(
        red('Value must be an integer from 1 to $limit'),
      );
    }

    if (value < 1 || value > limit) {
      throw AskValidatorException('Invalid selection.');
    }

    return finalline;
  }

  final int limit;
}
