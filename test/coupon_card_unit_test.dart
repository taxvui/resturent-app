import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_pos/app/pages/common/widgets/widgets.dart';

class TestableCouponCardData extends CouponCardData {
  final DateTime _now;

  TestableCouponCardData({
    required DateTime now,
    super.title,
    super.subtitle,
    super.startDate,
    super.endDate,
    super.code,
    super.discount,
    super.isPercentage,
  }) : _now = now;

  @override
  bool get isStarted => startDate != null && _now.isAfter(startDate!);

  @override
  bool get isOnGoing => startDate != null && endDate != null && !_now.isBefore(startDate!) && !_now.isAfter(endDate!);

  @override
  bool get isExpired => endDate != null && _now.isAfter(endDate!);
}

void main() {
  final jan10 = DateTime(2025, 1, 10);
  final jan20 = DateTime(2025, 1, 20);

  test('Before start', () {
    final c = TestableCouponCardData(
      now: DateTime(2025, 1, 1),
      startDate: jan10,
      endDate: jan20,
    );
    expect(c.isStarted, false);
    expect(c.isOnGoing, false);
    expect(c.isExpired, false);
  });

  test('Ongoing period', () {
    final c = TestableCouponCardData(
      now: DateTime(2025, 1, 15),
      startDate: jan10,
      endDate: jan20,
    );
    expect(c.isStarted, true);
    expect(c.isOnGoing, true);
    expect(c.isExpired, false);
  });

  test('After expiry', () {
    final c = TestableCouponCardData(
      now: DateTime(2025, 1, 21),
      startDate: jan10,
      endDate: jan20,
    );
    expect(c.isStarted, true);
    expect(c.isOnGoing, false);
    expect(c.isExpired, true);
  });
}
