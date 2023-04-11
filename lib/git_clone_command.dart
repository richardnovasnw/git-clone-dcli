import 'dart:convert';

import 'package:args/command_runner.dart';
import 'package:dartcli/menu_select.dart';
import 'package:dcli/dcli.dart' hide Shell, menu;
import 'package:http/http.dart' as http;
import 'package:process_run/shell.dart';

class CloneCommand extends Command {
  CloneCommand() {
    // we can add command specific arguments here.
    // [argParser] is automatically created by the parent class.

    // --name="username" or -n username
    argParser.addOption('username', abbr: 'n', help: 'Provide your username');

    // --name="organization" or -n organization
    argParser.addOption('organization',
        abbr: 'o', help: 'Provide your organization name');

    // --authToken="authToken" or -a authToken
    argParser.addOption('authToken', abbr: 'a', help: 'Provide your authToken');
  }

  // The [name] and [description] properties must be defined by every
  // subclass.
  @override
  String get name => 'clone';

  @override
  String get description => 'Clone a git repository';

  // [run] may also return a Future.
  @override
  Future<void> run() async {
    await gitClone();
  }

  Future<void> gitClone() async {
    var baseUrl = 'https://api.github.com';

    final ArgResults results = argResults!;

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
      // final File tempPath = File((await getTemporaryDirectory()).path);

      if (!exists('tempPath')) {
        createDir('tempPath');
      } else {
        deleteDir('tempPath');
      }
      await shell.run('''
       git clone ${selected.url} tempPath/${selected.name}
      ''');
      print('done, check output directory for result');
      final basePath = 'tempPath/${selected.name}';
      final outputPath = 'output/${selected.name}';

      // cat('$basePath/lib/main.dart');

      final androidPath = 'android';
      final iosPath = 'ios';
      final integrationTest = 'integration_test';
      final pubspecYaml = 'pubspec.yaml';
      final pubspecLock = 'pubspec.lock';
      final readme = 'README.md';
      final analysisOptions = 'analysis_options.yaml';
      final metadata = '.metadata';
      final utils = 'utils';
      final test = 'test';
      final lib = 'lib';
      final macos = 'macos';
      final windows = 'windows';
      final linux = 'linux';
      final web = 'web';

      final pathList = [
        androidPath,
        iosPath,
        integrationTest,
        pubspecLock,
        pubspecYaml,
        readme,
        analysisOptions,
        // metadata,
        utils,
        test,
        macos,
        windows,
        linux,
        web,
        lib,
      ];
      if (!exists('output')) {
        createDir(outputPath, recursive: true);
      }
      for (final path in pathList) {
        if (!exists(
          '$outputPath/$path',
        )) {
          if (isDirectory('$basePath/$path')) {
            createDir('$outputPath/$path', recursive: true);
            print('created $path');
          } else {
            print('$path is not dir');
          }
        } else {
          print('$path already exist');
        }
        if (isFile(path)) {
          move(
            '$basePath/$path',
            '$outputPath/$path',
            overwrite: true,
          );
          print('$path file moved');
        } else {
          moveTree(
            '$basePath/$path',
            '$outputPath/$path',
            overwrite: true,
          );
          print('$path dir moved');
        }
      }
      deleteDir('tempPath');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }
}

class Repository {
  final String url;
  final String name;

  Repository(this.name, this.url);
}
