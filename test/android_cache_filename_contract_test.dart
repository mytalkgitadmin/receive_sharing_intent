import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android cache copies and video thumbnails use collision-free names',
      () {
    final fileDirectory = File(
      'android/src/main/kotlin/com/kasem/receive_sharing_intent/FileDirectory.kt',
    ).readAsStringSync();
    final plugin = File(
      'android/src/main/kotlin/com/kasem/receive_sharing_intent/ReceiveSharingIntentPlugin.kt',
    ).readAsStringSync();

    expect(fileDirectory, contains('UUID.randomUUID()'));
    expect(
      fileDirectory,
      isNot(contains('File(context.cacheDir, fileName)')),
    );
    expect(plugin, contains('UUID.randomUUID()'));
    expect(plugin, contains('import java.util.UUID'));
    expect(
      plugin,
      isNot(
        contains(
          'File(applicationContext.cacheDir, "\${File(path).name}.png")',
        ),
      ),
    );
  });
}
