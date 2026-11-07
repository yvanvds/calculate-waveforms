import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'audio.dart';

AudioOutput createAudioOutput() => BrowserAudioOutput();

class BrowserAudioOutput implements AudioOutput {
  web.AudioContext? _context;
  web.AudioBufferSourceNode? _source;
  bool _started = false;

  @override
  Future<void> play(
    Float32List samples,
    int rate,
    void Function() onEnded,
  ) async {
    stop();
    final context = _context ??= web.AudioContext();
    final buffer = context.createBuffer(1, samples.length, rate);
    buffer.copyToChannel(samples.toJS, 0);
    final source = context.createBufferSource()..buffer = buffer;
    _source = source;
    source.connect(context.destination);
    source.onended = ((web.Event event) {
      if (_source == source) {
        _source = null;
        source.disconnect();
        onEnded();
      }
    }).toJS;
    await context.resume().toDart;
    if (_source == source) {
      source.start();
      _started = true;
    }
  }

  @override
  void stop() {
    final source = _source;
    _source = null;
    if (source != null) {
      if (_started) source.stop();
      source.disconnect();
    }
    _started = false;
  }

  @override
  void dispose() {
    stop();
    _context?.close();
  }
}
