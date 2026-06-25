import 'package:flutter/material.dart';
class HumanNodeBottomSheet extends StatelessWidget {
  final Widget child; final String? title;
  const HumanNodeBottomSheet({super.key, required this.child, this.title});
  static Future<T?> show<T>(BuildContext context, {required Widget child, String? title}) =>
      showModalBottomSheet<T>(context: context, builder: (_) => HumanNodeBottomSheet(child: child, title: title),
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))));
  @override Widget build(BuildContext context) => SafeArea(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 32, height: 4, margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
      if (title != null) Padding(padding: const EdgeInsets.all(16),
          child: Text(title!, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600))),
      Flexible(child: child),
    ]));
}
