import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/domain/entities/profile.dart';
import 'package:weblibre/features/user/domain/presentation/utils/profile_labels.dart';

const _a = '0199a0b1-1111-7111-8111-111111111111';
const _b = '0199a0b1-2222-7222-8222-222222222222';
const _c = '0199a0b1-3333-7333-8333-333333333333';

Profile named(String id, String name) => Profile(id: id, name: name);

void main() {
  test('unique names are shown as they are', () {
    final profiles = [named(_a, 'Personal'), named(_b, 'Work')];
    final labels = profileLabels(profiles);

    // No uuid fragment where nothing is ambiguous: beside every name it would
    // be noise that teaches the user to skip past it.
    expect(labelOfProfile(profiles[0], labels), 'Personal');
    expect(labelOfProfile(profiles[1], labels), 'Work');
  });

  test('a shared name is disambiguated on every profile that shares it', () {
    // `validateProfileName` checks only that a name is present and well-formed,
    // so this is a state a user can reach, not a corrupt one.
    final profiles = [
      named(_a, 'Work'),
      named(_b, 'Work'),
      named(_c, 'Personal'),
    ];
    final labels = profileLabels(profiles);

    expect(labelOfProfile(profiles[0], labels), startsWith('Work ('));
    expect(labelOfProfile(profiles[1], labels), startsWith('Work ('));
    expect(
      labelOfProfile(profiles[0], labels),
      isNot(labelOfProfile(profiles[1], labels)),
    );
    // Untouched: it is not part of the collision.
    expect(labelOfProfile(profiles[2], labels), 'Personal');
  });

  test('the labels of two same-named profiles actually differ', () {
    // The whole point. A suffix that collided too would be decoration.
    // These ids share their first eight characters on purpose: uuid v7 is
    // time-ordered, so profiles created in the same session really do. A
    // leading-prefix fragment would have printed the same label twice.
    final profiles = [named(_a, 'Work'), named(_b, 'Work')];
    final labels = profileLabels(profiles);

    expect(
      labelOfProfile(profiles[0], labels),
      isNot(labelOfProfile(profiles[1], labels)),
    );
  });

  test('three of a kind are all disambiguated', () {
    final profiles = [named(_a, 'Work'), named(_b, 'Work'), named(_c, 'Work')];
    final labels = profileLabels(profiles);

    expect(
      profiles.map((p) => labelOfProfile(p, labels)).toSet(),
      hasLength(3),
    );
  });

  test('an empty list has no duplicates', () {
    expect(profileLabels(const <Profile>[]), isEmpty);
  });

  test('ids differing only in their tail are still told apart', () {
    // The realistic shape: uuid v7 puts a millisecond timestamp in the leading
    // 48 bits, so two profiles made seconds apart differ only near the end.
    final profiles = [
      named('0199a0b1-1111-7111-8111-aaaaaaaaaaaa', 'Work'),
      named('0199a0b1-1111-7111-8111-aaaaaaaaaaab', 'Work'),
    ];
    final labels = profileLabels(profiles);

    expect(
      labelOfProfile(profiles[0], labels),
      isNot(labelOfProfile(profiles[1], labels)),
    );
  });
}
