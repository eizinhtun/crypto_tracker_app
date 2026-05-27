import 'package:crypto_tracker_app/core/utils/html_text_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HtmlTextFormatter', () {
    test('converts simple HTML description into display text', () {
      final text = HtmlTextFormatter.plainText(
        '<p>Bitcoin &amp; Ethereum are <strong>crypto</strong>.</p>',
      );

      expect(text, 'Bitcoin & Ethereum are crypto.');
    });
  });
}
