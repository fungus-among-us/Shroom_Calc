import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

class JsonEditorScreen extends StatefulWidget {
  const JsonEditorScreen({
    super.key,
    required this.initialJson,
    required this.onSave,
  });
  final String initialJson;
  final Future<void> Function(String) onSave;

  @override
  State<JsonEditorScreen> createState() => _JsonEditorScreenState();
}

class _JsonEditorScreenState extends State<JsonEditorScreen> {
  late TextEditingController _controller;
  Timer? _debounce;
  bool _isSaving = false;
  String? _validationError;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatJson(widget.initialJson));
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  String _formatJson(String jsonString) {
    try {
      final json = jsonDecode(jsonString);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    } catch (e) {
      return jsonString;
    }
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    setState(() {
      _hasUnsavedChanges = true;
      _validationError = null;
    });

    // Validate JSON
    try {
      jsonDecode(_controller.text);
    } catch (e) {
      setState(() {
        _validationError = 'Invalid JSON: ${e.toString()}';
      });
      return;
    }

    // Auto-save after 500ms of no typing
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _save();
    });
  }

  Future<void> _save() async {
    if (_validationError != null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave(_controller.text);
      if (mounted) {
        setState(() {
          _isSaving = false;
          _hasUnsavedChanges = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Changes saved'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _validationError = 'Save failed: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Edit Profiles'),
            if (_isSaving || _hasUnsavedChanges) ...[
              const SizedBox(width: 12),
              if (_isSaving)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8B7355),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ],
        ),
        actions: [
          if (_validationError == null)
            TextButton.icon(
              onPressed: _isSaving
                  ? null
                  : () {
                      _save();
                    },
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Save'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF8B7355),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          if (_validationError != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: colorScheme.errorContainer,
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 20,
                    color: colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _validationError!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (_isSaving)
            Container(
              padding: const EdgeInsets.all(12),
              color: const Color(0xFF8B7355).withValues(alpha: 0.1),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF8B7355)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Saving changes...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF8B7355),
                    ),
                  ),
                ],
              ),
            ),

          // Info banner
          Container(
            padding: const EdgeInsets.all(16),
            color: colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Changes auto-save 500ms after typing. Use monospace font for easier editing.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Editor
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
