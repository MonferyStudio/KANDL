import 'package:flutter/material.dart';

import '../../theme/app_themes.dart';
import 'info_panel.dart';

class InfoPanelSheet extends StatefulWidget {
  const InfoPanelSheet({super.key});

  @override
  State<InfoPanelSheet> createState() => _InfoPanelSheetState();
}

class _InfoPanelSheetState extends State<InfoPanelSheet> {
  final DraggableScrollableController _controller = DraggableScrollableController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watchTheme;

    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: 0.08,
      minChildSize: 0.08,
      maxChildSize: 0.85,
      snap: true,
      snapSizes: const [0.08, 0.4, 0.85],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border(
              top: BorderSide(color: theme.border, width: 1),
              left: BorderSide(color: theme.border, width: 1),
              right: BorderSide(color: theme.border, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              GestureDetector(
                onTap: () {
                  // Toggle between collapsed and half
                  final currentSize = _controller.size;
                  if (currentSize < 0.2) {
                    _controller.animateTo(
                      0.4,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    );
                  } else {
                    _controller.animateTo(
                      0.08,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.textSecondary.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: InfoPanel(
                  isSheet: true,
                  scrollController: scrollController,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
