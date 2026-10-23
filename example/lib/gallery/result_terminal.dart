import 'dart:convert';
import 'package:flutter/material.dart';
import 'branding.dart';
import 'package:flutter/services.dart';

/// Explicit local output may show demo data. Global diagnostics never copy it.
class ResultTerminal extends StatelessWidget {
  const ResultTerminal({
    super.key,
    required this.status,
    required this.output,
    this.elapsed,
  });
  final String status;
  final Object? output;
  final Duration? elapsed;
  @override
  Widget build(BuildContext context) {
    final text = const JsonEncoder.withIndent('  ').convert(output);
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff111820),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$status${elapsed == null ? '' : ' · ${elapsed!.inMicroseconds / 1000} ms'}',
                  style: const TextStyle(color: activitySky),
                ),
              ),
              IconButton(
                tooltip: 'Copy result output',
                color: Colors.white70,
                onPressed: () => Clipboard.setData(ClipboardData(text: text)),
                icon: const Icon(Icons.copy, size: 18),
              ),
            ],
          ),
          SelectableText(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
