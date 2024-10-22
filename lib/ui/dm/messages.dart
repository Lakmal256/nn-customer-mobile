import 'package:flutter/material.dart';

import '../../l10n.dart';
import '../../locator.dart';
import '../../service/service.dart';
import '../ui.dart';

class MyMessagesView extends StatefulWidget {
  const MyMessagesView({super.key});

  @override
  State<MyMessagesView> createState() => _MyMessagesViewState();
}

class _MyMessagesViewState extends State<MyMessagesView> {
  late Future<List<ConversationDto>> future;
  late String filterValue;

  @override
  initState() {
    filterValue = "";
    future = fetch();
    super.initState();
  }

  refresh() {
    setState(() {
      future = fetch();
    });
  }

  Future<List<ConversationDto>> fetch() => locate<RestService>().getConversations();

  handleItemSelect(BuildContext context, int id, String name, String email) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Material(
        child: ChatView(
          id: id,
          name: name,
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
            child: Text(
              // "My Messages",
              AppLocalizations.of(context)!.nN_063,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: AppSearchBar(
              onChange: (value) => setState(() => filterValue = value),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: FutureBuilder(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  }

                  if (snapshot.hasData && snapshot.data!.isEmpty) {
                    return const Center(child: Text("The list is empty"));
                  }

                  var items = (snapshot.data ?? [])
                      .reversed
                      .where((item) => (item.lastMessage?.interlocutorName?.toLowerCase() ?? "")
                          .contains(filterValue.toLowerCase()))
                      .toList();

                  return RefreshIndicator(
                    onRefresh: () => refresh(),
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (context, i) => const SizedBox(height: 15),
                      itemBuilder: (context, i) {
                        var item = items[i];
                        var name = item.lastMessage?.interlocutorName ?? "N/A";
                        return MessageItem(
                          name: name,
                          preview: item.lastMessage?.message ?? "",
                          time: item.lastMessage?.relativeTime ?? "",
                          imageUrl: item.lastMessage?.interlocutorImageUrl,
                          count: item.unseenMessageCount,
                          onSelect: () => item.lastMessage != null
                              ? handleItemSelect(context, item.lastMessage!.interlocutorId!, name, "")
                              : null,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageItem extends StatelessWidget {
  const MessageItem({
    super.key,
    required this.name,
    required this.time,
    required this.preview,
    required this.onSelect,
    this.count = 0,
    this.imageUrl,
  });

  final String name;
  final String time;
  final String preview;
  final String? imageUrl;
  final int count;
  final Function() onSelect;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xF0F0F0F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.red,
              foregroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black38),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                if (count > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: const ShapeDecoration(
                      shape: StadiumBorder(),
                      color: AppColors.red,
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
