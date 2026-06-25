import 'package:flutter/material.dart';

class ModelDownloadSheet extends StatefulWidget {
  final String modelName;
  final String downloadUrl;
  final int sizeBytes;
  const ModelDownloadSheet({super.key, required this.modelName, required this.downloadUrl, required this.sizeBytes});
  @override State<ModelDownloadSheet> createState() => _ModelDownloadSheetState();
}

class _ModelDownloadSheetState extends State<ModelDownloadSheet> {
  double _progress = 0;
  bool _downloading = false;
  bool _completed = false;
  bool _error = false;

  Future<void> _startDownload() async {
    setState(() { _downloading = true; _error = false; });
    try {
      for (var i = 1; i <= 20; i++) {
        await Future.delayed(const Duration(milliseconds: 150));
        if (!mounted) return;
        setState(() => _progress = i / 20);
      }
      setState(() { _downloading = false; _completed = true; });
    } catch (_) {
      setState(() { _downloading = false; _error = true; });
    }
  }

  @override Widget build(BuildContext context) {
    final sizeGB = widget.sizeBytes / (1024 * 1024 * 1024);
    return SizedBox(
      height: 300,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 32, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('Download ${widget.modelName}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('${sizeGB.toStringAsFixed(1)} GB · Q4_K_M quantization', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(120))),
          const SizedBox(height: 20),
          if (_completed)
            Column(children: [
              const Icon(Icons.check_circle, size: 48, color: Colors.green),
              const SizedBox(height: 8),
              const Text('Download complete!', style: TextStyle(fontWeight: FontWeight.w600)),
            ])
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: _progress, minHeight: 8,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest),
            ),
            const SizedBox(height: 10),
            Text('${(_progress * 100).toStringAsFixed(0)}% · ${(sizeGB * _progress).toStringAsFixed(1)} GB of ${sizeGB.toStringAsFixed(1)} GB',
                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withAlpha(120))),
          ],
          const Spacer(),
          FilledButton.icon(
            onPressed: _downloading || _completed ? null : _startDownload,
            icon: const Icon(Icons.download_rounded),
            label: Text(_error ? 'Retry' : _completed ? 'Done' : 'Download'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          ),
        ]),
      ),
    );
  }
}
