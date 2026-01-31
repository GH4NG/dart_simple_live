// ignore_for_file: avoid_print

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
    targets: ['appimage', 'deb', 'zip'],
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
///   dart build.dart windows              # Build all windows targets
///   dart build.dart macos                # Build all macos targets
///   dart build.dart android              # Build all android targets
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
