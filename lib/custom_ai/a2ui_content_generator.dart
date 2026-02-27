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
      final String responseText = "{\n" +
          "  \"candidates\": [\n" +
          "    {\n" +
          "      \"content\": {\n" +
          "        \"parts\": [\n" +
          "          {\n" +
          "            \"functionCall\": {\n" +
          "              \"args\": {\n" +
          "                \"components\": [\n" +
          "                  {\n" +
          "                    \"component\": {\n" +
          "                      \"Text\": {\n" +
          "                        \"text\": {\n" +
          "                          \"literalString\": \"I can help you debug your PMS9103M Air Quality Sensor. To get started, please provide the following information:\"\n" +
          "                        },\n" +
          "                        \"usageHint\": \"h3\"\n" +
          "                      }\n" +
          "                    },\n" +
          "                    \"id\": \"intro_text\"\n" +
          "                  },\n" +
          "                  {\n" +
          "                    \"component\": {\n" +
          "                      \"Text\": {\n" +
          "                        \"text\": {\n" +
          "                          \"literalString\": \"1. Do you have the sensor's datasheet or protocol documentation available? This will help me understand the message structure.\"\n" +
          "                        },\n" +
          "                        \"usageHint\": \"body\"\n" +
          "                      }\n" +
          "                    },\n" +
          "                    \"id\": \"question_1\"\n" +
          "                  },\n" +
          "                  {\n" +
          "                    \"component\": {\n" +
          "                      \"Text\": {\n" +
          "                        \"text\": {\n" +
          "                          \"literalString\": \"2. How is the sensor connected to your system (e.g., Serial, USB-to-Serial, etc.)? What are the serial port parameters (baud rate, data bits, parity, stop bits, flow control)?\"\n" +
          "                        },\n" +
          "                        \"usageHint\": \"body\"\n" +
          "                      }\n" +
          "                    },\n" +
          "                    \"id\": \"question_2\"\n" +
          "                  },\n" +
          "                  {\n" +
          "                    \"component\": {\n" +
          "                      \"Text\": {\n" +
          "                        \"text\": {\n" +
          "                          \"literalString\": \"3. Can you provide any sample raw data (in hexadecimal format, if possible) that the sensor is sending?\"\n" +
          "                        },\n" +
          "                        \"usageHint\": \"body\"\n" +
          "                      }\n" +
          "                    },\n" +
          "                    \"id\": \"question_3\"\n" +
          "                  },\n" +
          "                  {\n" +
          "                    \"component\": {\n" +
          "                      \"Text\": {\n" +
          "                        \"text\": {\n" +
          "                          \"literalString\": \"4. What specific values or measurements do you want to extract from the sensor's data (e.g., PM1.0, PM2.5, PM10 concentrations)?\"\n" +
          "                        },\n" +
          "                        \"usageHint\": \"body\"\n" +
          "                      }\n" +
          "                    },\n" +
          "                    \"id\": \"question_4\"\n" +
          "                  },\n" +
          "                  {\n" +
          "                    \"component\": {\n" +
          "                      \"Column\": {\n" +
          "                        \"children\": {\n" +
          "                          \"explicitList\": [\n" +
          "                            \"intro_text\",\n" +
          "                            \"question_1\",\n" +
          "                            \"question_2\",\n" +
          "                            \"question_3\",\n" +
          "                            \"question_4\"\n" +
          "                          ]\n" +
          "                        }\n" +
          "                      }\n" +
          "                    },\n" +
          "                    \"id\": \"main_column\"\n" +
          "                  }\n" +
          "                ],\n" +
          "                \"surfaceId\": \"pms9103m_debug\"\n" +
          "              },\n" +
          "              \"name\": \"surfaceUpdate\"\n" +
          "            },\n" +
          "            \"thoughtSignature\": \"removed\"\n" +
          "          },\n" +
          "          {\n" +
          "            \"functionCall\": {\n" +
          "              \"args\": {\n" +
          "                \"root\": \"main_column\",\n" +
          "                \"surfaceId\": \"pms9103m_debug\"\n" +
          "              },\n" +
          "              \"name\": \"beginRendering\"\n" +
          "            }\n" +
          "          }\n" +
          "        ],\n" +
          "        \"role\": \"model\"\n" +
          "      },\n" +
          "      \"finishMessage\": \"Model generated function call(s).\",\n" +
          "      \"finishReason\": \"STOP\",\n" +
          "      \"index\": 0\n" +
          "    }\n" +
          "  ],\n" +
          "  \"modelVersion\": \"gemini-2.5-flash\",\n" +
          "  \"responseId\": \"B-removed\",\n" +
          "  \"usageMetadata\": {\n" +
          "    \"candidatesTokenCount\": 418,\n" +
          "    \"promptTokenCount\": 5379,\n" +
          "    \"promptTokensDetails\": [\n" +
          "      {\n" +
          "        \"modality\": \"TEXT\",\n" +
          "        \"tokenCount\": 5379\n" +
          "      }\n" +
          "    ],\n" +
          "    \"thoughtsTokenCount\": 184,\n" +
          "    \"totalTokenCount\": 5981\n" +
          "  }\n" +
          "}";/*await connector.connectAndSend(
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
