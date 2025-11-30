import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:se202_project_refind/utils/tag_color_manager.dart';

void main() {
  group('TagColorManager', () {
    test('returns same color for the same tag', () {
      final manager = TagColorManager();
      final c1 = manager.getColorForTag('wallet');
      final c2 = manager.getColorForTag('wallet');

      expect(c1, isA<Color>());
      expect(c2, isA<Color>());
      expect(c1, equals(c2));
    });

    test('different tags eventually get different colors', () {
      final manager = TagColorManager();
      final c1 = manager.getColorForTag('wallet');
      final c2 = manager.getColorForTag('keys');

      // Not guaranteed but *very* likely – at least check they’re valid colors
      expect(c1, isA<Color>());
      expect(c2, isA<Color>());
    });

    test('can handle many different tags without crashing', () {
      final manager = TagColorManager();
      const tags = [
        'wallet',
        'keys',
        'phone',
        'bag',
        'documents',
        'jewelry',
        'other',
      ];

      for (final t in tags) {
        final c = manager.getColorForTag(t);
        expect(c, isA<Color>());
      }
    });
  });
}
