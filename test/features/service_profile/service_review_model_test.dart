import 'package:dali_alsham/features/service_profile/data/models/service_review_model.dart';
import 'package:dali_alsham/features/service_profile/domain/entities/service_review.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads the id the signed-in reviews carry', () {
    final review = ServiceReviewModel.fromJson({
      'id': 34,
      'rating': 3,
      'comment': 'الخدمة بطيئة',
      'is_mine': true,
      'user': {'id': 8, 'name': 'عمران ابراهيم', 'avatar': null},
      'created_at': '2026-11-06T14:25:33+03:00',
    });

    expect(review.id, 34);
    expect(review.rating, 3);
    expect(review.comment, 'الخدمة بطيئة');
    expect(review.isMine, isTrue);
    expect(review.userName, 'عمران ابراهيم');
    expect(review.userAvatar, isNull);
    expect(review.createdAt, DateTime.parse('2026-11-06T14:25:33+03:00'));
  });

  test('a review without an id is still readable', () {
    final review = ServiceReviewModel.fromJson({
      'rating': 5,
      'comment': 'رائع',
      'user': {'name': 'ali'},
    });

    expect(review.id, isNull);
    expect(review.isMine, isFalse);
    expect(review.comment, 'رائع');
  });

  test('a star value outside the scale is clamped', () {
    expect(ServiceReviewModel.fromJson({'rating': 9}).rating, 5);
    expect(ServiceReviewModel.fromJson({'rating': -2}).rating, 0);
  });

  test('the sort the page asks for travels as its wire word', () {
    expect(ServiceReviewSort.lowest.wire, 'lowest');
    expect(ServiceReviewSort.highest.wire, 'highest');
    expect(ServiceReviewSort.latest.wire, 'latest');
    expect(ServiceReviewSort.fromWire('lowest'), ServiceReviewSort.lowest);
    expect(ServiceReviewSort.fromWire('unknown'), ServiceReviewSort.latest);
  });
}
