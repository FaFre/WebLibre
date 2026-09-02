import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/services/proxy_start_expectation.dart';

void main() {
  const tor = TorProxyConnectionId();
  const singbox = SingboxProxyConnectionId('profile-1');
  const otherSingbox = SingboxProxyConnectionId('profile-2');

  test('nothing is expected once every backend has settled', () {
    final expectation = ProxyStartExpectation.none;

    expect(expectation.covers(tor.encode()), isFalse);
    expect(expectation.covers(singbox.encode()), isFalse);
  });

  test('an unresolved startup covers every connection', () {
    final expectation = ProxyStartExpectation(
      unresolved: true,
      startingProxyIds: {},
    );

    expect(expectation.covers(tor.encode()), isTrue);
    expect(expectation.covers(singbox.encode()), isTrue);
  });

  test('a starting backend covers only its own connections', () {
    final torOnly = ProxyStartExpectation(
      unresolved: false,
      startingProxyIds: {tor.encode()},
    );

    expect(torOnly.covers(tor.encode()), isTrue);
    expect(
      torOnly.covers(singbox.encode()),
      isFalse,
      reason: 'a sing-box profile must not be held behind a Tor bootstrap',
    );

    final singboxOnly = ProxyStartExpectation(
      unresolved: false,
      startingProxyIds: {singbox.encode()},
    );

    expect(singboxOnly.covers(singbox.encode()), isTrue);
    expect(singboxOnly.covers(tor.encode()), isFalse);
  });

  test('one starting sing-box profile does not cover another', () {
    final expectation = ProxyStartExpectation(
      unresolved: false,
      startingProxyIds: {singbox.encode()},
    );

    expect(expectation.covers(singbox.encode()), isTrue);
    expect(
      expectation.covers(otherSingbox.encode()),
      isFalse,
      reason:
          'a profile nobody is starting has to fail at once, even while '
          'another profile of the same backend is coming up',
    );
  });

  test('equal by value, so an unchanged answer pushes no new snapshot', () {
    expect(
      ProxyStartExpectation(
        unresolved: false,
        startingProxyIds: {tor.encode(), singbox.encode()},
      ),
      ProxyStartExpectation(
        // The same set, in the order the other backend happened to report it.
        unresolved: false,
        startingProxyIds: {singbox.encode(), tor.encode()},
      ),
      reason:
          'the Tor status stream ticks far more often than this answer '
          'changes, and every inequality recomputes the routing snapshot',
    );

    expect(
      ProxyStartExpectation(unresolved: true, startingProxyIds: const {}),
      isNot(ProxyStartExpectation.none),
    );
  });

  test('an unknown connection id is never waited for', () {
    final expectation = ProxyStartExpectation(
      unresolved: true,
      startingProxyIds: {},
    );

    expect(
      expectation.covers('some-retired-backend:1'),
      isFalse,
      reason: 'startup not having finished does not make it startable',
    );
  });
}
