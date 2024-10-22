import 'package:flutter/material.dart';

class TypographyCatalog extends StatelessWidget {
  const TypographyCatalog({Key? key}) : super(key: key);

  static const _text = "Aa";
  static const _paragraph = "Nor again is there anyone who loves or pursues or "
      "desires to obtain pain of itself, because it is pain, but occasionally "
      "circumstances occur in which toil and pain can procure him some great pleasure";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LabeledDivider(label: "Display"),
                Text(_text, style: Theme.of(context).textTheme.displayLarge),
                Text(_text, style: Theme.of(context).textTheme.displayMedium),
                Text(_text, style: Theme.of(context).textTheme.displaySmall),

                const LabeledDivider(label: "Headline"),
                Text(_text, style: Theme.of(context).textTheme.headlineLarge),
                Text(_text, style: Theme.of(context).textTheme.headlineMedium),
                Text(_text, style: Theme.of(context).textTheme.headlineSmall),

                const LabeledDivider(label: "Title"),
                Text(_text, style: Theme.of(context).textTheme.titleLarge),
                Text(_text, style: Theme.of(context).textTheme.titleMedium),
                Text(_text, style: Theme.of(context).textTheme.titleSmall),

                const LabeledDivider(label: "Label"),
                Text(_text, style: Theme.of(context).textTheme.labelLarge),
                Text(_text, style: Theme.of(context).textTheme.labelMedium),
                Text(_text, style: Theme.of(context).textTheme.labelSmall),

                const LabeledDivider(label: "Body"),
                Text(_paragraph, style: Theme.of(context).textTheme.bodyLarge),

                const Divider(),
                Text(_paragraph, style: Theme.of(context).textTheme.bodyMedium),

                const Divider(),
                Text(_paragraph, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LabeledDivider extends StatelessWidget {
  const LabeledDivider({Key? key, required this.label}) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        const SizedBox(width: 10),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
