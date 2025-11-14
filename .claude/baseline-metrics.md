# Baseline Metrics - Pre Riverpod 3.0 Migration

**Date:** November 13, 2025
**Branch:** feature/riverpod-3.0-migration

## Code Quality

### Analyzer
- **Result:** No issues found!
- **Time:** 2.3s
- **Errors:** 0
- **Warnings:** 0
- **Info:** 0

## Test Suite

### Test Execution
- **Status:** Running (captured ~1000+ tests)
- **Some Tests Failing:** 47 failures observed during run
- **Test Count:** 900+ tests passing, ~47 failing
- **Notes:** Some widget tests have hit test warnings (non-fatal)

### Expected Results
- Target: 200+ tests with >70% coverage
- Current baseline will be documented after full test run completes

## Build Performance

**Build time baseline** - To be measured with `flutter build apk --debug`

## Dependencies

### Current Versions (Pre-Migration)
```yaml
dependencies:
  provider: ^6.1.0          # To be kept temporarily

dev_dependencies:
  build_runner: ^2.10.1     # To be updated to 2.4.13
  mockito: ^5.5.1           # To be downgraded to 5.5.0
```

### New Riverpod 3.0.3 Dependencies
```yaml
dependencies:
  flutter_riverpod: ^3.0.3

dev_dependencies:
  riverpod_annotation: ^3.0.3
  riverpod_generator: ^3.0.3
  riverpod_lint: ^3.0.3
  build_runner: ^2.4.13      # Compatible version
  mockito: ^5.5.0            # Downgraded for compatibility
```

## Notes

- Flutter analyze is clean (0 issues)
- Build_runner successfully installed and tested
- Some test failures exist in baseline (47 failures) - need investigation
- Test warnings related to widget tap() hit testing are non-fatal
