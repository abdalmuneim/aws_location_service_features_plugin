import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/l10n.dart';

/// Collapsible pretty-printed JSON, for inspecting raw API responses.
class JsonViewer extends StatelessWidget {
  const JsonViewer({super.key, required this.data, this.title});

  final Object? data;

  /// Defaults to a generic "Raw response".
  final String? title;

  @override
  Widget build(BuildContext context) {
    final text = const JsonEncoder.withIndent('  ').convert(data);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        leading: const Icon(Icons.data_object),
        title: Text(title ?? context.l10n.commonRawResponse),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              icon: const Icon(Icons.copy, size: 16),
              label: Text(context.l10n.commonCopy),
              onPressed: () => Clipboard.setData(ClipboardData(text: text)),
            ),
          ),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 320),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              // JSON reads left-to-right in every UI language.
              child: SelectableText(
                text,
                textDirection: TextDirection.ltr,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
