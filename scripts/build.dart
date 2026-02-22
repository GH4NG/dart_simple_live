// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

class PlatformConfig {
  final String name;
  final List<String> targets;
  final List<String> buildArgs;

  PlatformConfig({
    required this.name,
    required this.targets,
    this.buildArgs = const [],
  });
}

/// Platform configurations
final platformConfigs = {
  'windows': PlatformConfig(
    name: 'windows',
    targets: ['exe', 'msix', 'zip'],
  ),
  'macos': PlatformConfig(
    name: 'macos',
    targets: ['dmg', 'zip'],
  ),
  'linux': PlatformConfig(
    name: 'linux',
    targets: ['deb', 'zip'],
  ),
  'android': PlatformConfig(
    name: 'android',
    targets: ['apk'],
    buildArgs: ['split-per-abi'],
  ),
  'ios': PlatformConfig(
    name: 'ios',
    targets: ['ipa'],
    buildArgs: ['no-codesign'],
  ),
};

const String artifactName =
    '{{name}}-{{platform}}-{{build_name}}{{#channel}}-{{channel}}{{/channel}}.{{ext}}';

/// Entry point for the build script
/// Usage:
///   dart build.dart linux                # Build all linux targets
///   dart build.dart windows              # Build all windows targets
///   dart build.dart macos                # Build all macos targets
///   dart build.dart android              # Build all android targets
///   dart build.dart ios                  # Build all ios targets

Future<void> main(List<String> args) async {
  try {
    final platform = args.firstWhere(
      (arg) => !arg.startsWith('-'),
      orElse: () => '',
    );

    if (!platformConfigs.containsKey(platform)) {
      print('Error: Unknown platform "$platform"');
      print('Available platforms: ${platformConfigs.keys.join(", ")}');
      exit(1);
    }

    await _buildPlatform(platformConfigs[platform]!);
    print('Build completed successfully.');
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

Future<void> _buildPlatform(PlatformConfig config) async {
  print('==> Building for platform: ${config.name}');

  print('--> Building targets: ${config.targets.join(', ')}');

  final channel = Platform.environment['CHANNEL']?.trim();
  await _run('fastforge', [
    'package',
    '--platform',
    config.name,
    '--targets',
    config.targets.join(','),
    if (channel != null && channel.isNotEmpty) ...[
      '--channel',
      channel,
    ],
    '--artifact-name',
    artifactName,
    if (config.buildArgs.isNotEmpty)
      '--flutter-build-args=${config.buildArgs.join(' ')}',
  ]);
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
