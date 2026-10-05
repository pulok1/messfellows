import 'package:flutter_test/flutter_test.dart';
import 'package:messfellows/features/shared/widgets/member_avatar.dart';

void main() {
  group('MemberAvatar.initialsOf', () {
    test('takes the first letter of up to two words', () {
      expect(MemberAvatar.initialsOf('Rahim Uddin'), 'RU');
      expect(MemberAvatar.initialsOf('Karim'), 'K');
      expect(MemberAvatar.initialsOf('md abdul karim'), 'MA');
    });

    test('ignores extra whitespace', () {
      expect(MemberAvatar.initialsOf('  Sajid   Hasan  '), 'SH');
    });

    test('falls back to ? for an empty name', () {
      expect(MemberAvatar.initialsOf(''), '?');
      expect(MemberAvatar.initialsOf('   '), '?');
    });

    test('keeps a Bangla name\'s first character whole', () {
      expect(MemberAvatar.initialsOf('রহিম'), 'র');
    });
  });
}
