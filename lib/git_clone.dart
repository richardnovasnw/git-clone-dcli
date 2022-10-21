#! /usr/bin/env dcli

import 'dart:convert';
import 'dart:io';

import 'package:dcli/dcli.dart' hide Shell, menu;
import 'package:http/http.dart' as http;
import 'package:process_run/shell.dart';

import 'menu_select.dart';

Future<void> gitClone(List<String> args) async {
  var baseUrl = 'https://api.github.com';

  // Add arg
  final ArgParser parser = ArgParser();

  // --name="username" or -n username
  parser.addOption('username', abbr: 'n', help: 'Provide your username');

  // --name="organization" or -n organization
  parser.addOption('organization',
      abbr: 'o', help: 'Provide your organization name');

  // --authToken="authToken" or -a authToken
  parser.addOption('authToken', abbr: 'a', help: 'Provide your authToken');

  // --help or -h
  parser.addFlag('help',
      abbr: 'h', help: 'Print out usage instructions', negatable: false);

  final ArgResults results = parser.parse(args);

  // Help
  if (results.wasParsed('help')) {
    print(parser.usage);
    exit(0);
  }

  print('🚀Github Cloner🚀\n');

  // Username
  final String userName =
      results.wasParsed('username') ? results['username'] : ask('Username:');

  // Organization
  final String? organization = results.wasParsed('organization')
      ? results['organization']
      : ask(
          'Organization name (${grey('Tap enter to continue without Organization')}):',
          required: false,
        );

  // authToken
  final String? authToken = results.wasParsed('authToken')
      ? results['authToken']
      : ask(
          'authToken (${grey('Tap enter to continue without authToken')}):',
          required: false,
        );

  // auth headers
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (authToken?.isNotEmpty ?? false) 'Authorization': 'Bearer $authToken'
  };

  // For Individual user
  // maximum 100 repo
  var user = await http.get(
    Uri.parse('$baseUrl/users/$userName/repos?per_page=100'),
    headers: headers,
  );

  // For organization
  var org = await http.get(
    Uri.parse('$baseUrl/orgs/$organization/repos?per_page=100'),
    headers: headers,
  );

  final response = (organization?.isEmpty ?? false) ? user : org;

  print(yellow('Your github repositories 👇'));

  // To list repositories
  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(response.body);

    List<Repository> repo = <Repository>[];

    for (var i = 0; i < jsonResponse.length; i++) {
      var cloneUrl = jsonResponse[i]['clone_url'];
      var repoName = jsonResponse[i]['name'];
      repo.add(Repository(repoName, cloneUrl));
    }

    // select by entering a number from the numerical list
    final selected = menu(
      prompt: green('\nEnter repository no :'),
      options: repo,
    );

    // To show the selected repo url
    print(green('You choose ${selected.url}'));

    // Git clone command
    var shell = Shell();
    await shell.run('''
     git clone ${selected.url} output/${selected.name}
    ''');

    print('done, check output directory for result');
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
}

class Repository {
  final String url;
  final String name;

  Repository(this.name, this.url);
}
