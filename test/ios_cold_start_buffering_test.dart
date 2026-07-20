import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// iOS cold start에서는 application(open:)이 Dart stream listener 등록보다
/// 먼저 호출될 수 있다. 이때 공유 데이터를 initialMedia에 보존해야 메인
/// 화면이 준비된 뒤 getInitialMedia()로 이어서 처리할 수 있다.
void main() {
  test('listener가 없으면 application(open:) 데이터를 initial media로 보존한다',
      () {
    final source = File(
      'ios/Classes/SwiftReceiveSharingIntentPlugin.swift',
    ).readAsStringSync();

    expect(source, contains('let shouldStoreAsInitialMedia = eventSinkMedia == nil'));
    expect(
      source,
      contains('handleUrl(url: url, setInitialData: shouldStoreAsInitialMedia)'),
    );
  });

  test('공유 URL 전체를 진단 로그로 출력하지 않는다', () {
    final source = File(
      'ios/Classes/SwiftReceiveSharingIntentPlugin.swift',
    ).readAsStringSync();
    final logLines = source.split('\n').where(
          (line) => line.contains('print(') || line.contains('NSLog('),
        );

    expect(logLines, isNot(anyElement(contains('url.absoluteString'))));
  });
}
