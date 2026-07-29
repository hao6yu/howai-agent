import 'package:flutter_test/flutter_test.dart';
import 'package:haogpt/services/content_report_service.dart';

void main() {
  group('MessageReportStatus', () {
    test('only hides image content after it has been reported', () {
      expect(
        MessageReportStatus.fromReportedState(
          isReported: true,
          hasImages: true,
        ).shouldHide,
        isTrue,
      );
      expect(
        MessageReportStatus.fromReportedState(
          isReported: true,
          hasImages: false,
        ).shouldHide,
        isFalse,
      );
      expect(
        MessageReportStatus.fromReportedState(
          isReported: false,
          hasImages: true,
        ).shouldHide,
        isFalse,
      );
    });
  });
}
