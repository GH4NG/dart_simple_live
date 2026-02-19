import 'package:flutter/material.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/app/log.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> function1() async {
      try {
        const msg = '测试功能一';
        SmartDialog.showToast(msg);
        SimpleLiveLogger().d(msg);

        throw Exception('测试功能一异常');
      } catch (e, st) {
        SimpleLiveLogger().e('测试功能一发生异常', error: e, stackTrace: st);
      }
    }

    void function2() {
      SmartDialog.showToast('测试功能二');
      SimpleLiveLogger().d('测试功能二');
    }

    void function3() {
      SmartDialog.showToast('测试功能三');
      SimpleLiveLogger().d('测试功能三');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('功能测试页'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: function1,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('测试功能一'),
            ),
            AppStyle.hGap16,
            ElevatedButton.icon(
              onPressed: function2,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('测试功能二'),
            ),
            AppStyle.hGap16,
            ElevatedButton.icon(
              onPressed: function3,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('测试功能三'),
            ),
          ],
        ),
      ),
    );
  }
}
