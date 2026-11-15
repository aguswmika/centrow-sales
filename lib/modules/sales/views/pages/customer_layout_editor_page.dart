import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:centrow_sales/shared/theme/app_colors.dart';
import 'package:centrow_sales/shared/theme/app_radius.dart';

/// Kanvas sederhana untuk menggambar layout/denah lokasi pelanggan.
/// Mengembalikan bytes PNG lewat `Navigator.pop` ketika disimpan.
class CustomerLayoutEditorPage extends StatefulWidget {
  const CustomerLayoutEditorPage({super.key});

  @override
  State<CustomerLayoutEditorPage> createState() =>
      _CustomerLayoutEditorPageState();
}

class _CustomerLayoutEditorPageState extends State<CustomerLayoutEditorPage> {
  static const Size _canvasSize = Size(1600, 1000);
  static const List<Color> _palette = [
    Color(0xFF181A19),
    Color(0xFFEF4444),
    Color(0xFF1E40AF),
    Color(0xFF10B981),
    Color(0xFFBC7B43),
  ];

  final FocusNode _textFocusNode = FocusNode();
  late final PainterController _controller;
  Color _color = _palette[1];
  double _strokeWidth = 5;
  bool _isSaving = false;
  Offset? _pointer;

  Paint get _shapePaint => Paint()
    ..strokeWidth = _strokeWidth
    ..color = _color
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void initState() {
    super.initState();
    _controller = PainterController(
      settings: PainterSettings(
        text: TextSettings(
          focusNode: _textFocusNode,
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: _color,
            fontSize: 28,
          ),
        ),
        freeStyle: FreeStyleSettings(color: _color, strokeWidth: _strokeWidth),
        shape: ShapeSettings(paint: _shapePaint),
        scale: const ScaleSettings(enabled: true, minScale: 1, maxScale: 5),
      ),
    );
    _controller.background = Colors.white.backgroundDrawable;
    _textFocusNode.addListener(_refresh);
  }

  @override
  void dispose() {
    _textFocusNode.removeListener(_refresh);
    _textFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _toggleDraw() {
    _controller.shapeFactory = null;
    _controller.freeStyleMode = _controller.freeStyleMode == FreeStyleMode.draw
        ? FreeStyleMode.none
        : FreeStyleMode.draw;
  }

  void _toggleErase() {
    _controller.shapeFactory = null;
    _controller.freeStyleMode = _controller.freeStyleMode == FreeStyleMode.erase
        ? FreeStyleMode.none
        : FreeStyleMode.erase;
  }

  void _addText() {
    _controller.freeStyleMode = FreeStyleMode.none;
    _controller.shapeFactory = null;
    _controller.addText();
  }

  void _selectShape(ShapeFactory? factory) {
    if (factory != null) _controller.freeStyleMode = FreeStyleMode.none;
    _controller.shapeFactory = factory;
  }

  void _setColor(Color color) {
    setState(() => _color = color);
    _controller.freeStyleColor = color;
    _controller.textStyle = _controller.textStyle.copyWith(color: color);
    _controller.shapePaint = _shapePaint;
  }

  void _setStrokeWidth(double value) {
    setState(() => _strokeWidth = value);
    _controller.freeStyleStrokeWidth = value;
    _controller.shapePaint = _shapePaint;
  }

  void _removeSelected() {
    final selected = _controller.selectedObjectDrawable;
    if (selected != null) _controller.removeDrawable(selected);
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final ui.Image image = await _controller.renderImage(_canvasSize);
      final Uint8List? bytes = await image.pngBytes;
      if (!mounted) return;
      if (bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuat gambar layout'),
            backgroundColor: AppColors.err,
          ),
        );
        return;
      }
      Navigator.of(context).pop(bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan layout: $e'),
          backgroundColor: AppColors.err,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Gambar Layout',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        actions: [
          ValueListenableBuilder<PainterControllerValue>(
            valueListenable: _controller,
            builder: (context, _, _) => Row(
              children: [
                IconButton(
                  tooltip: 'Hapus objek terpilih',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _controller.selectedObjectDrawable == null
                      ? null
                      : _removeSelected,
                ),
                IconButton(
                  tooltip: 'Undo',
                  icon: const Icon(Icons.undo),
                  onPressed: _controller.canUndo ? _controller.undo : null,
                ),
                IconButton(
                  tooltip: 'Redo',
                  icon: const Icon(Icons.redo),
                  onPressed: _controller.canRedo ? _controller.redo : null,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 4),
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check, size: 18),
              label: const Text('Simpan'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brand,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.borderMd,
                ),
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _canvasSize.width / _canvasSize.height,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.borderMd,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ClipRRect(
                        borderRadius: AppRadius.borderMd,
                        child: _buildCanvas(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _buildToolbar(),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return ValueListenableBuilder<PainterControllerValue>(
      valueListenable: _controller,
      builder: (context, _, _) {
        final mode = _controller.freeStyleMode;
        final shape = _controller.shapeFactory;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            16,
            10,
            16,
            10 + MediaQuery.paddingOf(context).bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _toolButton(
                icon: Icons.edit_outlined,
                label: 'Pensil',
                active: mode == FreeStyleMode.draw,
                onTap: _toggleDraw,
              ),
              _toolButton(
                icon: Icons.cleaning_services_outlined,
                label: 'Penghapus',
                active: mode == FreeStyleMode.erase,
                onTap: _toggleErase,
              ),
              _toolButton(
                icon: Icons.text_fields,
                label: 'Teks',
                active: _textFocusNode.hasFocus,
                onTap: _addText,
              ),
              _buildShapeMenu(shape),
              const SizedBox(width: 8),
              for (final c in _palette) _colorDot(c),
              const SizedBox(width: 8),
              _buildStrokeSlider(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCanvas() {
    return ValueListenableBuilder<PainterControllerValue>(
      valueListenable: _controller,
      builder: (context, _, _) {
        final mode = _controller.freeStyleMode;
        final showBrush = mode != FreeStyleMode.none && _pointer != null;
        final scale = _controller.transformationController.value
            .getMaxScaleOnAxis();
        final diameter = _strokeWidth * scale;
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerHover: (e) => setState(() => _pointer = e.localPosition),
          onPointerDown: (e) => setState(() => _pointer = e.localPosition),
          onPointerMove: (e) => setState(() => _pointer = e.localPosition),
          onPointerUp: (e) {
            if (e.kind == PointerDeviceKind.mouse) return;
            setState(() => _pointer = null);
          },
          onPointerCancel: (_) => setState(() => _pointer = null),
          child: Stack(
            fit: StackFit.expand,
            children: [
              FlutterPainter(controller: _controller),
              if (showBrush)
                Positioned(
                  left: _pointer!.dx - diameter / 2,
                  top: _pointer!.dy - diameter / 2,
                  width: diameter,
                  height: diameter,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: mode == FreeStyleMode.erase
                            ? Colors.white
                            : _color.withValues(alpha: 0.35),
                        border: Border.all(
                          color: mode == FreeStyleMode.erase
                              ? AppColors.err
                              : _color,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStrokeSlider() {
    return SizedBox(
      width: 280,
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.muted,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.brand,
                inactiveTrackColor: AppColors.borderStrong,
                thumbColor: AppColors.brand,
                trackHeight: 4,
                tickMarkShape: const RoundSliderTickMarkShape(
                  tickMarkRadius: 1.5,
                ),
                activeTickMarkColor: Colors.white,
                inactiveTickMarkColor: AppColors.muted,
              ),
              child: Slider(
                min: 2,
                max: 50,
                divisions: 24,
                value: _strokeWidth,
                onChanged: _setStrokeWidth,
              ),
            ),
          ),
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: AppColors.muted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '${_strokeWidth.round()} px',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.sec,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShapeMenu(ShapeFactory? current) {
    final shapes = <ShapeFactory, (String, IconData)>{
      LineFactory(): ('Garis', Icons.horizontal_rule),
      ArrowFactory(): ('Panah', Icons.arrow_right_alt),
      DoubleArrowFactory(): ('Panah Ganda', Icons.swap_horiz),
      RectangleFactory(): ('Kotak', Icons.crop_square),
      OvalFactory(): ('Oval', Icons.circle_outlined),
    };
    return PopupMenuButton<ShapeFactory>(
      tooltip: 'Bentuk',
      onSelected: _selectShape,
      itemBuilder: (_) => [
        for (final e in shapes.entries)
          PopupMenuItem(
            value: e.key,
            child: Row(
              children: [
                Icon(e.value.$2, color: AppColors.brand),
                const SizedBox(width: 8),
                Text(e.value.$1),
              ],
            ),
          ),
      ],
      child: _toolChip(
        icon: Icons.category_outlined,
        label: current == null ? 'Bentuk' : 'Bentuk aktif',
        active: current != null,
      ),
    );
  }

  Widget _toolButton({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: AppRadius.borderMd,
      onTap: onTap,
      child: _toolChip(icon: icon, label: label, active: active),
    );
  }

  Widget _toolChip({
    required IconData icon,
    required String label,
    required bool active,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.brand10 : AppColors.subtle,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: active ? AppColors.brand : AppColors.border,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: active ? AppColors.brand : AppColors.sec),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.brand : AppColors.sec,
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorDot(Color color) {
    final selected = _color == color;
    return GestureDetector(
      onTap: () => _setColor(color),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.brand : AppColors.border,
            width: selected ? 3 : 1.5,
          ),
        ),
      ),
    );
  }
}
