import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TiptapState {
  final Map<String, dynamic> json;
  final Map<String, bool> isActive;

  TiptapState({required this.json, required this.isActive});

  factory TiptapState.fromJson(Map<String, dynamic> data) {
    return TiptapState(
      json: data['json'] as Map<String, dynamic>? ?? {},
      isActive: Map<String, bool>.from(data['isActive'] as Map? ?? {}),
    );
  }
}

class WebviewTiptapEditor extends StatefulWidget {
  final Map<String, dynamic> initialJson;
  final ValueChanged<TiptapState>? onStateChange;
  final void Function(WebViewController)? onControllerCreated;

  const WebviewTiptapEditor({
    super.key,
    required this.initialJson,
    this.onStateChange,
    this.onControllerCreated,
  });

  @override
  State<WebviewTiptapEditor> createState() => _WebviewTiptapEditorState();
}

class _WebviewTiptapEditorState extends State<WebviewTiptapEditor> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final data = jsonDecode(message.message) as Map<String, dynamic>;
            final state = TiptapState.fromJson(data);
            widget.onStateChange?.call(state);
          } catch (e) {
            debugPrint('Error parsing message from webview: $e');
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            final initialJsonStr = jsonEncode(widget.initialJson);
            _controller.runJavaScript(
              "window.setupContent(String.raw`$initialJsonStr`);",
            );
            setState(() {
              _isLoading = false;
            });
            widget.onControllerCreated?.call(_controller);
          },
        ),
      );

    _loadHtml();
  }

  Future<void> _loadHtml() async {
    final jsBundle = await rootBundle.loadString('assets/js/tiptap.bundle.js');
    final htmlContent =
        '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
  <script>$jsBundle</script>
  <style>
    body { margin: 0; padding: 16px; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; font-size: 14px; line-height: 1.6; color: #1e293b; background-color: #ffffff; }
    .tiptap { outline: none; min-height: 100vh; }
    p { margin-top: 0; margin-bottom: 0.75em; }
    h1, h2, h3, h4, h5, h6 { margin-top: 1em; margin-bottom: 0.5em; line-height: 1.2; font-weight: 700; }
    h1 { font-size: 2em; } h2 { font-size: 1.5em; } h3 { font-size: 1.17em; }
    ul, ol { padding-left: 1.5em; margin-bottom: 0.75em; }
    blockquote { border-left: 3px solid #cbd5e1; margin: 0; padding-left: 1rem; color: #64748b; }
    pre { background: #0f172a; color: #f8fafc; padding: 0.75rem 1rem; border-radius: 0.5rem; margin-bottom: 0.75em; overflow-x: auto; font-family: monospace; }
    code { font-family: monospace; background-color: #f1f5f9; padding: 0.2em 0.4em; border-radius: 3px; font-size: 85%; }
    pre code { background-color: transparent; padding: 0; font-size: inherit; color: inherit; }
    a { color: #2563eb; text-decoration: none; cursor: pointer; }
    a:hover { text-decoration: underline; }
    
    table {
      border-collapse: collapse;
      table-layout: fixed;
      width: 100%;
      margin: 0;
      overflow: hidden;
      margin-bottom: 0.75em;
    }
    table td, table th {
      min-width: 1em;
      border: 1px solid #cbd5e1;
      padding: 3px 5px;
      vertical-align: top;
      box-sizing: border-box;
      position: relative;
    }
    table th { font-weight: bold; text-align: left; background-color: #f8fafc; }
  </style>
</head>
<body>
  <div id="editor"></div>
  
  <script>
    const { Editor, StarterKit, Table, TableRow, TableCell, TableHeader, TextAlign, Underline, Link } = window.Tiptap;

    const sendStateToFlutter = (editor) => {
      if (window.FlutterChannel) {
        const state = {
          json: editor.getJSON(),
          isActive: {
            bold: editor.isActive('bold'),
            italic: editor.isActive('italic'),
            underline: editor.isActive('underline'),
            strike: editor.isActive('strike'),
            code: editor.isActive('code'),
            link: editor.isActive('link'),
            bulletList: editor.isActive('bulletList'),
            orderedList: editor.isActive('orderedList'),
            blockquote: editor.isActive('blockquote'),
            codeBlock: editor.isActive('codeBlock'),
            h1: editor.isActive('heading', { level: 1 }),
            h2: editor.isActive('heading', { level: 2 }),
            h3: editor.isActive('heading', { level: 3 }),
            h4: editor.isActive('heading', { level: 4 }),
            h5: editor.isActive('heading', { level: 5 }),
            h6: editor.isActive('heading', { level: 6 }),
            left: editor.isActive({ textAlign: 'left' }),
            center: editor.isActive({ textAlign: 'center' }),
            right: editor.isActive({ textAlign: 'right' }),
            table: editor.isActive('table'),
          }
        };
        window.FlutterChannel.postMessage(JSON.stringify(state));
      }
    };

    window.editor = new Editor({
      element: document.querySelector('#editor'),
      extensions: [
        StarterKit,
        Table.configure({ resizable: true }),
        TableRow,
        TableHeader,
        TableCell,
        TextAlign.configure({ types: ['heading', 'paragraph'] }),
        Underline,
        Link.configure({ openOnClick: false })
      ],
      content: {},
      onUpdate: ({ editor }) => {
        sendStateToFlutter(editor);
      },
      onSelectionUpdate: ({ editor }) => {
        sendStateToFlutter(editor);
      }
    });

    window.setupContent = function(jsonString) {
      try {
        const json = JSON.parse(jsonString);
        if (Object.keys(json).length > 0) {
          window.editor.commands.setContent(json);
        }
      } catch (e) {
        console.error(e);
      }
      sendStateToFlutter(window.editor);
    };
    
    window.execCmd = function(cmd, argsStr) {
      const args = argsStr ? JSON.parse(argsStr) : undefined;
      if (args !== undefined) {
         window.editor.chain().focus()[cmd](args).run();
      } else {
         window.editor.chain().focus()[cmd]().run();
      }
    };
  </script>
</body>
</html>
''';
    await _controller.loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: WebViewWidget(controller: _controller)),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
