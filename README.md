# heroicons_animated

Animated Heroicons for Flutter, ported from the React project `heroicons-animated`.

## Repository structure

This repository follows the requested layout:

- `lib/` - publishable Flutter package source
- `docs/` - Flutter web demo/docs site
- `tool/` - migration and generation scripts

## Package usage

Add this package to your app:

```yaml
dependencies:
  heroicons_animated:
    git:
      url: https://github.com/heroicons-animated/heroicons-animated-flutter
```

Then use any icon:

```dart
import 'package:heroicons_animated/heroicons_animated.dart';

HeroiconAnimatedIcon(
  icon: heart,
  trigger: AnimationTrigger.onTap,
)
```

## Available icons

All React icons were migrated from:

- `packages/react/src/icons/*.tsx` in the sibling React repo

Generated icon list is available as:

- `allHeroicons` (list)
- Individual constants (e.g. `heart`, `arrowPath`, `chatBubbleLeft`)

## Run docs website

```bash
cd docs
flutter pub get
flutter run -d chrome
```

## Credits

- Heroicons Animated React: https://github.com/heroicons-animated/heroicons-animated
- not_static_icons structure inspiration: https://github.com/khlebobul/not_static_icons

## License

MIT
