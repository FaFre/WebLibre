import 'package:collection/collection.dart';
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';

class UriBreadcrumb extends StatelessWidget {
  final Uri uri;
  final Widget? icon;
  final TextStyle? style;

  const UriBreadcrumb({super.key, required this.uri, this.icon, this.style});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: uri.toString(),
      child: DefaultTextStyle(
        style: style ?? DefaultTextStyle.of(context).style,
        child: FadingScroll(
          fadingSize: 15,
          builder: (context, controller) {
            return SingleChildScrollView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ?icon,
                  Text(
                    uri.authority,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (uri.pathSegments.any((s) => s.isNotEmpty))
                    Text(
                      ' › ${uri.pathSegments.whereNot((s) => s.isEmpty).join(' › ')}',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
