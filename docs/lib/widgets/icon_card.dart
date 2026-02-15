import 'package:flutter/material.dart';
import 'package:heroicons_animated/heroicons_animated.dart';

class IconCard extends StatelessWidget {
  const IconCard({
    required this.name,
    required this.icon,
    required this.isDark,
    this.onViewCode,
    this.onCopy,
    super.key,
  });

  final String name;
  final HeroiconAnimatedIconData icon;
  final bool isDark;
  final VoidCallback? onViewCode;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: HeroiconAnimatedIcon(
                icon: icon,
                size: 40,
                color: isDark ? Colors.white : Colors.black87,
                trigger: AnimationTrigger.onHover,
              ),
            ),
          ),
          SelectableText(
            name,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Tooltip(
                message: 'Copy',
                child: _buildActionButton(
                  icon: Icon(
                    Icons.copy,
                    size: 16,
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                  ),
                  onTap: () => onCopy?.call(),
                ),
              ),
              Tooltip(
                message: 'View code',
                child: _buildActionButton(
                  icon: Icon(
                    Icons.code,
                    size: 16,
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                  ),
                  onTap: () => onViewCode?.call(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        child: icon,
      ),
    );
  }
}
