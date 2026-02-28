// Copyright 2025 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart';

import 'a2ui_agent_connector.dart';
import 'package:genuidemo/log_cat.dart';

/// A content generator that connects to an A2UI server.
class A2uiContentGenerator implements ContentGenerator {
  /// Creates an [A2uiContentGenerator] instance.
  ///
  /// If optional `connector` is not supplied, then one will be created with the
  /// given `serverUrl`.
  A2uiContentGenerator({required Uri serverUrl, A2uiAgentConnector? connector})
    : connector = connector ?? A2uiAgentConnector(url: serverUrl) {
    this.connector.errorStream.listen((Object error) {
      _errorResponseController.add(
        ContentGeneratorError(error, StackTrace.current),
      );
    });
  }

  final A2uiAgentConnector connector;
  final _textResponseController = StreamController<String>.broadcast();
  final _errorResponseController =
      StreamController<ContentGeneratorError>.broadcast();
  final _isProcessing = ValueNotifier<bool>(false);

  @override
  Stream<A2uiMessage> get a2uiMessageStream => connector.stream;

  @override
  Stream<String> get textResponseStream => _textResponseController.stream;

  @override
  Stream<ContentGeneratorError> get errorStream =>
      _errorResponseController.stream;

  @override
  ValueListenable<bool> get isProcessing => _isProcessing;

  @override
  void dispose() {
    _textResponseController.close();
    connector.dispose();
    _isProcessing.dispose();
  }

  @override
  Future<void> sendRequest(
    ChatMessage message, {
    Iterable<ChatMessage>? history,
    A2UiClientCapabilities? clientCapabilities,
  }) async {
    _isProcessing.value = true;
    try {
      logCat.info("sendRequest>>>>>>>>>>>>>>>>>>");
      if (history != null && history.isNotEmpty) {
        genUiLogger.warning(
          'A2uiContentGenerator is stateful and ignores history.',
        );
      }

      final String responseText = "version: \"1.0\"\ngroups:\n  app:\n    app_transport: \"serial\"\n    app_codec: \"frame_codec\"\n    app_transformer: \"disable\"\n    app_lua_script_enabled: true\n    app_encoding: \"UTF-8\"\n  serial:\n    serial_requires_codec: true\n    serial_port: \"/dev/ttyS0\" # Update if your serial port is different\n    serial_baud_rate: 9600\n    serial_data_bits: 8\n    serial_parity: \"none\"\n    serial_stop_bits: \"1\"\n    serial_flow_control: \"none\"\n  frame_codec:\n    frame_codec_prefix: \"42 4d\"\n    frame_codec_header_size: 0\n    frame_codec_length_mode: \"u16_be\"\n    frame_codec_length_meaning: \"payload_checksum\" # Length value 0x1C (28) covers 26 bytes payload + 2 bytes checksum\n    frame_codec_checksum_algo: \"sum16_be\" # Assuming 16-bit big-endian sum, adjust if your datasheet specifies a different algorithm\n    frame_codec_checksum_scope: \"prefix_header_length_payload\"\n    frame_codec_tailer_length: 0\n    frame_codec_suffix: \"\"";/*await connector.connectAndSend(
        message,
        clientCapabilities: clientCapabilities,
      );*/
      print("responseText>>>>>>>>>>>>>>>>>>"+responseText);
      logCat.info("sendRequest>>>>>>>>>>>>>>>>>>");
      if (responseText != null && responseText.isNotEmpty) {
        _textResponseController.add(responseText);
      }
    } finally {
      _isProcessing.value = false;
    }
  }
}
