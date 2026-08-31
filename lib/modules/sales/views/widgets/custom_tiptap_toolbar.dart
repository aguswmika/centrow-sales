import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'webview_tiptap_editor.dart';
import 'package:centrow_sales/modules/sales/entities/proposal_document.dart';

class CustomTiptapToolbar extends StatefulWidget {
  final WebViewController controller;
  final TiptapState state;
  final List<ProposalPlaceholder> placeholders;

  const CustomTiptapToolbar({
    super.key,
    required this.controller,
    required this.state,
    this.placeholders = const [],
  });

  @override
  State<CustomTiptapToolbar> createState() => _CustomTiptapToolbarState();
}

class _CustomTiptapToolbarState extends State<CustomTiptapToolbar> {
  Future<void> _exec(String cmd, [dynamic args]) async {
    final argsStr = args != null ? jsonEncode(args) : 'null';
    await widget.controller.runJavaScript(
      "window.execCmd('$cmd', String.raw`$argsStr`);",
    );
  }

  Future<void> _handleLinkInsert(BuildContext context) async {
    if (widget.state.isActive['link'] == true) {
      await _exec('unsetLink');
      return;
    }

    final url = await showDialog<String>(
      context: context,
      builder: (context) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Insert Link'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(hintText: 'https://...'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(ctrl.text),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (url != null && url.isNotEmpty) {
      await _exec('setLink', {'href': url});
    }
  }

  String _getCurrentBlockType() {
    final state = widget.state;
    if (state.isActive['h1'] == true) return 'h1';
    if (state.isActive['h2'] == true) return 'h2';
    if (state.isActive['h3'] == true) return 'h3';
    if (state.isActive['h4'] == true) return 'h4';
    if (state.isActive['h5'] == true) return 'h5';
    if (state.isActive['h6'] == true) return 'h6';
    return 'p';
  }

  void _onBlockTypeSelected(String? value) {
    if (value == null) return;
    if (value == 'p') {
      _exec('setParagraph');
    } else if (value.startsWith('h')) {
      final level = int.tryParse(value.substring(1));
      if (level != null) {
        _exec('toggleHeading', {'level': level});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentBlockType = _getCurrentBlockType();
    final state = widget.state;

    return Focus(
      canRequestFocus: false,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Block Type Dropdown
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.transparent,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: currentBlockType,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    isDense: true,
                    alignment: Alignment.center,
                    onChanged: _onBlockTypeSelected,
                    items: const [
                      DropdownMenuItem(value: 'p', child: Text('Normal text')),
                      DropdownMenuItem(value: 'h1', child: Text('Heading 1')),
                      DropdownMenuItem(value: 'h2', child: Text('Heading 2')),
                      DropdownMenuItem(value: 'h3', child: Text('Heading 3')),
                      DropdownMenuItem(value: 'h4', child: Text('Heading 4')),
                      DropdownMenuItem(value: 'h5', child: Text('Heading 5')),
                      DropdownMenuItem(value: 'h6', child: Text('Heading 6')),
                    ],
                  ),
                ),
              ),

              // Variables Dropdown
              if (widget.placeholders.isNotEmpty) ...[
                _ToolbarDivider(),
                PopupMenuButton<ProposalPlaceholder>(
                  tooltip: 'Variabel',
                  icon: const Icon(Icons.integration_instructions, size: 20),
                  onSelected: (placeholder) {
                    _exec('insertContent', placeholder.tag);
                  },
                  itemBuilder: (context) {
                    return widget.placeholders.map((p) {
                      return PopupMenuItem(
                        value: p,
                        child: Text('${p.tag}: ${p.label}'),
                      );
                    }).toList();
                  },
                ),
              ],

              _ToolbarDivider(),

              // Marks
              _ToolbarButton(
                icon: Icons.format_bold,
                tooltip: 'Bold',
                isActive: state.isActive['bold'] == true,
                onPressed: () => _exec('toggleBold'),
              ),
              _ToolbarButton(
                icon: Icons.format_italic,
                tooltip: 'Italic',
                isActive: state.isActive['italic'] == true,
                onPressed: () => _exec('toggleItalic'),
              ),
              _ToolbarButton(
                icon: Icons.format_underlined,
                tooltip: 'Underline',
                isActive: state.isActive['underline'] == true,
                onPressed: () => _exec('toggleUnderline'),
              ),
              _ToolbarButton(
                icon: Icons.format_strikethrough,
                tooltip: 'Strikethrough',
                isActive: state.isActive['strike'] == true,
                onPressed: () => _exec('toggleStrike'),
              ),
              _ToolbarButton(
                icon: Icons.code,
                tooltip: 'Inline Code',
                isActive: state.isActive['code'] == true,
                onPressed: () => _exec('toggleCode'),
              ),
              _ToolbarButton(
                icon: Icons.link,
                tooltip: 'Link',
                isActive: state.isActive['link'] == true,
                onPressed: () => _handleLinkInsert(context),
              ),

              _ToolbarDivider(),

              // Alignments
              _ToolbarButton(
                icon: Icons.format_align_left,
                tooltip: 'Align Left',
                isActive: state.isActive['left'] == true,
                onPressed: () => _exec('setTextAlign', 'left'),
              ),
              _ToolbarButton(
                icon: Icons.format_align_center,
                tooltip: 'Align Center',
                isActive: state.isActive['center'] == true,
                onPressed: () => _exec('setTextAlign', 'center'),
              ),
              _ToolbarButton(
                icon: Icons.format_align_right,
                tooltip: 'Align Right',
                isActive: state.isActive['right'] == true,
                onPressed: () => _exec('setTextAlign', 'right'),
              ),

              _ToolbarDivider(),

              // Text Blocks (Hard break only now, since paragraph is in dropdown)
              _ToolbarButton(
                icon: Icons.wrap_text,
                tooltip: 'Hard Break',
                isActive: false,
                onPressed: () => _exec('setHardBreak'),
              ),

              _ToolbarDivider(),

              // Lists
              _ToolbarButton(
                icon: Icons.format_list_bulleted,
                tooltip: 'Bullet List',
                isActive: state.isActive['bulletList'] == true,
                onPressed: () => _exec('toggleBulletList'),
              ),
              _ToolbarButton(
                icon: Icons.format_list_numbered,
                tooltip: 'Ordered List',
                isActive: state.isActive['orderedList'] == true,
                onPressed: () => _exec('toggleOrderedList'),
              ),

              _ToolbarDivider(),

              // Blocks
              _ToolbarButton(
                icon: Icons.format_quote,
                tooltip: 'Blockquote',
                isActive: state.isActive['blockquote'] == true,
                onPressed: () => _exec('toggleBlockquote'),
              ),
              _ToolbarButton(
                icon: Icons.data_object,
                tooltip: 'Code Block',
                isActive: state.isActive['codeBlock'] == true,
                onPressed: () => _exec('toggleCodeBlock'),
              ),
              _ToolbarButton(
                icon: Icons.horizontal_rule,
                tooltip: 'Horizontal Rule',
                isActive: false,
                onPressed: () => _exec('setHorizontalRule'),
              ),

              _ToolbarDivider(),

              // Table Controls
              _ToolbarButton(
                icon: Icons.grid_on,
                tooltip: 'Insert Table',
                isActive: state.isActive['table'] == true,
                onPressed: () => _exec('insertTable', {
                  'rows': 3,
                  'cols': 3,
                  'withHeaderRow': true,
                }),
              ),
              if (state.isActive['table'] == true) ...[
                _ToolbarButton(
                  icon: Icons.table_rows,
                  tooltip: 'Add Row After',
                  isActive: false,
                  onPressed: () => _exec('addRowAfter'),
                ),
                _ToolbarButton(
                  icon: Icons.view_column,
                  tooltip: 'Add Column After',
                  isActive: false,
                  onPressed: () => _exec('addColumnAfter'),
                ),
                _ToolbarButton(
                  icon: Icons.delete_sweep,
                  tooltip: 'Delete Row',
                  isActive: false,
                  onPressed: () => _exec('deleteRow'),
                ),
                _ToolbarButton(
                  icon: Icons.delete_outline,
                  tooltip: 'Delete Column',
                  isActive: false,
                  onPressed: () => _exec('deleteColumn'),
                ),
                _ToolbarButton(
                  icon: Icons.delete_forever,
                  tooltip: 'Delete Table',
                  isActive: false,
                  onPressed: () => _exec('deleteTable'),
                ),
              ],

              _ToolbarDivider(),

              // History
              _ToolbarButton(
                icon: Icons.undo,
                tooltip: 'Undo',
                isActive: false,
                onPressed: () => _exec('undo'),
              ),
              _ToolbarButton(
                icon: Icons.redo,
                tooltip: 'Redo',
                isActive: false,
                onPressed: () => _exec('redo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: isActive ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onPressed,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(
                icon,
                size: 20,
                color: isActive
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        height: 24,
        child: VerticalDivider(
          width: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }
}
