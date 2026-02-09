import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lazywikis/data/models/guide.dart';

class GuideCard extends StatefulWidget {
  final Guide guide;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  const GuideCard({
    super.key,
    required this.guide,
    required this.onTap,
    required this.onDelete,
    required this.onDuplicate,
  });

  @override
  State<GuideCard> createState() => _GuideCardState();
}

class _GuideCardState extends State<GuideCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat.yMMMd().add_jm().format(widget.guide.updatedAt);

    return Hero(
      tag: 'guide-${widget.guide.id}',
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: _isHovered ? 4 : 0,
            shadowColor: theme.shadowColor.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: _isHovered
                    ? theme.colorScheme.primary.withOpacity(0.5)
                    : theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: InkWell(
              onTap: widget.onTap,
              hoverColor: theme.colorScheme.primary.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.guide.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          onSelected: (value) {
                            if (value == 'delete') {
                              widget.onDelete();
                            } else if (value == 'duplicate') {
                              widget.onDuplicate();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'duplicate',
                              child: Row(
                                children: [
                                  Icon(Icons.content_copy, size: 20),
                                  SizedBox(width: 8),
                                  Text('Duplicate'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.layers_outlined,
                          size: 16,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_getTotalSteps()} steps',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Updated $dateStr',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(
                          0.7,
                        ),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _getTotalSteps() {
    int count = widget.guide.steps.length;
    if (widget.guide.introduction != null) {
      count += 1; // Include Introduction as a step
    }
    return count;
  }
}
