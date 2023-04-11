import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart' hide Shell, menu;
import 'package:process_run/shell.dart';

class NativewitTemplateClone extends Command {
  NativewitTemplateClone() {
    // we can add command specific arguments here.
    // [argParser] is automatically created by the parent class.

    // --name="username" or -n username
    argParser.addOption('username', abbr: 'n', help: 'Provide your username');

    // // --name="organization" or -n organization
    // argParser.addOption('organization',
    //     abbr: 'o', help: 'Provide your organization name');

    // --authToken="authToken" or -a authToken
    argParser.addOption('authToken', abbr: 'a', help: 'Provide your authToken');
  }

  // The [name] and [description] properties must be defined by every
  // subclass.
  @override
  String get name => 'clone';

  @override
  String get description => 'Clone a flutter template repository';

  // [run] may also return a Future.
  @override
  Future<void> run() async {
    await gitClone();
  }

  Future<void> gitClone() async {
    final templateName = 'flutter_template';
    final tempPath = 'tempPath';
    final basePath = '$tempPath/$templateName';
    final outputPath = 'output/$templateName';

    final ArgResults results = argResults!;

    print(red('Nativewit Technologies\n'));

    // Username
    final String userName =
        results.wasParsed('username') ? results['username'] : ask('Username:');

    // Organization
    final String organization = 'nativewit';

    // authToken
    final String? authToken = results.wasParsed('authToken')
        ? results['authToken']
        : ask(
            'authToken:',
            required: true,
          );

    print(yellow('running...'));

    // Git clone command
    var shell = Shell();
    // final File tempPath = File((await getTemporaryDirectory()).path);

    // Create temporary path
    if (!exists(tempPath)) {
      createDir(tempPath);
    } else {
      deleteDir(tempPath);
    }

    // Template repo url
    final templateUrl =
        'https://$authToken@github.com/$organization/$templateName.git';

    // Git clone command
    await shell.run('''
       git clone $templateUrl $basePath
      ''');
    print('done, check output directory for result');

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
    final shareUtil = 'output/flutter_template/lib/utils/share_utils.dart';

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
    final bool addShareUtil = confirm('Add share util?', defaultValue: false);
    final bool addWeb = confirm('Add web?', defaultValue: false);
    final bool addMacos = confirm('Add macos?', defaultValue: false);
    final bool addWindows = confirm('Add windows?', defaultValue: false);
    final bool addLinux = confirm('Add linux?', defaultValue: false);
    // Check and create output dir
    if (!exists('output')) {
      createDir(outputPath, recursive: true);
    }

    for (final path in pathList) {
      // validate and create repo paths
      if (!exists('$outputPath/$path')) {
        if (isDirectory('$basePath/$path')) {
          createDir('$outputPath/$path', recursive: true);
          print('created $path');
        } else {
          print('$path is not dir');
        }
      } else {
        print('$path already exist');
      }

      // Moving from temp folder to output folder
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
    if (!addWeb) {
      delete(web);
    }
    if (!addMacos) {
      delete(macos);
    }
    if (!addLinux) {
      delete(linux);
    }
    if (!addWindows) {
      delete(windows);
    }
    if (!addShareUtil) {
      delete(shareUtil);
    }
    // Delete tempPath folder
    deleteDir('tempPath');
  }
}
