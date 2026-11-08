import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/story.dart';
import '../../domain/usecases/get_story_feed.dart';

enum StoryFeedStatus { initial, loading, ready, failure }

class StoryFeedState extends Equatable {
  const StoryFeedState({
    this.status = StoryFeedStatus.initial,
    this.stories = const [],
    this.failure,
  });

  final StoryFeedStatus status;
  final List<Story> stories;
  final Failure? failure;

  @override
  List<Object?> get props => [status, stories, failure];
}

/// The stories the public listing hands out, one page of them.
class StoryFeedCubit extends Cubit<StoryFeedState> {
  StoryFeedCubit(this._getStoryFeed) : super(const StoryFeedState());

  final GetStoryFeed _getStoryFeed;
  int _requestId = 0;

  /// What the list on screen was fetched with, so a repeated call in the same
  /// language does not blank the strip the reader is looking at.
  String? _shownLocale;

  Future<void> load(String locale) async {
    final requestId = ++_requestId;
    final keepsList = _shownLocale == locale && state.stories.isNotEmpty;
    if (!keepsList) {
      emit(const StoryFeedState(status: StoryFeedStatus.loading));
    }

    final result = await _getStoryFeed(StoryFeedParams(locale: locale));
    if (isClosed || requestId != _requestId) return;
    _shownLocale = locale;

    result.fold(
      (failure) {
        if (!keepsList) {
          emit(
            StoryFeedState(status: StoryFeedStatus.failure, failure: failure),
          );
        }
      },
      (feed) => emit(
        StoryFeedState(status: StoryFeedStatus.ready, stories: feed.stories),
      ),
    );
  }
}
