---
title: later - Design Documentation
description: Mobile-first design system and specifications for the later productivity app
last-updated: 2025-10-21
version: 2.0.0
status: approved
---

# later - Design Documentation

> **A unified productivity experience that flows with your thoughts**

## Overview

This documentation contains the complete design system, specifications, and implementation guidelines for "later" - a productivity app that unifies tasks, notes, and lists in a single fluid interface.

**Current Focus**: Mobile-First Bold Redesign - optimized for performance and visual distinctiveness on small screens.

## Quick Navigation

### Primary Documentation

**[📱 Mobile-First Bold Redesign](./MOBILE-FIRST-BOLD-REDESIGN.md)**
Complete mobile design strategy with visual specifications, component details, and design rationale.

**[🚀 Mobile Implementation Quick Start](./MOBILE_IMPLEMENTATION_QUICK_START.md)**
Developer guide with code examples, setup instructions, and implementation patterns.

**[📋 Mobile Design Cheat Sheet](./MOBILE_DESIGN_CHEAT_SHEET.md)**
Quick reference for common patterns, values, and design decisions.

**[🎨 Design Tokens Reference](./DESIGN_TOKENS_REFERENCE.md)**
Complete token reference including colors, typography, spacing, and animations.

**[👀 Mobile Visual Comparison](./MOBILE_VISUAL_COMPARISON.md)**
Before/after comparison showing the evolution from desktop-first to mobile-first design.

**[📦 Flutter Packages](./FLUTTER-PACKAGES.md)**
Curated list of recommended packages for implementing the design system.

---

## Design Philosophy

later's mobile-first design emphasizes:

- **Bold & Distinctive**: Thick gradient borders, strong typography, and clear visual hierarchy
- **Performance First**: Solid backgrounds, optimized animations, 60fps on older devices
- **Mobile Native**: Circular FAB, icon-only navigation, thumb-friendly interactions
- **Clear Hierarchy**: 6px gradient pill borders that are actually visible on phones
- **Readable Content**: 18px bold titles, generous spacing, high contrast

## Key Design Principles

### 1. Mobile-First, Always
Every design decision prioritizes the mobile experience. Desktop is an enhancement, not the baseline.

### 2. Performance is Non-Negotiable
We choose solid colors over gradients, simple animations over complex effects, and native patterns over custom solutions.

### 3. Boldness Over Subtlety
If it's not visible on a 320px screen at arm's length, it's too subtle. Our designs are confident and clear.

### 4. Content First
Minimal chrome, maximum content. Every pixel serves the user's productivity goals.

### 5. Gestural Intimacy
Touch is conversation. Swipes, taps, and long-presses feel responsive with immediate visual and haptic feedback.

## What Changed from v1.0

**v1.0 (Temporal Flow)** was desktop-first with glass morphism, subtle borders, and gradient-heavy designs. It looked generic on mobile and performed poorly on older devices.

**v2.0 (Mobile-First Bold)** addresses these issues:

- ✅ **6px gradient pill borders** (vs 2px subtle strips) = visible on phones
- ✅ **18px bold titles** (vs 16px) = readable at a glance
- ✅ **Solid backgrounds** (no gradient fills) = 60fps on old Android
- ✅ **Circular FAB** (not squircle) = Android-native feel
- ✅ **Icon-only navigation** = more spacious on small screens

## Visual Identity

**later** is distinguished by:

- **Thick gradient pill borders** on all cards (6px width)
- **Bold, confident typography** with clear size hierarchy
- **Generous whitespace** that gives content room to breathe
- **Solid color backgrounds** for performance
- **Circular floating action button** with gradient
- **Icon-only bottom navigation** with gradient underline indicators
- **Spring-physics animations** that feel alive

## Getting Started

### For Designers

1. Start with **[Mobile-First Bold Redesign](./MOBILE-FIRST-BOLD-REDESIGN.md)** to understand the complete design system
2. Reference **[Design Tokens Reference](./DESIGN_TOKENS_REFERENCE.md)** for exact values
3. Use **[Mobile Design Cheat Sheet](./MOBILE_DESIGN_CHEAT_SHEET.md)** for quick lookups

### For Developers

1. Begin with **[Mobile Implementation Quick Start](./MOBILE_IMPLEMENTATION_QUICK_START.md)** for setup and code examples
2. Check **[Flutter Packages](./FLUTTER-PACKAGES.md)** for recommended dependencies
3. Reference **[Design Tokens Reference](./DESIGN_TOKENS_REFERENCE.md)** for implementation values

### For Product Managers

1. Read the **[Mobile Visual Comparison](./MOBILE_VISUAL_COMPARISON.md)** to understand the evolution
2. Review **[Mobile-First Bold Redesign](./MOBILE-FIRST-BOLD-REDESIGN.md)** for the complete strategy
3. Reference **[Mobile Design Cheat Sheet](./MOBILE_DESIGN_CHEAT_SHEET.md)** for quick decisions

## Implementation Status

| Component | Design | Implementation |
|-----------|--------|----------------|
| Item Cards | ✓ Complete | Phase 1 Complete |
| Navigation | ✓ Complete | Phase 2 Complete |
| FAB & Modal | ✓ Complete | Phase 3 Complete |
| Polish & Details | ✓ Complete | Phase 4 Complete |

**Status**: Mobile-first redesign fully implemented (Phases 1-4 complete)

## Resources

### Design Assets
- Color palette and gradients
- Typography scale and weights
- Component specifications
- Animation timing functions

### Development Tools
- Flutter packages list
- Design token constants
- Animation presets
- Code examples

## Version History

**v2.0.0** (October 2025) - Mobile-First Bold Redesign
- Complete mobile-first redesign
- Performance optimizations
- Bold visual language
- Removed glassmorphism and Temporal Flow references

**v1.0.0** (October 2025) - Initial Temporal Flow Design
- Desktop-first design system
- Glass morphism effects
- Gradient-heavy interfaces

---

**Last Updated**: October 21, 2025
**Current Version**: 2.0.0 (Mobile-First Bold)
**Maintained By**: later Design Team
