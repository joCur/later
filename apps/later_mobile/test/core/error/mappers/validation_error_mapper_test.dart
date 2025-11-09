import 'package:flutter_test/flutter_test.dart';
import 'package:later_mobile/core/error/error.dart';

void main() {
  group('ValidationErrorMapper', () {
    group('requiredField', () {
      test('creates AppError with validationRequired code', () {
        final error = ValidationErrorMapper.requiredField('Email');

        expect(error.code, ErrorCode.validationRequired);
        expect(error.message, contains('Required field is missing'));
        expect(error.message, contains('Email'));
      });

      test('includes fieldName in context', () {
        final error = ValidationErrorMapper.requiredField('Username');

        expect(error.context, isNotNull);
        expect(error.context!['fieldName'], 'Username');
      });

      test('generates correct localized message', () {
        final error = ValidationErrorMapper.requiredField('Password');

        // Test fallback message (without localization)
        final message = error.getUserMessageLocalized();
        expect(message, 'Password is required.');
      });

      test('validation errors have low severity', () {
        final error = ValidationErrorMapper.requiredField('Name');

        expect(error.severity, ErrorSeverity.low);
      });

      test('validation errors are not retryable', () {
        final error = ValidationErrorMapper.requiredField('Email');

        expect(error.isRetryable, isFalse);
      });
    });

    group('invalidFormat', () {
      test('creates AppError with validationInvalidFormat code', () {
        final error = ValidationErrorMapper.invalidFormat('Email');

        expect(error.code, ErrorCode.validationInvalidFormat);
        expect(error.message, contains('Invalid format'));
        expect(error.message, contains('Email'));
      });

      test('includes fieldName in context', () {
        final error = ValidationErrorMapper.invalidFormat('Phone number');

        expect(error.context, isNotNull);
        expect(error.context!['fieldName'], 'Phone number');
      });

      test('generates correct localized message', () {
        final error = ValidationErrorMapper.invalidFormat('Email address');

        // Test fallback message (without localization)
        final message = error.getUserMessageLocalized();
        expect(message, 'Email address has an invalid format.');
      });

      test('validation errors have low severity', () {
        final error = ValidationErrorMapper.invalidFormat('URL');

        expect(error.severity, ErrorSeverity.low);
      });
    });

    group('outOfRange', () {
      test('creates AppError with validationOutOfRange code', () {
        final error = ValidationErrorMapper.outOfRange('Age', '18', '120');

        expect(error.code, ErrorCode.validationOutOfRange);
        expect(error.message, contains('out of range'));
        expect(error.message, contains('Age'));
        expect(error.message, contains('18'));
        expect(error.message, contains('120'));
      });

      test('includes fieldName, min, and max in context', () {
        final error = ValidationErrorMapper.outOfRange('Price', '0', '9999');

        expect(error.context, isNotNull);
        expect(error.context!['fieldName'], 'Price');
        expect(error.context!['min'], '0');
        expect(error.context!['max'], '9999');
      });

      test('generates correct localized message', () {
        final error = ValidationErrorMapper.outOfRange('Age', '18', '65');

        // Test fallback message (without localization)
        final message = error.getUserMessageLocalized();
        expect(message, 'Age must be between 18 and 65.');
      });

      test('handles string ranges for non-numeric fields', () {
        final error = ValidationErrorMapper.outOfRange(
          'Name length',
          '3',
          '50',
        );

        expect(error.code, ErrorCode.validationOutOfRange);
        expect(error.context!['min'], '3');
        expect(error.context!['max'], '50');
      });

      test('validation errors have low severity', () {
        final error = ValidationErrorMapper.outOfRange('Score', '0', '100');

        expect(error.severity, ErrorSeverity.low);
      });
    });

    group('duplicate', () {
      test('creates AppError with validationDuplicate code', () {
        final error = ValidationErrorMapper.duplicate('Username');

        expect(error.code, ErrorCode.validationDuplicate);
        expect(error.message, contains('Duplicate value'));
        expect(error.message, contains('Username'));
      });

      test('includes fieldName in context', () {
        final error = ValidationErrorMapper.duplicate('Email');

        expect(error.context, isNotNull);
        expect(error.context!['fieldName'], 'Email');
      });

      test('generates correct localized message', () {
        final error = ValidationErrorMapper.duplicate('Username');

        // Test fallback message (without localization)
        final message = error.getUserMessageLocalized();
        expect(message, 'Username already exists.');
      });

      test('validation errors have low severity', () {
        final error = ValidationErrorMapper.duplicate('Space name');

        expect(error.severity, ErrorSeverity.low);
      });

      test('validation errors are not retryable', () {
        final error = ValidationErrorMapper.duplicate('Tag');

        expect(error.isRetryable, isFalse);
      });
    });

    group('edge cases', () {
      test('handles special characters in field names', () {
        final error = ValidationErrorMapper.requiredField('User\'s Email');

        expect(error.context!['fieldName'], 'User\'s Email');
      });

      test('handles empty field names gracefully', () {
        final error = ValidationErrorMapper.requiredField('');

        expect(error.code, ErrorCode.validationRequired);
        expect(error.context!['fieldName'], '');
      });

      test('handles very long field names', () {
        const longName = 'This is a very long field name that should still work';
        final error = ValidationErrorMapper.requiredField(longName);

        expect(error.context!['fieldName'], longName);
      });

      test('handles numeric strings in outOfRange', () {
        final error = ValidationErrorMapper.outOfRange('Score', '0.0', '100.5');

        expect(error.context!['min'], '0.0');
        expect(error.context!['max'], '100.5');
      });

      test('handles negative ranges in outOfRange', () {
        final error = ValidationErrorMapper.outOfRange('Temperature', '-40', '50');

        expect(error.context!['min'], '-40');
        expect(error.context!['max'], '50');
      });
    });
  });
}
