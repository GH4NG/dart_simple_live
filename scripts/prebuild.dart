// ignore_for_file: avoid_print

import 'dart:io';

Future<void> main() async {
  try {
    if (Platform.isLinux) {
      await _prepareLinux();
    } else if (Platform.isWindows) {
      await _prepareWindows();
    } else if (Platform.isMacOS) {
      await _prepareMacOS();
    } else {
      stderr.writeln('Unsupported platform: ${Platform.operatingSystem}');
      exit(1);
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

Future<void> _prepareLinux() async {
  print('==> Preparing dependencies for Linux');

  await _run('sudo', ['apt-get', 'update']);

  await _run('sudo', [
    'apt-get',
    'install',
    '-y',
    'ninja-build',
    'libgtk-3-dev',
    'libmpv-dev',
    'patchelf',
    'cmake',
    'clang',
    'libfuse2',
    'pkg-config',
    'liblzma-dev',
    'mpv',
    'libasound2-dev',
    'locate',
    'libc++1',
    'fuse',
    'lld',
    'binutils',
  ]);

  // Install AppImageTool
  await _run('wget', [
    '-O',
    'appimagetool',
    'https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage',
  ]);

  await _run('chmod', ['+x', 'appimagetool']);
  await _run('sudo', ['mv', 'appimagetool', '/usr/local/bin/appimagetool']);

  print('Linux dependencies ready.');
}

Future<void> _prepareWindows() async {
  print('==> Preparing dependencies for Windows');

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

  print('Windows dependencies ready.');
}

Future<void> _prepareMacOS() async {
  print('==> Preparing dependencies for macOS');

  await _run('npm', ['install', '-g', 'appdmg']);

  print('macOS dependencies ready.');
}

Future<void> _run(String command, List<String> args) async {
  print('> $command ${args.join(' ')}');

  final result = await Process.run(
    command,
    args,
    runInShell: true,
    stdoutEncoding: const SystemEncoding(),
    stderrEncoding: const SystemEncoding(),
  );

  if (result.stdout.toString().isNotEmpty) {
    stdout.write(result.stdout);
  }

  if (result.stderr.toString().isNotEmpty) {
    stderr.write(result.stderr);
  }

  if (result.exitCode != 0) {
    throw ProcessException(
      command,
      args,
      result.stderr.toString(),
      result.exitCode,
    );
  }
}
