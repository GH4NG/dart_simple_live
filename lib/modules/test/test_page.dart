import 'package:flutter/material.dart';
import 'package:simple_live_app/app/app_style.dart';
import 'package:simple_live_app/app/log.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> function1() async {
      const msg = '测试功能一';
      SmartDialog.showToast('测试功能一');
      Log.d(msg);
    }

    void function2() {
      SmartDialog.showToast('测试功能二');
      Log.d('测试功能二');
    }

    void function3() {
      SmartDialog.showToast('测试功能三');
      Log.d('测试功能三');
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
