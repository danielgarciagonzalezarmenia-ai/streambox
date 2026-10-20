import 'package:flutter/cupertino.dart';
import '../models/media_item.dart';
import 'media_card.dart';

class CategoryRow extends StatelessWidget {
  final String title;
  final List<MediaItem> items;
  final void Function(MediaItem item) onItemTap;

  const CategoryRow({
    super.key,
    required this.title,
    required this.items,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return MediaCard(
                item: item,
                onTap: () => onItemTap(item),
              );
            },
          ),
        ),
      ],
    );
  }
}
