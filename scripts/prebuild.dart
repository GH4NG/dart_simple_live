// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Entry point for the prebuild script
/// Usage:
///   dart prebuild.dart linux                # Prepare dependencies for linux
///   dart prebuild.dart windows              # Prepare dependencies for windows
///   dart prebuild.dart macos                # Prepare dependencies for macos
///   dart prebuild.dart android              # Prepare dependencies for android
///   dart prebuild.dart ios                  # Prepare dependencies for ios

Future<void> main(List<String> args) async {
  try {
    final platform = args.firstWhere(
      (arg) => !arg.startsWith('-'),
      orElse: () => '',
    );
    switch (platform) {
      case 'linux':
        await _prepareLinux();
        break;
      case 'windows':
        await _prepareWindows();
        break;
      case 'macos':
        await _prepareMacOS();
        break;
      case 'android':
        break;
      case 'ios':
        break;
      default:
        _fail('Unsupported platform: ${Platform.operatingSystem}');
    }

    await _run('flutter', ['pub', 'get']);

    print('All dependencies prepared successfully.');
  } catch (e, st) {
    stderr
      ..writeln('Dependency preparation failed.')
      ..writeln(e)
      ..writeln(st);
    exit(1);
  }
}

void _fail(String message) {
  stderr.writeln(message);
  exit(1);
}

Future<void> _prepareLinux() async {
  print('\n==> Preparing dependencies for Linux\n');

  await _run('sudo', [
    'pacman',
    '-Syu',
    '--noconfirm',
  ]);

  await _run('sudo', [
    'pacman',
    '-S',
    '--noconfirm',
    'gtk3',
    'libsecret',
    'gnome-keyring',
    'wpewebkit',
    'mpv',
    'dpkg',
    'pkgconf',
    'fuse2',
  ]);

  // // Install AppImageTool
  // await _run('wget', [
  //   '-O',
  //   'appimagetool',
  //   'https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage',
  // ]);

  // await _run('chmod', ['+x', 'appimagetool']);
  // await _run('sudo', ['mv', 'appimagetool', '/usr/local/bin/appimagetool']);

  print('\nLinux dependencies ready.');
}

Future<void> _prepareWindows() async {
  print('\n==> Preparing dependencies for Windows\n');

  const source = r'windows\packaging\exe\ChineseSimplified.isl';
  const target =
      r'C:\Program Files (x86)\Inno Setup 6\Languages\ChineseSimplified.isl';

  await _run(
    'powershell',
    [
      '-NoProfile',
      '-ExecutionPolicy',
      'Bypass',
      '-Command',
      'Copy-Item "$source" "$target" -Force',
    ],
  );

  print('\nWindows dependencies ready.');
}

Future<void> _prepareMacOS() async {
  print('\n==> Preparing dependencies for macOS\n');

  await _run('npm', ['install', '-g', 'appdmg']);

  print('\nmacOS dependencies ready.');
}

Future<void> _run(String command, List<String> args) async {
  print('--> $command ${args.join(' ')}');

  final process = await Process.start(
    command,
    args,
    runInShell: true,
  );

  final stdoutFuture = () async {
    await for (final chunk in process.stdout.transform(utf8.decoder)) {
      stdout.write(chunk);
    }
  }();

  final stderrFuture = () async {
    await for (final chunk in process.stderr.transform(utf8.decoder)) {
      stderr.write(chunk);
    }
  }();

  final exitCode = await process.exitCode;

  await Future.wait([stdoutFuture, stderrFuture]);

  if (exitCode != 0) {
    throw ProcessException(
      command,
      args,
      'Command failed with exit code $exitCode\nStdout: ${stdout.toString()}\nStderr: ${stderr.toString()}',
      exitCode,
    );
  }
}
