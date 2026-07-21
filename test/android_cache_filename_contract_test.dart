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
      contains('"bfshare-\${UUID.randomUUID()}-\$safeFileName"'),
    );
    expect(fileDirectory, contains('"shared-image\$extension"'));
    expect(fileDirectory, contains('"shared-video\$extension"'));
    expect(fileDirectory, contains('"shared-file\$extension"'));
    expect(
      fileDirectory,
      isNot(contains('File(context.cacheDir, fileName)')),
    );
    expect(plugin, contains('UUID.randomUUID()'));
    expect(plugin, contains('import java.util.UUID'));
    expect(
      plugin,
      contains(
        '"bfshare-\${UUID.randomUUID()}-thumbnail-\${File(path).name}.png"',
      ),
    );
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
