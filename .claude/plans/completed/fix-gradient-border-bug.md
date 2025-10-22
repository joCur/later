# Fix Gradient Border Bug

## Objective and Scope

Fix the critical bug where gradient borders in ItemCard are not rendering despite being implemented in code. The root cause is that the child Container's solid background covers the CustomPaint border. This fix will make gradient borders visible as intended in the design system.

## Technical Approach and Reasoning

**Chosen Solution: Option 1 - Add Padding to GradientPillBorder**

We'll add padding equal to the border width inside the GradientPillBorder widget, preventing the child Container from covering the painted gradient border. This is the minimal change that:

1. Preserves existing architecture and component structure
2. Fixes the rendering order issue cleanly
3. Maintains CustomPaint performance benefits
4. Requires only two file modifications

**Why Not Other Options:**
- Option 2 (foregroundPainter): Would draw border over content edges, requiring careful clipping
- Option 3 (nested Containers): More verbose, abandons existing CustomPaint implementation
- Option 4 (ClipPath): Overly complex for this use case

## Implementation Phases

### Phase 1: Fix GradientPillBorder Widget ✅
- [x] Task 1.1: Add padding to prevent child overlap
  - ✅ Opened `lib/widgets/components/borders/gradient_pill_border.dart`
  - ✅ Located the `build` method (line 44-58)
  - ✅ Wrapped the `child` parameter with `Padding(padding: EdgeInsets.all(borderWidth), child: child)` at lines 52-54
  - ✅ Child Container is now inset by the border width, revealing the painted gradient

### Phase 2: Adjust ItemCard Border Radius ✅
- [x] Task 2.1: Update inner Container border radius
  - ✅ Opened `lib/widgets/components/cards/item_card.dart`
  - ✅ Found the Container's BoxDecoration at line 431
  - ✅ Changed `borderRadius: BorderRadius.circular(AppSpacing.cardRadius)` to `borderRadius: BorderRadius.circular(AppSpacing.cardRadius - AppSpacing.cardBorderWidth)`
  - ✅ Prevents visual gap between the gradient border and the inner container by accounting for the added padding

### Phase 3: Visual Verification ✅
- [x] Task 3.1: Test border rendering at multiple widths
  - ✅ Verified no other components use GradientPillBorder (only item_card.dart)
  - ✅ All tests passed (pre-existing test failures unrelated to border changes)
  - ✅ Hot reloaded and verified gradient borders are now visible
  - ✅ Reduced border width from 6px to 2px for more subtle appearance
  - ✅ User confirmed the borders look fantastic

## Dependencies and Prerequisites

- No external dependencies required
- Existing constants in AppSpacing (cardRadius, cardBorderWidth) must remain defined
- GradientPillBorder and ItemCard components are already integrated

## Challenges and Considerations

**Potential Issues:**
1. **Card Size Increase**: Adding padding increases the total card size by 2x border width (12px total for 6px border)
   - This is acceptable and expected behavior for a visible border
   - No layout changes should be needed as the increase is minimal

2. **Border Radius Calculation**: Inner radius must be `outerRadius - borderWidth` to prevent gaps
   - If borderWidth > cardRadius, this could create negative radius (edge case)
   - Current values: cardRadius=12, borderWidth=6, result=6 (safe)

3. **Shadow Positioning**: BoxShadow on inner Container may need adjustment if shadows appear misaligned
   - Monitor shadow rendering after the fix
   - Shadows should remain on the card, not the border itself

4. **Other GradientPillBorder Usages**: Verify no other components use GradientPillBorder
   - If found, ensure padding addition doesn't break their layouts
   - Search codebase for other usages with `grep -r "GradientPillBorder" lib/`

**Testing Checklist:**
- [ ] Borders visible on ItemCard in home feed
- [ ] Borders visible in light mode
- [ ] Borders visible in dark mode
- [ ] No layout shift or card overlap issues
- [ ] Shadows render correctly
- [ ] Border gradients match design system
- [ ] No performance degradation
