import 'package:flutter/material.dart';
import 'model_download_sheet.dart';

class ModelRegistryItem {
  final String name;
  final String description;
  final String quantization;
  final String size;
  final String downloadUrl;
  final int sizeBytes;
  final double? benchmark;
  const ModelRegistryItem({required this.name, required this.description, required this.quantization,
      required this.size, required this.downloadUrl, required this.sizeBytes, this.benchmark});
}

class ModelRegistryBrowser extends StatefulWidget {
  const ModelRegistryBrowser({super.key});
  @override State<ModelRegistryBrowser> createState() => _ModelRegistryBrowserState();
}

class _ModelRegistryBrowserState extends State<ModelRegistryBrowser> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  static const _catalog = [
    ModelRegistryItem(name: 'Llama 3.2 3B Instruct', description: 'Meta lightweight general-purpose model, strong all-around performance',
        quantization: 'Q4_K_M', size: '2.4 GB', downloadUrl: '', sizeBytes: 2400000000, benchmark: 25.5),
    ModelRegistryItem(name: 'Phi-3 Mini 4K Instruct', description: 'Microsoft compact model, excellent reasoning for size',
        quantization: 'Q4_K_M', size: '2.6 GB', downloadUrl: '', sizeBytes: 2600000000, benchmark: 30.2),
    ModelRegistryItem(name: 'Gemma 2 2B IT', description: 'Google lightweight model, fast and efficient',
        quantization: 'Q4_K_M', size: '1.6 GB', downloadUrl: '', sizeBytes: 1600000000, benchmark: 35.0),
    ModelRegistryItem(name: 'Qwen 2.5 1.5B Instruct', description: 'Alibaba compact model, excellent for mobile',
        quantization: 'Q4_K_M', size: '1.1 GB', downloadUrl: '', sizeBytes: 1100000000, benchmark: 40.1),
  ];

  List<ModelRegistryItem> get _filtered => _query.isEmpty
      ? _catalog : _catalog.where((m) => m.name.toLowerCase().contains(_query.toLowerCase())).toList();

  @override Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search models...', prefixIcon: const Icon(Icons.search_rounded, size: 20),
              filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filtered.length,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemBuilder: (context, i) {
              final item = _filtered[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 3),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.smart_toy_rounded, color: Theme.of(context).colorScheme.primary, size: 24),
                  ),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  subtitle: Text('${item.size} · ${item.quantization} · ${item.description}', style: const TextStyle(fontSize: 11), maxLines: 2),
                  trailing: FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.pop(context);
                      showModalBottomSheet(context: context,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                          builder: (_) => ModelDownloadSheet(modelName: item.name, downloadUrl: item.downloadUrl, sizeBytes: item.sizeBytes));
                    },
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text('Get', style: TextStyle(fontSize: 13)),
                  ),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  @override void dispose() { _searchCtrl.dispose(); super.dispose(); }
}
