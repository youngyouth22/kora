# Adaptive Responsive Nav

An animated, responsive navigation package for Flutter that smoothly adapts between a **Bottom Navigation Bar** on mobile and an **Animated Navigation Rail** (compact or extended) on tablet and desktop.

Built-in native support for `go_router` (`StatefulNavigationShell`) as well as standard Flutter state management.

---

## ✨ Features

- 📱 **Mobile**: Animated Disappearing Bottom Navigation Bar.
- 💻 **Tablet**: Compact Navigation Rail (icons only).
- 🖥️ **Desktop / Large Screens**: Extended Navigation Rail with labels and trailing action buttons.
- 🎬 **Smooth transitions**: Emphasized Material 3 cubic easing animations when resizing or rotating screens.
- 🛣️ **Seamless go_router integration**: Direct drop-in support for `StatefulNavigationShell`.
- 🎨 **Fully Customizable**: Colors, text styles, SVG / IconData / image icons, badges, indicators, settings callback.

---

## 🚀 Installation

In any Flutter project's `pubspec.yaml`:

```yaml
dependencies:
  adaptive_responsive_nav:
    path: packages/adaptive_responsive_nav # or path to where you placed the package
```

---

## 🛠️ Usage with go_router

```dart
import 'package:adaptive_responsive_nav/adaptive_responsive_nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) {
    return AdaptiveResponsiveScaffold(
      navigationShell: navigationShell,
      destinations: const [
        AdaptiveNavDestination(
          index: 0,
          title: 'Home',
          icon: Icons.home_rounded,
        ),
        AdaptiveNavDestination(
          index: 1,
          title: 'Progress',
          icon: 'assets/icons/progress.svg', // supports SVG assets!
        ),
        AdaptiveNavDestination(
          index: 2,
          title: 'Profile',
          icon: Icons.person_rounded,
        ),
      ],
      selectedColor: Colors.blueAccent,
      unselectedColor: Colors.grey,
      onSettingsPressed: () => context.push('/settings'),
    );
  },
  branches: [
    StatefulShellBranch(routes: [...]),
    StatefulShellBranch(routes: [...]),
    StatefulShellBranch(routes: [...]),
  ],
);
```

---

## 🛠️ Usage without go_router

```dart
AdaptiveResponsiveScaffold(
  selectedIndex: _currentIndex,
  onDestinationSelected: (index) => setState(() => _currentIndex = index),
  destinations: destinations,
  body: _pages[_currentIndex],
);
```
