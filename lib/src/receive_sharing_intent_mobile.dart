import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../receive_sharing_intent.dart';

class ReceiveSharingIntentMobile extends ReceiveSharingIntent {
  @visibleForTesting
  final mChannel = const MethodChannel('receive_sharing_intent/messages');

  @visibleForTesting
  final eChannelMedia =
      const EventChannel("receive_sharing_intent/events-media");

  static const EventChannel _eChannelText =
      const EventChannel("receive_sharing_intent/events-text");

  static Stream<List<SharedMediaFile>>? _streamMedia;
  static Stream<String>? _streamText;

  @override
  Future<List<SharedMediaFile>> getInitialMedia() async {
    final json = await mChannel.invokeMethod('getInitialMedia');
    if (json == null) return [];
    final encoded = jsonDecode(json);
    return encoded
        .map<SharedMediaFile>((file) => SharedMediaFile.fromMap(file))
        .toList();
  }

  @override
  Stream<List<SharedMediaFile>> getMediaStream() {
    if (_streamMedia == null) {
      final stream = Platform.isAndroid
          ? eChannelMedia.receiveBroadcastStream('media').cast<String?>()
          : eChannelMedia.receiveBroadcastStream().cast<String?>();
      _streamMedia = stream.transform<List<SharedMediaFile>>(
        StreamTransformer<String?, List<SharedMediaFile>>.fromHandlers(
          handleData: (data, sink) {
            if (data == null) {
              sink.add(<SharedMediaFile>[]);
            } else {
              final encoded = jsonDecode(data);
              sink.add(encoded
                  .map<SharedMediaFile>((file) => SharedMediaFile.fromMap(file))
                  .toList());
            }
          },
        ),
      );
    }
    return _streamMedia!;
  }

  @override
  Stream<String> getTextStream() {
    if (_streamText == null) {
      _streamText = _eChannelText.receiveBroadcastStream('text').cast<String>();
    }
    return _streamText!;
  }

  @override
  Stream<Uri> getTextStreamAsUri() {
    return getTextStream().transform<Uri>(
      new StreamTransformer<String, Uri>.fromHandlers(
        handleData: (String data, EventSink<Uri> sink) {
          sink.add(Uri.parse(data));
        },
      ),
    );
  }

  @override
  Future<String> getInitialText() async {
    final initialText = await mChannel.invokeMethod('getInitialText');
    return initialText;
  }

  @override
  Future<dynamic> reset() {
    return mChannel.invokeMethod('reset');
  }
}
