import 'package:equatable/equatable.dart';

/// How the reviews endpoint orders its pages.
enum ServiceReviewSort {
  latest('latest'),
  highest('highest'),
  lowest('lowest');

  const ServiceReviewSort(this.wire);

  final String wire;

  static ServiceReviewSort fromWire(String? wire) => switch (wire) {
    'highest' => ServiceReviewSort.highest,
    'lowest' => ServiceReviewSort.lowest,
    _ => ServiceReviewSort.latest,
  };
}

/// The average and the five-bar spread the reviews endpoint summarizes.
class ServiceReviewSummary extends Equatable {
  const ServiceReviewSummary({
    this.averageRating = 0,
    this.totalReviews = 0,
    this.breakdown = const {},
  });

  final double averageRating;
  final int totalReviews;

  /// Star value (1..5) to how many reviews gave it.
  final Map<int, int> breakdown;

  int countFor(int stars) => breakdown[stars] ?? 0;

  @override
  List<Object?> get props => [averageRating, totalReviews, breakdown];
}

/// One reader's rating and comment.
class ServiceReview extends Equatable {
  const ServiceReview({
    required this.rating,
    this.id,
    this.comment,
    this.isMine = false,
    this.userName,
    this.userAvatar,
    this.createdAt,
  });

  final int rating;

  /// Server identifier of the review; needed by signed-in actions
  /// such as editing or deleting the reader's own review.
  final int? id;
  final String? comment;

  /// Only the signed-in variant can say the review is the reader's own.
  final bool isMine;
  final String? userName;
  final String? userAvatar;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    rating,
    id,
    comment,
    isMine,
    userName,
    userAvatar,
    createdAt,
  ];
}

/// One page of reviews with the summary that heads them.
class ServiceReviewPage {
  const ServiceReviewPage({
    required this.reviews,
    required this.hasMore,
    required this.summary,
    this.nextPage,
    this.sort = ServiceReviewSort.latest,
  });

  final List<ServiceReview> reviews;
  final bool hasMore;
  final int? nextPage;
  final ServiceReviewSummary summary;
  final ServiceReviewSort sort;
}