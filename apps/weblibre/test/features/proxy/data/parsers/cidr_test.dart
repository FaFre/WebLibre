import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/proxy/data/parsers/cidr.dart';

void main() {
  group('tryParseCidr', () {
    test('a bare IPv4 address is one host', () {
      expect(tryParseCidr('10.0.0.2'), (
        address: '10.0.0.2',
        prefixLength: 32,
        isIpv6: false,
      ));
    });

    test('a bare IPv6 address is one host', () {
      expect(tryParseCidr('fd00::2'), (
        address: 'fd00::2',
        prefixLength: 128,
        isIpv6: true,
      ));
    });

    test('an explicit prefix is kept', () {
      expect(tryParseCidr('10.0.0.0/24')?.prefixLength, 24);
      expect(tryParseCidr('fd00::/64')?.prefixLength, 64);
      expect(tryParseCidr('0.0.0.0/0')?.prefixLength, 0);
    });

    test('brackets left over from endpoint syntax are dropped', () {
      expect(tryNormalizeCidr('[fd00::2]'), 'fd00::2/128');
    });

    test('a prefix outside its family is refused', () {
      expect(tryParseCidr('10.0.0.2/33'), isNull);
      expect(tryParseCidr('fd00::2/129'), isNull);
      expect(tryParseCidr('10.0.0.2/-1'), isNull);
    });

    test('something that is not an address is refused, not guessed at', () {
      expect(tryParseCidr('10.0.0'), isNull);
      expect(tryParseCidr('10.0.0.256'), isNull);
      expect(tryParseCidr('example.com'), isNull);
      expect(tryParseCidr('fd00::2::3'), isNull);
      expect(tryParseCidr('fe80::1%wlan0'), isNull);
      expect(tryParseCidr(''), isNull);
      expect(tryParseCidr('  '), isNull);
    });

    test('an IPv4-mapped IPv6 address parses as IPv6', () {
      expect(tryNormalizeCidr('::ffff:192.0.2.1'), '::ffff:192.0.2.1/128');
      expect(
        tryNormalizeCidr('1:2:3:4:5:6:192.0.2.1'),
        '1:2:3:4:5:6:192.0.2.1/128',
      );
    });

    test('compression may sit directly in front of the IPv4 part', () {
      // Splitting the address at its last colon takes one of the two colons
      // with it, and what is left parses as nothing.
      expect(
        tryNormalizeCidr('2001:db8::192.0.2.1'),
        '2001:db8::192.0.2.1/128',
      );
      expect(tryNormalizeCidr('::192.0.2.1'), '::192.0.2.1/128');
      expect(tryNormalizeCidr('::192.0.2.1/96'), '::192.0.2.1/96');
    });

    test(
      'an IPv4 tail still has to leave room for the groups it stands for',
      () {
        expect(
          tryParseCidr('1:2:3:4:5:6:7:192.0.2.1'),
          isNull,
          reason: 'the quad is two groups, so this is ten',
        );
        expect(tryParseCidr('1:2:3:4:5:192.0.2.1'), isNull);
        expect(tryParseCidr('2001:db8::1.2.3'), isNull);
        expect(tryParseCidr('::ffff:192.0.2.1%eth0'), isNull);
      },
    );

    test('a fully written IPv6 address needs all eight groups', () {
      expect(tryParseCidr('2001:db8:0:0:0:0:0:1'), isNotNull);
      expect(tryParseCidr('2001:db8:0:0:0:0:1'), isNull);
    });
  });
}
