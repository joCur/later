---
title: later - Design Documentation
description: Complete design system and specifications for the later productivity app
last-updated: 2025-10-19
version: 1.0.0
status: approved
---

# later - Design Documentation

> **A unified productivity experience that flows with your thoughts**

## Overview

This documentation contains the complete design system, specifications, and implementation guidelines for "later" - a productivity app that unifies tasks, notes, and lists in a single fluid interface.

## Design Philosophy

later's design language is built on the concept of **"Temporal Flow"** - the idea that productivity tools should feel like extensions of thought rather than rigid organizational systems. Our design emphasizes:

- **Fluid Motion**: Smooth, physics-based animations that feel natural and responsive
- **Adaptive Depth**: Subtle use of elevation and blur to create spatial hierarchy
- **Chromatic Intelligence**: Dynamic color system that adapts to context and content type
- **Gestural Intimacy**: Touch-first interactions that feel personal and immediate
- **Minimalist Boldness**: Strong typography and strategic use of whitespace

## Quick Navigation

### Design System
- [Style Guide](./design-system/style-guide.md) - Complete visual specifications
- [Design Tokens](./design-system/tokens/) - Foundational design elements
  - [Colors](./design-system/tokens/colors.md)
  - [Typography](./design-system/tokens/typography.md)
  - [Spacing](./design-system/tokens/spacing.md)
  - [Animations](./design-system/tokens/animations.md)
- [Components](./design-system/components/) - Component library
  - [Item Cards](./design-system/components/item-cards.md)
  - [Quick Capture](./design-system/components/quick-capture.md)
  - [Navigation](./design-system/components/navigation.md)
  - [Buttons](./design-system/components/buttons.md)
  - [Forms](./design-system/components/forms.md)

### Platform Guidelines
- [iOS Adaptations](./design-system/platform-adaptations/ios.md)
- [Android Adaptations](./design-system/platform-adaptations/android.md)
- [Web/Tablet Adaptations](./design-system/platform-adaptations/web.md)

### Features
- [Quick Capture Feature](./features/quick-capture/)
- [Item Management](./features/item-management/)
- [Spaces & Organization](./features/spaces/)

### Accessibility
- [Accessibility Guidelines](./accessibility/guidelines.md)
- [Testing Procedures](./accessibility/testing.md)
- [WCAG Compliance](./accessibility/compliance.md)

## Design Principles

### 1. Fluid Over Fixed
Every interaction should feel continuous and natural. We avoid abrupt transitions and favor smooth, physics-based animations that respect user intent.

### 2. Content First, Always
Chrome is minimal. Content is hero. Every pixel of UI should serve the user's productivity goals.

### 3. Adaptive Intelligence
The interface adapts to context - colors shift based on item type, spacing adjusts to content density, and interactions respond to user patterns.

### 4. Gestural Intimacy
Touch is conversation. Every tap, swipe, and long-press should feel responsive and purposeful, with immediate visual and haptic feedback.

### 5. Luminous Depth
We use light, shadow, and blur to create depth without heaviness. Layers feel distinct but connected, like sheets of glass.

## Visual Identity

**later** is distinguished by:
- **Gradient-infused interfaces** with subtle chromatic transitions
- **Generous whitespace** that gives content room to breathe
- **Bold, confident typography** using Inter and JetBrains Mono
- **Soft, rounded corners** throughout (12-20px radii)
- **Glass morphism effects** for overlays and elevated surfaces
- **Physics-based micro-interactions** that feel alive

## Design System Version

**Version 1.0.0** - Initial comprehensive design system
- Complete color palette with light/dark modes
- Typography system with responsive scaling
- Component library with 15+ core components
- Animation system with standardized timings
- Platform-specific adaptations for iOS/Android/Web

## Implementation Status

| Component | Design | iOS | Android | Web |
|-----------|--------|-----|---------|-----|
| Item Cards | ✓ | Pending | Pending | Pending |
| Quick Capture | ✓ | Pending | Pending | Pending |
| Navigation | ✓ | Pending | Pending | Pending |
| Buttons | ✓ | Pending | Pending | Pending |
| Forms | ✓ | Pending | Pending | Pending |

## Getting Started

### For Designers
1. Read the [Design Philosophy](./design-system/style-guide.md#design-philosophy)
2. Familiarize yourself with [Design Tokens](./design-system/tokens/)
3. Review [Component Specifications](./design-system/components/)

### For Developers
1. Review [Implementation Notes](./design-system/style-guide.md#implementation-notes)
2. Check [Platform Adaptations](./design-system/platform-adaptations/) for your target
3. Reference [Component Specifications](./design-system/components/) during development

### For Product Managers
1. Understand [Design Principles](#design-principles)
2. Review [Feature Documentation](./features/)
3. Check [Accessibility Guidelines](./accessibility/guidelines.md)

## Resources

### Design Tools
- Figma component library (coming soon)
- Design tokens JSON export
- Icon library

### Development Tools
- Flutter implementation packages
- Design token parser
- Animation presets

## Contact & Contribution

This is a living design system. As later evolves, so will these specifications.

**Last Updated**: October 19, 2025
**Maintained By**: later Design Team
