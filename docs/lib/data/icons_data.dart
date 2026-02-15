import 'package:heroicons_animated/heroicons_animated.dart';

class IconEntry {
  const IconEntry({required this.name, required this.icon});

  final String name;
  final HeroiconAnimatedIconData icon;
}

final List<IconEntry> icons = [
  for (final icon in allHeroicons) IconEntry(name: icon.name, icon: icon),
];

String toPascalIconName(String kebabCaseName) {
  return '${kebabCaseName.split('-').map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)).join('')}Icon';
}
