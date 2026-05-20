import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_pos/app/pages/common/widgets/widgets.dart';

// Test subclass with fixed now
class TestCouponCardData extends CouponCardData {
  final DateTime now;
  TestCouponCardData({
    required this.now,
    super.title,
    super.subtitle,
    super.startDate,
    super.endDate,
    super.code,
    super.discount,
    super.isPercentage,
  });

  @override
  bool get isStarted => startDate != null && now.isAfter(startDate!);

  @override
  bool get isOnGoing => startDate != null && endDate != null && !now.isBefore(startDate!) && !now.isAfter(endDate!);

  @override
  bool get isExpired => endDate != null && now.isAfter(endDate!);
}

void main() {
  const discountAmount = 25;
  const titleText = 'Special Offer';
  final jan1 = DateTime(2025, 1, 1);
  final jan10 = DateTime(2025, 1, 10);
  final jan15 = DateTime(2025, 1, 15);
  final jan20 = DateTime(2025, 1, 20);
  final jan21 = DateTime(2025, 1, 21);

  Widget makeTestable(TestCouponCardData data) {
    return MaterialApp(
      home: Scaffold(
        body: CouponCardWidget(
          data: data,
          seedColor: Colors.green,
        ),
      ),
    );
  }

  testWidgets('Before start: shows "Starts"', (WidgetTester tester) async {
    final data = TestCouponCardData(
      now: jan1,
      title: titleText,
      subtitle: 'Subtitle',
      startDate: jan10,
      endDate: jan20,
      discount: discountAmount,
      isPercentage: true,
    );
    await tester.pumpWidget(makeTestable(data));

    expect(find.text('Starts: 10 January 2025'), findsOneWidget);
    expect(find.textContaining('Till:'), findsNothing);
    expect(find.textContaining('Expired:'), findsNothing);
  });

  testWidgets('Ongoing: shows "Till"', (WidgetTester tester) async {
    final data = TestCouponCardData(
      now: jan15,
      title: titleText,
      subtitle: 'Subtitle',
      startDate: jan10,
      endDate: jan20,
      discount: discountAmount,
      isPercentage: false,
    );
    await tester.pumpWidget(makeTestable(data));

    expect(find.text('Till: 20 January 2025'), findsOneWidget);
    expect(find.textContaining('Starts:'), findsNothing);
    expect(find.textContaining('Expired:'), findsNothing);
  });

  testWidgets('Expired: shows "Expired"', (WidgetTester tester) async {
    final data = TestCouponCardData(
      now: jan21,
      title: titleText,
      subtitle: 'Subtitle',
      startDate: jan10,
      endDate: jan20,
      discount: discountAmount,
      isPercentage: false,
    );
    await tester.pumpWidget(makeTestable(data));

    expect(find.text('Expired: 20 January 2025'), findsOneWidget);
    expect(find.textContaining('Starts:'), findsNothing);
    expect(find.textContaining('Till:'), findsNothing);
  });
}
