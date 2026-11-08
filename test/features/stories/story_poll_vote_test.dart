import 'package:dali_alsham/features/stories/domain/entities/story.dart';
import 'package:flutter_test/flutter_test.dart';

const _shaurma = StoryPollOption(id: 4, text: 'شاورما', votesCount: 7);
const _falafel = StoryPollOption(id: 5, text: 'فلافل', votesCount: 3);

const _open = StoryPoll(
  id: 2,
  question: 'ما هو طبقك المفضل؟',
  totalVotes: 10,
  options: [_shaurma, _falafel],
);

const _answered = StoryPoll(
  id: 2,
  question: 'ما هو طبقك المفضل؟',
  totalVotes: 10,
  options: [_shaurma, _falafel],
  myVoteOptionId: 5,
);

void main() {
  test('the vote a reader sends moves the option and the total', () {
    final voted = _open.withVote(4);

    expect(voted.myVoteOptionId, 4);
    expect(voted.totalVotes, 11);
    expect(voted.options.first.votesCount, 8);
    expect(voted.options.last.votesCount, 3);
    expect(voted.shareOf(voted.options.first), closeTo(8 / 11, 0.0001));
  });

  test('a second answer leaves the tally where it stands', () {
    final voted = _answered.withVote(4);

    expect(voted, same(_answered));
  });

  test('an option that is not in this poll leaves the tally where it stands', () {
    final voted = _open.withVote(99);

    expect(voted, same(_open));
  });

  test('the story keeps everything but its poll', () {
    final story = Story(
      id: 5,
      type: StoryType.poll,
      caption: 'عرض جديد اليوم',
      hoursLeft: 21,
      service: const StoryService(id: 1, name: 'الاسد', slug: 'amran'),
      poll: _open,
    );

    final voted = story.withVote(5);

    expect(voted.poll?.myVoteOptionId, 5);
    expect(voted.poll?.totalVotes, 11);
    expect(voted.caption, story.caption);
    expect(voted.hoursLeft, story.hoursLeft);
    expect(voted.service, story.service);
    expect(voted.poll?.question, _open.question);
  });

  test('a story with no poll has nothing to answer', () {
    const photo = Story(
      id: 2,
      type: StoryType.image,
      imageUrl: 'https://dalildimashq.com/storage/stories/2.png',
    );

    expect(photo.withVote(4), same(photo));
  });
}
