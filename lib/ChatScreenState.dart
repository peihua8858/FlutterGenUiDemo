import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:genui_firebase_ai/genui_firebase_ai.dart';
import 'ChatScreen.dart';
import 'log_cat.dart';
import 'custom_ai/a2ui_agent_connector.dart';
import 'custom_ai/a2ui_content_generator.dart';
class ChatScreenState extends State<ChatScreen> {
  late final A2uiMessageProcessor _a2uiMessageProcessor;
  late final GenUiConversation _genUiConversation;
  final _textController = TextEditingController();
  final _surfaceIds = <String>[];

  // Send a message containing the user's [text] to the agent.
  void _sendMessage(String text) {
    print("_sendMessage>>>>>>>>>>>>>>>>>>"+text);
    logCat.info(">>_sendMessage>>>>>>>>>>>>>>>>>>>"+text);
    if (text.trim().isEmpty) return;
    _genUiConversation.sendRequest(UserMessage.text(text));
    logCat.info(">>_sendMessage>>>>>>>>>>>>>>>>>>>"+text);
    _genUiConversation.conversation.value.forEach((element) {
      logCat.info(">>_sendMessage>>>>>>>>>>>>>>>>>>>"+element.toString());
      if (element is AiTextMessage) {
        logCat.info(">>_sendMessage>>>>>>>>>>>>>>>>>>>"+element.text);
      }else if (element is UserMessage) {
        logCat.info(">>_sendMessage>>>>>>>>>>>>>>>>>>>"+element.text);
      }
    });
  }

  // A callback invoked by the [GenUiConversation] when a new
  // UI surface is generated. Here, the ID is stored so the
  // build method can create a GenUiSurface to display it.
  void _onSurfaceAdded(SurfaceAdded update) {
    setState(() {
      _surfaceIds.add(update.surfaceId);
      logCat.info(">>_onSurfaceAdded>>>>>>>>>>>>>>>>>>>"+update.surfaceId);
    });
  }

  // A callback invoked by GenUiConversation when a UI surface is removed.
  void _onSurfaceDeleted(SurfaceRemoved update) {
    setState(() {
      _surfaceIds.remove(update.surfaceId);
      logCat.info(">>_onSurfaceDeleted>>>>>>>>>>>>>>>>>>>"+update.surfaceId);
    });
  }

  @override
  void initState() {
    super.initState();

    // Create a A2uiMessageProcessor with a widget catalog.
    // The CoreCatalogItems contain basic widgets for text, markdown, and images.
    _a2uiMessageProcessor = A2uiMessageProcessor(
      catalogs: [CoreCatalogItems.asCatalog()],
    );
    // Create a ContentGenerator to communicate with the LLM.
    // Provide system instructions and the tools from the A2uiMessageProcessor.
    // final contentGenerator = FirebaseAiContentGenerator(
    //   catalog: CoreCatalogItems.asCatalog(),
    //   systemInstruction: '''
    //     You are an expert in creating funny riddles. Every time I give you a word,
    //     you should generate UI that displays one new riddle related to that word.
    //     Each riddle should have both a question and an answer.
    //     ''',
    //   // additionalTools: _a2uiMessageProcessor.getTools(),
    // );
    final contentGenerator = A2uiContentGenerator(serverUrl: Uri.parse('https://example-files.online-convert.com/document/txt/example.txt'));
    // Create the GenUiConversation to orchestrate everything.
    _genUiConversation = GenUiConversation(
      a2uiMessageProcessor: _a2uiMessageProcessor,
      contentGenerator: contentGenerator,
      onSurfaceAdded: _onSurfaceAdded, // Added in the next step.
      onSurfaceDeleted: _onSurfaceDeleted, // Added in the next step.
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _surfaceIds.length,
              itemBuilder: (context, index) {
                // For each surface, create a GenUiSurface to display it.
                final id = _surfaceIds[index];
                return GenUiSurface(
                  host: _genUiConversation.host,
                  surfaceId: id,
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child:TextField(
                      controller: _textController,
                      style: const TextStyle(fontSize: 16),

                      decoration: const InputDecoration(
                        hintText: 'Enter a message',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Send the user's text to the agent.
                      logCat.info(">>_sendMessage>>>>>>>>>>>>>>>>>>>");
                      _sendMessage(_textController.text);
                      _textController.clear();
                    },
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _genUiConversation.dispose();

    super.dispose();
  }
}
