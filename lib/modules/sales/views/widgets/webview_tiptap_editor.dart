import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

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
  final bool isEditable;

  /// Tema PDF dokumen (1–5) untuk tata letak halaman. `null` = gaya polos (addendum).
  final int? theme;

  const WebviewTiptapEditor({
    super.key,
    required this.initialJson,
    this.onStateChange,
    this.onControllerCreated,
    this.isEditable = true,
    this.theme,
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
              "window.setupContent(String.raw`$initialJsonStr`); window.setEditable(${widget.isEditable});",
            );
            setState(() {
              _isLoading = false;
            });
            widget.onControllerCreated?.call(_controller);
          },
        ),
      );

    // Halaman A4 dirender selebar kertas lalu di-zoom-out agar pas layar; Android
    // hanya menghormati meta viewport lebar bila wide viewport diaktifkan. Pinch zoom
    // sudah aktif bawaan (Android: built-in zoom; iOS: user-scalable di meta viewport).
    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      platform.setUseWideViewPort(true);
    }

    _loadHtml();
  }

  @override
  void didUpdateWidget(covariant WebviewTiptapEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isEditable != widget.isEditable && !_isLoading) {
      _controller.runJavaScript("window.setEditable(${widget.isEditable});");
    }
  }

  Future<void> _loadHtml() async {
    final jsBundle = await rootBundle.loadString('assets/js/tiptap.bundle.js');
    final pageLayout = widget.theme == null
        ? "{ profile: 'plain' }"
        : "{ profile: 'theme', theme: ${widget.theme} }";
    final htmlContent =
        '''
<!DOCTYPE html>
<html>
<head>
  <!-- Lebar A4 (794px) + padding kanvas 2x24px; WebView menskalakan agar pas layar, pinch zoom aktif. -->
  <meta name="viewport" content="width=842, user-scalable=yes" />
  <style>
    /* Token yang dipakai page.css (nilai dari centrow web/app/main.css). */
    :root {
      --font-sans: "Inter", system-ui, -apple-system, sans-serif;
      --color-page: #F8F8F5;
      --color-surface: #FFFFFF;
      --color-primary: #181A19;
      --color-secondary: #5A5D5A;
      --color-brand-500: #1E40AF;
      --color-border-default: #E4E5DF;
      --color-border-strong: #CBD5E1;
      --shadow-ds-md: 0 2px 8px rgba(0, 0, 0, 0.06), 0 1px 3px rgba(0, 0, 0, 0.04);
    }
    html, body { margin: 0; padding: 0; background: var(--color-page); color: var(--color-primary); }
    #editor { display: contents; }
    .rt-paged { min-height: 100vh; box-sizing: border-box; }
    .ProseMirror { outline: none; }
    a { color: var(--color-brand-500); text-decoration: none; cursor: pointer; }
    img { max-width: 100%; height: auto; }
    img[data-align="center"] { display: block; margin-left: auto; margin-right: auto; }
    img[data-align="right"] { display: block; margin-left: auto; margin-right: 0; }
    table td, table th { min-width: 1em; vertical-align: top; box-sizing: border-box; position: relative; }
  </style>
  <script>$jsBundle</script>
</head>
<body>
  <div id="paged" class="rt-paged"><div id="editor"></div></div>

  <script>
    const { Editor, StarterKit, Table, TableRow, TableCell, TableHeader, TextAlign, Underline, Link, Image, PagePagination, resolvePageProfile, contentWidthPx } = window.Tiptap;

    let pageProfile = resolvePageProfile($pageLayout);
    document.querySelector('#paged').setAttribute('data-profile', pageProfile.id);

    // Lebar area konten A4 (tanpa margin halaman); dasar preset lebar gambar.
    const editorContentWidth = () => contentWidthPx(pageProfile);

    const sendStateToFlutter = (editor) => {
      if (window.FlutterChannel) {
        const imageAlign = editor.isActive('image') ? (editor.getAttributes('image').align || 'left') : null;
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
            image: editor.isActive('image'),
            imageLeft: imageAlign === 'left',
            imageCenter: imageAlign === 'center',
            imageRight: imageAlign === 'right',
          }
        };
        window.FlutterChannel.postMessage(JSON.stringify(state));
      }
    };

    window.editor = new Editor({
      element: document.querySelector('#editor'),
      editable: ${widget.isEditable},
      extensions: [
        StarterKit,
        Table.configure({ resizable: true }),
        TableRow,
        TableHeader,
        TableCell,
        TextAlign.configure({ types: ['heading', 'paragraph'] }),
        Underline,
        Link.configure({ openOnClick: false }),
        Image.extend({
          addAttributes() {
            return {
              ...this.parent?.(),
              align: {
                default: 'left',
                parseHTML: el => el.getAttribute('data-align') || 'left',
                renderHTML: attrs => ({ 'data-align': attrs.align }),
              },
            };
          },
        }).configure({ allowBase64: false }),
        PagePagination.configure({ profile: pageProfile.id })
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

    window.setEditable = function(editable) {
      if (window.editor) {
        window.editor.setEditable(editable);
      }
    };

    window.setImageWidth = function(percent) {
      const containerWidth = editorContentWidth();
      const px = Math.max(50, Math.round((percent / 100) * containerWidth));
      window.editor.chain().focus().updateAttributes('image', { width: px, height: null }).run();
    };

    window.adjustImageWidth = function(deltaPercent) {
      const editor = window.editor;
      const maxWidth = editorContentWidth();
      const sel = editor.state.selection;
      const selectedIsImage = !!(sel.node && sel.node.type.name === 'image');
      let imgEl = null;
      const dom = editor.view.nodeDOM(sel.from);
      if (dom && dom.tagName === 'IMG') {
        imgEl = dom;
      } else {
        imgEl = document.querySelector('img.ProseMirror-selectednode');
      }
      if (!selectedIsImage && !imgEl) return;
      let current = selectedIsImage ? sel.node.attrs.width : null;
      if (current === null || current === undefined || current === '') {
        current = imgEl ? imgEl.getBoundingClientRect().width : maxWidth;
      }
      const next = Math.round(Math.max(50, Math.min(maxWidth, Number(current) + (deltaPercent / 100) * maxWidth)));
      editor.chain().focus().updateAttributes('image', { width: next, height: null }).run();
    };

    window.setPageLayout = function(layout) {
      pageProfile = resolvePageProfile(layout);
      document.querySelector('#paged').setAttribute('data-profile', pageProfile.id);
      window.editor.commands.setPageProfile(pageProfile.id);
    };

    window.setImageAlign = function(align) {
      if (align !== 'left' && align !== 'center' && align !== 'right') return;
      window.editor.chain().focus().updateAttributes('image', { align: align }).run();
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
