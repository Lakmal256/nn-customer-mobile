import 'package:flutter/material.dart';

import '../l10n.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({super.key, required this.onChange});

  final Function(String) onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xF0F0F0F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.search),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  hintText: AppLocalizations.of(context)!.nN_175,
                ),
                onChanged: onChange,
              ),
            ),
          ),
          // const Icon(Icons.tune_rounded)
        ],
      ),
    );
  }
}