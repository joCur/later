export 'temporal_flow_theme.dart';

import 'package:flutter/material.dart';
import 'temporal_flow_theme.dart';

/// Extension on BuildContext to provide convenient access to TemporalFlowTheme
extension TemporalFlowContextExtension on BuildContext {
  /// Get the TemporalFlowTheme extension from the current theme
  TemporalFlowTheme get temporalTheme =>
      Theme.of(this).extension<TemporalFlowTheme>()!;
}
