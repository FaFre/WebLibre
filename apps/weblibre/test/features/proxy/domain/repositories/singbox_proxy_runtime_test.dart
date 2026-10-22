import 'dart:async';

import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/proxy/data/models/singbox_proxy_profile.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/repositories/container_proxy.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_credentials.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/proxy/domain/services/singbox_start_retry.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ProxyProfile;
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/proxy_diagnostics_settings.dart';
import 'package:weblibre/features/user/data/models/proxy_routing_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_diagnostics_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('startProfile preserves already-running profiles', () async {
    final profile1 = _profile(id: 'profile-1', name: 'First');
    final profile2 = _profile(id: 'profile-2', name: 'Second');
    final client = _FakeSingboxProxyClient(
      _state([_endpoint(profile1.proxyConnectionId, port: 12080)]),
    );
    final container = _container(
      client: client,
      profilesRepository: _FakeProfilesRepository([profile1, profile2]),
    );
    addTearDown(container.dispose);

    await container.read(singboxProxyRuntimeRepositoryProvider.future);
    await container
        .read(singboxProxyRuntimeRepositoryProvider.notifier)
        .startProfile(profile2.id);

    expect(client.startCalls, hasLength(1));
    expect(
      client.startCalls.single.map((profile) => profile.id),
      unorderedEquals([profile1.proxyConnectionId, profile2.proxyConnectionId]),
    );
  });

  test('ensureProfilesStarted preserves already-running profiles', () async {
    final profile1 = _profile(id: 'profile-1', name: 'First');
    final profile2 = _profile(id: 'profile-2', name: 'Second');
    final client = _FakeSingboxProxyClient(
      _state([_endpoint(profile1.proxyConnectionId, port: 12080)]),
    );
    final container = _container(
      client: client,
      profilesRepository: _FakeProfilesRepository([profile1, profile2]),
    );
    addTearDown(container.dispose);

    await container.read(singboxProxyRuntimeRepositoryProvider.future);
    await container
        .read(singboxProxyRuntimeRepositoryProvider.notifier)
        .ensureProfilesStarted([profile2.id]);

    // The authoritative `startProfiles` would have stopped the first profile —
    // and with it every container routing through it — to serve a launch that
    // asked only about the second.
    expect(client.startCalls, hasLength(1));
    expect(
      client.startCalls.single.map((profile) => profile.id),
      unorderedEquals([profile1.proxyConnectionId, profile2.proxyConnectionId]),
    );
  });

  test('ensureProfilesStarted does not restart what already runs', () async {
    final profile1 = _profile(id: 'profile-1', name: 'First');
    final client = _FakeSingboxProxyClient(
      _state([_endpoint(profile1.proxyConnectionId, port: 12080)]),
    );
    final container = _container(
      client: client,
      profilesRepository: _FakeProfilesRepository([profile1]),
    );
    addTearDown(container.dispose);

    await container.read(singboxProxyRuntimeRepositoryProvider.future);
    await container
        .read(singboxProxyRuntimeRepositoryProvider.notifier)
        .ensureProfilesStarted([profile1.id]);

    // A second launch into the same container arrives while the first one's
    // start is done; restarting would drop the SOCKS port its tabs are using.
    expect(client.startCalls, isEmpty);
  });

  test(
    'concurrent startProfile calls preserve both requested profiles',
    () async {
      final profile1 = _profile(id: 'profile-1', name: 'First');
      final profile2 = _profile(id: 'profile-2', name: 'Second');
      final client = _FakeSingboxProxyClient(_state(const []));
      final container = _container(
        client: client,
        profilesRepository: _FakeProfilesRepository([profile1, profile2]),
      );
      addTearDown(container.dispose);

      await container.read(singboxProxyRuntimeRepositoryProvider.future);
      final repository = container.read(
        singboxProxyRuntimeRepositoryProvider.notifier,
      );

      await Future.wait([
        repository.startProfile(profile1.id),
        repository.startProfile(profile2.id),
      ]);

      expect(client.startCalls, hasLength(2));
      expect(
        client.startCalls.last.map((profile) => profile.id),
        unorderedEquals([
          profile1.proxyConnectionId,
          profile2.proxyConnectionId,
        ]),
      );
      expect(
        container
            .read(singboxProxyRuntimeRepositoryProvider)
            .requireValue
            .endpoints
            .map((endpoint) => endpoint.profileId),
        unorderedEquals([
          profile1.proxyConnectionId,
          profile2.proxyConnectionId,
        ]),
      );
    },
  );

  test(
    'a start that fails puts the previously running profiles back',
    () async {
      final profile1 = _profile(id: 'profile-1', name: 'First');
      final profile2 = _profile(id: 'profile-2', name: 'Broken');
      final client = _FakeSingboxProxyClient(
        _state([_endpoint(profile1.proxyConnectionId, port: 12080)]),
      )..failStartsContaining = {profile2.proxyConnectionId};
      final container = _container(
        client: client,
        profilesRepository: _FakeProfilesRepository([profile1, profile2]),
      );
      addTearDown(container.dispose);

      await container.read(singboxProxyRuntimeRepositoryProvider.future);
      final held = <Set<String>>[];
      container.listen(
        singboxProxyStartingConnectionsProvider,
        (_, next) => held.add(next),
      );

      await expectLater(
        container
            .read(singboxProxyRuntimeRepositoryProvider.notifier)
            .startProfile(profile2.id),
        throwsStateError,
      );

      // One broken profile used to take every working one down with it: the
      // runtime is a single instance, and the failed start had already closed
      // the old one (issue #669).
      expect(
        client.startCalls.map(
          (profiles) => profiles.map((profile) => profile.id).toSet(),
        ),
        [
          {profile1.proxyConnectionId, profile2.proxyConnectionId},
          {profile1.proxyConnectionId},
        ],
      );
      expect(
        container
            .read(singboxProxyRuntimeRepositoryProvider)
            .requireValue
            .endpoints
            .map((endpoint) => endpoint.profileId),
        [profile1.proxyConnectionId],
      );

      // Held as starting from the first attempt to the end of the restore, so
      // no routing computed in between blocks the profile being put back.
      expect(held.last, isEmpty);
      for (final ids in held.take(held.length - 1)) {
        expect(ids, contains(profile1.proxyConnectionId));
      }
    },
  );

  test('profiles a failed restore could not bring back are retried', () async {
    final profile1 = _profile(id: 'profile-1', name: 'First');
    final profile2 = _profile(id: 'profile-2', name: 'Broken');
    // The restore fails too: profile-1 no longer comes up either.
    final client =
        _FakeSingboxProxyClient(
            _state([_endpoint(profile1.proxyConnectionId, port: 12080)]),
          )
          ..failStartsContaining = {
            profile1.proxyConnectionId,
            profile2.proxyConnectionId,
          };
    final container = _container(
      client: client,
      profilesRepository: _FakeProfilesRepository([profile1, profile2]),
    );
    addTearDown(container.dispose);
    await container.read(singboxProxyRuntimeRepositoryProvider.future);
    // Active from startup, as `main.dart` has it.
    container.listen(singboxStartRetriesProvider, (_, _) {});

    await expectLater(
      container
          .read(singboxProxyRuntimeRepositoryProvider.notifier)
          .startProfile(profile2.id),
      throwsStateError,
    );

    // Nobody asked for profile-1 to go down, and the error the caller gets
    // is profile-2's: without a retry it stayed down unnoticed.
    expect(container.read(singboxStartRetriesProvider).keys, [profile1.id]);
  });

  test(
    'endpoints an ERROR state keeps are not taken for running profiles',
    () async {
      final profile1 = _profile(id: 'profile-1', name: 'First');
      final profile2 = _profile(id: 'profile-2', name: 'Broken');
      final client =
          _FakeSingboxProxyClient(
              _state([_endpoint(profile1.proxyConnectionId, port: 12080)]),
            )
            ..retainEndpointsOnFailure = true
            ..failStartsContaining = {
              profile1.proxyConnectionId,
              profile2.proxyConnectionId,
            };
      final container = _container(
        client: client,
        profilesRepository: _FakeProfilesRepository([profile1, profile2]),
      );
      addTearDown(container.dispose);
      await container.read(singboxProxyRuntimeRepositoryProvider.future);
      final runtime = container.read(
        singboxProxyRuntimeRepositoryProvider.notifier,
      );

      // Adding profile-2 fails, and so does putting profile-1 back; native
      // still reports profile-1's endpoint, with its instance closed.
      await expectLater(runtime.startProfile(profile2.id), throwsStateError);
      expect((await client.getState()).endpoints.map((e) => e.profileId), [
        profile1.proxyConnectionId,
      ]);

      client
        ..failStartsContaining = const {}
        ..startCalls.clear();
      final started = await runtime.retryProfile(
        profile1.id,
        stillWanted: () => true,
      );

      // Read as running, the retry returned without starting it and dropped
      // its entry, and profile-1 stayed down for good.
      expect(
        client.startCalls.map(
          (profiles) => profiles.map((profile) => profile.id).toList(),
        ),
        [
          [profile1.proxyConnectionId],
        ],
      );
      expect(started?.status, SingboxProxyRuntimeStatus.running);
      // Nothing was probed: with the runtime down, nothing else could be cut.
      expect(client.probeCalls, isEmpty);
    },
  );

  test(
    'running profile ids count neither a failed start nor an ERROR state',
    () async {
      final profile1 = _profile(id: 'profile-1', name: 'First');
      final profile2 = _profile(id: 'profile-2', name: 'Broken');
      final client =
          _FakeSingboxProxyClient(
              _state([_endpoint(profile1.proxyConnectionId, port: 12080)]),
            )
            ..retainEndpointsOnFailure = true
            ..failStartsContaining = {
              profile1.proxyConnectionId,
              profile2.proxyConnectionId,
            };
      final container = _container(
        client: client,
        profilesRepository: _FakeProfilesRepository([profile1, profile2]),
      );
      addTearDown(container.dispose);
      await container.read(singboxProxyRuntimeRepositoryProvider.future);
      container.listen(runningSingboxProfileIdsProvider, (_, _) {});
      expect(container.read(runningSingboxProfileIdsProvider), {profile1.id});

      await expectLater(
        container
            .read(singboxProxyRuntimeRepositoryProvider.notifier)
            .startProfile(profile2.id),
        throwsStateError,
      );

      // The failed restore leaves an error still carrying the RUNNING data
      // from before it.
      expect(
        container
            .read(singboxProxyRuntimeRepositoryProvider)
            .value
            ?.runningProfileIds,
        {profile1.id},
      );
      expect(container.read(runningSingboxProfileIdsProvider), isEmpty);

      // And native's ERROR state, published as data, keeps the endpoints.
      client.emit(await client.getState());
      await _drainSync();
      expect(
        container
            .read(singboxProxyRuntimeRepositoryProvider)
            .requireValue
            .endpoints,
        isNotEmpty,
      );
      expect(container.read(runningSingboxProfileIdsProvider), isEmpty);
    },
  );

  test(
    'a stop holds and reports the rest lost when they fail to come back',
    () async {
      final kept = _profile(id: 'profile-1', name: 'Kept');
      final deleted = _profile(id: 'profile-2', name: 'Deleted');
      final client = _FakeSingboxProxyClient(
        _state([
          _endpoint(kept.proxyConnectionId, port: 12080),
          _endpoint(deleted.proxyConnectionId, port: 12081),
        ]),
      )..failStartsContaining = {kept.proxyConnectionId};
      final profilesRepository = _FakeProfilesRepository([kept, deleted]);
      final container = _container(
        client: client,
        profilesRepository: profilesRepository,
      );
      addTearDown(container.dispose);
      await container.read(singboxProxyRuntimeRepositoryProvider.future);
      container.listen(singboxStartRetriesProvider, (_, _) {});

      await container
          .read(singboxProxyRuntimeRepositoryProvider.notifier)
          .deleteProfile(deleted.id);

      // The reload of the profile that stays failed: the delete behind the
      // stop used to be skipped, and the profile left down with no retry.
      expect(profilesRepository.deletedProfileIds, [deleted.id]);
      expect(client.stopAllCalls, 1);
      expect(container.read(runningSingboxProfileIdsProvider), isEmpty);
      expect(container.read(singboxStartRetriesProvider).keys, [kept.id]);
    },
  );

  test(
    'deleting a profile while the runtime is down reloads nothing',
    () async {
      final profile1 = _profile(id: 'profile-1', name: 'Deleted');
      final profile2 = _profile(id: 'profile-2', name: 'Also down');
      final profile3 = _profile(id: 'profile-3', name: 'Broken');
      // Adding profile-3 fails and so does putting 1 and 2 back: native is in
      // ERROR, still holding 1 and 2 as what it last ran.
      final client =
          _FakeSingboxProxyClient(
              _state([
                _endpoint(profile1.proxyConnectionId, port: 12080),
                _endpoint(profile2.proxyConnectionId, port: 12081),
              ]),
            )
            ..failStartsContaining = {
              profile1.proxyConnectionId,
              profile2.proxyConnectionId,
              profile3.proxyConnectionId,
            };
      final profiles = _FakeProfilesRepository([profile1, profile2, profile3]);
      final container = _container(
        client: client,
        profilesRepository: profiles,
      );
      addTearDown(container.dispose);
      await container.read(singboxProxyRuntimeRepositoryProvider.future);
      final runtime = container.read(
        singboxProxyRuntimeRepositoryProvider.notifier,
      );
      await expectLater(runtime.startProfile(profile3.id), throwsStateError);
      client.startCalls.clear();

      await runtime.deleteProfile(profile1.id);

      // The runtime's partial stop would have reloaded profile-2 from its
      // stale set — failing the delete while it could not come up.
      expect(client.stopCalls, isEmpty);
      expect(client.startCalls, isEmpty);
      expect(client.stopAllCalls, 1);
      expect(profiles.deletedProfileIds, [profile1.id]);
    },
  );

  test('a retry leaves the runtime alone while its probe fails', () async {
    final profile1 = _profile(id: 'profile-1', name: 'Working');
    final profile2 = _profile(id: 'profile-2', name: 'Unresolved');
    final client =
        _FakeSingboxProxyClient(
            _state([_endpoint(profile1.proxyConnectionId, port: 12080)]),
          )
          ..probeFailures = {
            profile2.proxyConnectionId: 'Peer address does not resolve',
          };
    final container = _container(
      client: client,
      profilesRepository: _FakeProfilesRepository([profile1, profile2]),
    );
    addTearDown(container.dispose);
    await container.read(singboxProxyRuntimeRepositoryProvider.future);

    await expectLater(
      container
          .read(singboxProxyRuntimeRepositoryProvider.notifier)
          .retryProfile(profile2.id, stillWanted: () => true),
      throwsA(isA<SingboxProbeFailed>()),
    );

    // A start that fails reloads the working profile twice, for nothing.
    expect(client.startCalls, isEmpty);
    expect(client.probeCalls, [profile2.proxyConnectionId]);
  });

  test('a retry with nothing else running starts without a probe', () async {
    final profile = _profile(id: 'profile-1', name: 'Only');
    final client = _FakeSingboxProxyClient(_state(const []));
    final container = _container(
      client: client,
      profilesRepository: _FakeProfilesRepository([profile]),
    );
    addTearDown(container.dispose);
    await container.read(singboxProxyRuntimeRepositoryProvider.future);

    await container
        .read(singboxProxyRuntimeRepositoryProvider.notifier)
        .retryProfile(profile.id, stillWanted: () => true);

    expect(client.probeCalls, isEmpty);
    expect(client.startCalls, hasLength(1));
  });

  test(
    'a retry no longer wanted once it holds the lock starts nothing',
    () async {
      final profile = _profile(id: 'profile-1', name: 'Stopped');
      final client = _FakeSingboxProxyClient(_state(const []));
      final container = _container(
        client: client,
        profilesRepository: _FakeProfilesRepository([profile]),
      );
      addTearDown(container.dispose);
      await container.read(singboxProxyRuntimeRepositoryProvider.future);

      final started = await container
          .read(singboxProxyRuntimeRepositoryProvider.notifier)
          .retryProfile(profile.id, stillWanted: () => false);

      expect(started, isNull);
      expect(client.startCalls, isEmpty);
    },
  );

  test(
    'a profile sing-box refuses is left out without reloading the rest',
    () async {
      final profile1 = _profile(id: 'profile-1', name: 'First');
      final profile2 = _profile(id: 'profile-2', name: 'Broken');
      final client = _FakeSingboxProxyClient(
        _state([_endpoint(profile1.proxyConnectionId, port: 12080)]),
      )..rejectedProfiles = {profile2.proxyConnectionId};
      final container = _container(
        client: client,
        profilesRepository: _FakeProfilesRepository([profile1, profile2]),
      );
      addTearDown(container.dispose);

      await container.read(singboxProxyRuntimeRepositoryProvider.future);
      await expectLater(
        container
            .read(singboxProxyRuntimeRepositoryProvider.notifier)
            .startProfile(profile2.id),
        throwsA(
          isA<SingboxProfilesRejected>().having(
            (error) => error.rejections.keys,
            'rejected',
            [profile2.id],
          ),
        ),
      );

      // What would run is what already runs: no reload, so the first
      // profile keeps its connections, and no restore either.
      expect(client.startCalls, isEmpty);
      expect(
        container
            .read(singboxProxyRuntimeRepositoryProvider)
            .requireValue
            .endpoints
            .map((endpoint) => endpoint.profileId),
        [profile1.proxyConnectionId],
      );
    },
  );

  test('a start leaves a refused profile out and starts the rest', () async {
    // A config sing-box refuses used to fail the whole start, taking every
    // other profile in it down too.
    final profile1 = _profile(id: 'profile-1', name: 'First');
    final profile2 = _profile(id: 'profile-2', name: 'Broken');
    final client = _FakeSingboxProxyClient(_state(const []))
      ..rejectedProfiles = {profile2.proxyConnectionId};
    final container = _container(
      client: client,
      profilesRepository: _FakeProfilesRepository([profile1, profile2]),
    );
    addTearDown(container.dispose);

    await container.read(singboxProxyRuntimeRepositoryProvider.future);
    await expectLater(
      container
          .read(singboxProxyRuntimeRepositoryProvider.notifier)
          .startProfiles([profile1.id, profile2.id]),
      throwsA(isA<SingboxProfilesRejected>()),
    );

    expect(client.startCalls.single.map((profile) => profile.id), [
      profile1.proxyConnectionId,
    ]);
    expect(
      container
          .read(singboxProxyRuntimeRepositoryProvider)
          .requireValue
          .endpoints
          .map((endpoint) => endpoint.profileId),
      [profile1.proxyConnectionId],
    );
  });

  test(
    'a start with a refused profile still applies an edit to the rest',
    () async {
      final profile1 = _profile(id: 'profile-1', name: 'First');
      final profile2 = _profile(id: 'profile-2', name: 'Broken');
      final client = _FakeSingboxProxyClient(_state(const []))
        ..rejectedProfiles = {profile2.proxyConnectionId};
      final profiles = _FakeProfilesRepository([profile1, profile2]);
      final container = _container(
        client: client,
        profilesRepository: profiles,
      );
      addTearDown(container.dispose);
      await container.read(singboxProxyRuntimeRepositoryProvider.future);
      final runtime = container.read(
        singboxProxyRuntimeRepositoryProvider.notifier,
      );
      await expectLater(
        runtime.startProfiles([profile1.id, profile2.id]),
        throwsA(isA<SingboxProfilesRejected>()),
      );

      // Unchanged, it is what already runs: no reload.
      await expectLater(
        runtime.startProfiles([profile1.id, profile2.id]),
        throwsA(isA<SingboxProfilesRejected>()),
      );
      expect(client.startCalls, hasLength(1));

      // The same ids with profile-1 edited are not: that edit has to reach
      // the runtime.
      profiles.profiles[0] = profile1.copyWith(
        configJson: '{"type":"socks","server":"edited.example"}',
      );
      await expectLater(
        runtime.startProfiles([profile1.id, profile2.id]),
        throwsA(isA<SingboxProfilesRejected>()),
      );
      expect(client.startCalls, hasLength(2));
      expect(
        client.startCalls.last.single.configJson,
        contains('edited.example'),
      );
    },
  );

  test('a profile is checked again only once it has changed', () async {
    final profile1 = _profile(id: 'profile-1', name: 'First');
    final profile2 = _profile(id: 'profile-2', name: 'Second');
    final client = _FakeSingboxProxyClient(_state(const []));
    final profiles = _FakeProfilesRepository([profile1, profile2]);
    final container = _container(client: client, profilesRepository: profiles);
    addTearDown(container.dispose);

    await container.read(singboxProxyRuntimeRepositoryProvider.future);
    final runtime = container.read(
      singboxProxyRuntimeRepositoryProvider.notifier,
    );
    await runtime.startProfiles([profile1.id]);
    await runtime.startProfiles([profile1.id, profile2.id]);

    expect(client.validateCalls, [
      profile1.proxyConnectionId,
      profile2.proxyConnectionId,
    ]);

    profiles.profiles[0] = _profile(id: 'profile-1', name: 'Renamed');
    await runtime.startProfiles([profile1.id, profile2.id]);

    expect(client.validateCalls.last, profile1.proxyConnectionId);
    expect(client.validateCalls, hasLength(3));
  });

  test('a failed first start has nothing to put back', () async {
    final profile = _profile(id: 'profile-1', name: 'Broken');
    final client = _FakeSingboxProxyClient(_state(const []))
      ..failStartsContaining = {profile.proxyConnectionId};
    final container = _container(
      client: client,
      profilesRepository: _FakeProfilesRepository([profile]),
    );
    addTearDown(container.dispose);

    await container.read(singboxProxyRuntimeRepositoryProvider.future);
    await expectLater(
      container
          .read(singboxProxyRuntimeRepositoryProvider.notifier)
          .startProfile(profile.id),
      throwsStateError,
    );

    expect(client.startCalls, hasLength(1));
    expect(container.read(singboxProxyStartingConnectionsProvider), isEmpty);
  });

  test(
    'stopProfiles holds the remaining profiles as starting for the reload',
    () async {
      final profile1 = _profile(id: 'profile-1', name: 'First');
      final profile2 = _profile(id: 'profile-2', name: 'Second');
      final client = _FakeSingboxProxyClient(
        _state([
          _endpoint(profile1.proxyConnectionId, port: 12080),
          _endpoint(profile2.proxyConnectionId, port: 12081),
        ]),
      );
      final container = _container(
        client: client,
        profilesRepository: _FakeProfilesRepository([profile1, profile2]),
      );
      addTearDown(container.dispose);

      await container.read(singboxProxyRuntimeRepositoryProvider.future);
      Set<String>? heldDuringReload;
      client.onStart = () => heldDuringReload = container.read(
        singboxProxyStartingConnectionsProvider,
      );

      await container
          .read(singboxProxyRuntimeRepositoryProvider.notifier)
          .stopProfiles([profile2.id]);

      // The runtime withdraws every endpoint while it reloads with the
      // profiles that stay; those must read as coming back, not as stopped.
      expect(heldDuringReload, {profile1.proxyConnectionId});
      expect(container.read(singboxProxyStartingConnectionsProvider), isEmpty);
    },
  );

  test(
    'stopping one profile rebuilds the DNS options for the ones that stay',
    () async {
      final profile1 = _profile(id: 'profile-1', name: 'First');
      final profile2 = _profile(id: 'profile-2', name: 'Second');
      final client = _FakeSingboxProxyClient(
        _state([
          _endpoint(profile1.proxyConnectionId, port: 12080),
          _endpoint(profile2.proxyConnectionId, port: 12081),
        ]),
      );
      final container = _container(
        client: client,
        profilesRepository: _FakeProfilesRepository([profile1, profile2]),
      );
      addTearDown(container.dispose);

      await container.read(singboxProxyRuntimeRepositoryProvider.future);
      await container
          .read(singboxProxyRuntimeRepositoryProvider.notifier)
          .stopProfiles([profile2.id]);

      // Reusing the last start's options kept a resolver detouring through
      // the stopped profile's outbound, and sing-box refused the whole config
      // ("outbound detour not found") with every remaining profile in it.
      final servers = client.startOptions.single!.dnsConfig!.servers;
      expect(servers, isNotEmpty);
      for (final server in servers) {
        expect(server.tag, isNot(contains('profile-2')));
        expect(server.detourTag ?? '', isNot(contains('profile-2')));
      }
      expect(
        servers.where((server) => server.tag.contains('profile-1')),
        isNotEmpty,
      );
    },
  );

  test(
    'deleting a profile goes ahead when the one staying up is refused',
    () async {
      // A partial stop restarts what stays, which checks it again: a profile
      // that no longer passes used to fail the stop and skip the delete.
      final profile1 = _profile(id: 'profile-1', name: 'Now broken');
      final profile2 = _profile(id: 'profile-2', name: 'Deleted');
      final client = _FakeSingboxProxyClient(
        _state([
          _endpoint(profile1.proxyConnectionId, port: 12080),
          _endpoint(profile2.proxyConnectionId, port: 12081),
        ]),
      )..rejectedProfiles = {profile1.proxyConnectionId};
      final profiles = _FakeProfilesRepository([profile1, profile2]);
      final container = _container(
        client: client,
        profilesRepository: profiles,
      );
      addTearDown(container.dispose);

      await container.read(singboxProxyRuntimeRepositoryProvider.future);
      await container
          .read(singboxProxyRuntimeRepositoryProvider.notifier)
          .deleteProfile(profile2.id);

      expect(profiles.deletedProfileIds, [profile2.id]);
      // Nothing that stays could run, so the runtime was stopped outright
      // rather than left running the deleted profile.
      expect(client.startCalls, isEmpty);
      expect(client.stopAllCalls, 1);
    },
  );

  test('a stop succeeds when only some of what stays is refused', () async {
    final profile1 = _profile(id: 'profile-1', name: 'Fine');
    final profile2 = _profile(id: 'profile-2', name: 'Now broken');
    final profile3 = _profile(id: 'profile-3', name: 'Stopped');
    final client = _FakeSingboxProxyClient(
      _state([
        _endpoint(profile1.proxyConnectionId, port: 12080),
        _endpoint(profile2.proxyConnectionId, port: 12081),
        _endpoint(profile3.proxyConnectionId, port: 12082),
      ]),
    )..rejectedProfiles = {profile2.proxyConnectionId};
    final container = _container(
      client: client,
      profilesRepository: _FakeProfilesRepository([
        profile1,
        profile2,
        profile3,
      ]),
    );
    addTearDown(container.dispose);

    await container.read(singboxProxyRuntimeRepositoryProvider.future);
    await container
        .read(singboxProxyRuntimeRepositoryProvider.notifier)
        .stopProfiles([profile3.id]);

    expect(
      container
          .read(singboxProxyRuntimeRepositoryProvider)
          .requireValue
          .endpoints
          .map((endpoint) => endpoint.profileId),
      [profile1.proxyConnectionId],
    );
  });

  test(
    'stopping a profile that is not running leaves the rest alone',
    () async {
      final profile1 = _profile(id: 'profile-1', name: 'First');
      final profile2 = _profile(id: 'profile-2', name: 'Second');
      final client = _FakeSingboxProxyClient(
        _state([_endpoint(profile1.proxyConnectionId, port: 12080)]),
      );
      final container = _container(
        client: client,
        profilesRepository: _FakeProfilesRepository([profile1, profile2]),
      );
      addTearDown(container.dispose);

      await container.read(singboxProxyRuntimeRepositoryProvider.future);
      await container
          .read(singboxProxyRuntimeRepositoryProvider.notifier)
          .stopProfiles([profile2.id]);

      // Reloading the runtime for it would only drop the running one's
      // connections.
      expect(client.startCalls, isEmpty);
      expect(client.stopCalls, isEmpty);
    },
  );

  test('stopProfiles drops the stopped profile from the runtime', () async {
    final profile1 = _profile(id: 'profile-1', name: 'First');
    final profile2 = _profile(id: 'profile-2', name: 'Second');
    final client =
        _FakeSingboxProxyClient(
            _state([
              _endpoint(profile1.proxyConnectionId, port: 12080),
              _endpoint(profile2.proxyConnectionId, port: 12081),
            ]),
          )
          ..stateAfterStop = _state([
            _endpoint(profile1.proxyConnectionId, port: 12080),
          ]);
    final containerProxyRepository = _FakeContainerProxyRepository();
    final container = _container(
      client: client,
      profilesRepository: _FakeProfilesRepository([profile1, profile2]),
      containerProxyRepository: containerProxyRepository,
    );
    addTearDown(container.dispose);

    await container.read(singboxProxyRuntimeRepositoryProvider.future);
    await container
        .read(singboxProxyRuntimeRepositoryProvider.notifier)
        .stopProfiles([profile2.id]);
    await _drainSync();

    // A start of the profile that stays, not the runtime's partial stop.
    expect(client.stopCalls, isEmpty);
    expect(client.startCalls.single.map((profile) => profile.id), [
      profile1.proxyConnectionId,
    ]);
    expect(
      container
          .read(singboxProxyRuntimeRepositoryProvider)
          .requireValue
          .endpoints
          .map((endpoint) => endpoint.profileId),
      [profile1.proxyConnectionId],
    );
  });

  test(
    'deleteProfile stops runtime and preserves persisted references',
    () async {
      final profile = _profile(id: 'profile-1', name: 'First');
      final client = _FakeSingboxProxyClient(
        _state([_endpoint(profile.proxyConnectionId, port: 12080)]),
      )..stateAfterStop = _state(const []);
      final profilesRepository = _FakeProfilesRepository([profile]);
      final containerRepository = _FakeContainerRepository();
      final routingSettingsRepository = _FakeProxyRoutingSettingsRepository(
        ProxyRoutingSettings(
          regularTabsMode: ProxyRegularTabRoutingMode.all,
          regularTabsProxyConnectionId: profile.proxyConnection,
          privateTabsProxyConnectionId: profile.proxyConnection,
          isolationContextRoutes: const {},
        ),
      );
      final container = _container(
        client: client,
        profilesRepository: profilesRepository,
        containerRepository: containerRepository,
        routingSettingsRepository: routingSettingsRepository,
      );
      addTearDown(container.dispose);

      await container.read(singboxProxyRuntimeRepositoryProvider.future);
      await container
          .read(singboxProxyRuntimeRepositoryProvider.notifier)
          .deleteProfile(profile.id);

      expect(client.stopAllCalls, 1);
      expect(containerRepository.clearedProxyConnectionIds, isEmpty);
      final routingSettings = routingSettingsRepository.peekSettings();

      expect(routingSettings, isNotNull);
      expect(routingSettings!.regularTabsMode, ProxyRegularTabRoutingMode.all);
      expect(
        routingSettings.regularTabsProxyConnectionId,
        profile.proxyConnection,
      );
      expect(
        routingSettings.privateTabsProxyConnectionId,
        profile.proxyConnection,
      );
      expect(profilesRepository.deletedProfileIds, [profile.id]);
    },
  );

  test('a blank DoH setting still starts with DNS configured', () async {
    final profile = _profile(id: 'profile-1', name: 'WireGuard');
    final client = _FakeSingboxProxyClient(_state(const []));
    final container = _container(
      client: client,
      profilesRepository: _FakeProfilesRepository([profile]),
      engineSettings: EngineSettings.withDefaults(
        dohProviderUrl: '',
        dohDefaultProviderUrl: '',
      ),
    );
    addTearDown(container.dispose);

    await container.read(singboxProxyRuntimeRepositoryProvider.future);
    await container
        .read(singboxProxyRuntimeRepositoryProvider.notifier)
        .startProfile(profile.id);

    final options = client.startOptions.single;

    // An unset resolver must not translate into "no DNS": the bootstrap URL
    // backs the platform transport that answers every lookup, and a blank one
    // leaves it returning SERVFAIL to everything.
    expect(options, isNotNull);
    expect(options!.bootstrapDohUrl, BuiltInDohProviders.quad9.url);
  });

  test(
    'starts at the quiet log level unless the setting says otherwise',
    () async {
      final profile = _profile(id: 'profile-1', name: 'WireGuard');
      final client = _FakeSingboxProxyClient(_state(const []));
      final container = _container(
        client: client,
        profilesRepository: _FakeProfilesRepository([profile]),
      );
      addTearDown(container.dispose);

      await container.read(singboxProxyRuntimeRepositoryProvider.future);
      await container
          .read(singboxProxyRuntimeRepositoryProvider.notifier)
          .startProfile(profile.id);

      // The default is load-bearing: from `info` upwards sing-box writes a line
      // per connection, and each one crosses to Dart on the main thread.
      expect(client.startOptions.single?.logLevel, SingboxProxyLogLevel.warn);
    },
  );

  test('carries the configured log level into the runtime options', () async {
    final profile = _profile(id: 'profile-1', name: 'WireGuard');
    final client = _FakeSingboxProxyClient(_state(const []));
    final container = _container(
      client: client,
      profilesRepository: _FakeProfilesRepository([profile]),
      logLevel: ProxyLogLevel.debug,
    );
    addTearDown(container.dispose);

    await container.read(singboxProxyRuntimeRepositoryProvider.future);
    await container
        .read(singboxProxyRuntimeRepositoryProvider.notifier)
        .startProfile(profile.id);

    expect(client.startOptions.single?.logLevel, SingboxProxyLogLevel.debug);
  });

  test('reloadActiveProfiles restarts exactly what is running', () async {
    final profile1 = _profile(id: 'profile-1', name: 'First');
    final profile2 = _profile(id: 'profile-2', name: 'Second');
    final client = _FakeSingboxProxyClient(
      _state([_endpoint(profile1.proxyConnectionId, port: 12080)]),
    );
    final container = _container(
      client: client,
      profilesRepository: _FakeProfilesRepository([profile1, profile2]),
    );
    addTearDown(container.dispose);

    await container.read(singboxProxyRuntimeRepositoryProvider.future);
    await container
        .read(singboxProxyRuntimeRepositoryProvider.notifier)
        .reloadActiveProfiles();

    expect(client.startCalls, hasLength(1));
    expect(client.startCalls.single.map((profile) => profile.id), [
      profile1.proxyConnectionId,
    ]);
  });

  test('reloadActiveProfiles does nothing while nothing runs', () async {
    final profile = _profile(id: 'profile-1', name: 'WireGuard');
    final client = _FakeSingboxProxyClient(_state(const []));
    final container = _container(
      client: client,
      profilesRepository: _FakeProfilesRepository([profile]),
    );
    addTearDown(container.dispose);

    await container.read(singboxProxyRuntimeRepositoryProvider.future);
    await container
        .read(singboxProxyRuntimeRepositoryProvider.notifier)
        .reloadActiveProfiles();

    expect(client.startCalls, isEmpty);
  });
}

ProviderContainer _container({
  required _FakeSingboxProxyClient client,
  required _FakeProfilesRepository profilesRepository,
  _FakeContainerProxyRepository? containerProxyRepository,
  _FakeContainerRepository? containerRepository,
  _FakeProxyRoutingSettingsRepository? routingSettingsRepository,
  EngineSettings? engineSettings,
  ProxyLogLevel? logLevel,
}) {
  final container = ProviderContainer(
    overrides: [
      singboxProxyClientProvider.overrideWithValue(client),
      singboxProxyProfilesRepositoryProvider.overrideWith(
        () => profilesRepository,
      ),
      singboxProxyCredentialsRepositoryProvider.overrideWith(
        _FakeCredentialsRepository.new,
      ),
      engineSettingsRepositoryProvider.overrideWith(
        () => _FakeEngineSettingsRepository(engineSettings),
      ),
      containerProxyRepositoryProvider.overrideWith(
        () => containerProxyRepository ?? _FakeContainerProxyRepository(),
      ),
      containerRepositoryProvider.overrideWith(
        () => containerRepository ?? _FakeContainerRepository(),
      ),
      proxyRoutingSettingsRepositoryProvider.overrideWith(
        () =>
            routingSettingsRepository ?? _FakeProxyRoutingSettingsRepository(),
      ),
      proxyDiagnosticsSettingsRepositoryProvider.overrideWith(
        () => _FakeProxyDiagnosticsSettingsRepository(logLevel),
      ),
    ],
  );

  return container;
}

/// Drains all currently-pending microtasks/futures so listeners chained off
/// the runtime state stream have time to settle.
Future<void> _drainSync() => pumpEventQueue();

ProxyProfile _profile({required String id, required String name}) {
  final createdAt = DateTime(2026);

  return ProxyProfile(
    id: id,
    name: name,
    type: SingboxProxyProfileType.customOutbound,
    configJson: '{"type":"socks"}',
    autostart: false,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

SingboxProxyRuntimeState _state(List<SingboxProxyRuntimeEndpoint> endpoints) {
  return SingboxProxyRuntimeState(
    status: endpoints.isEmpty
        ? SingboxProxyRuntimeStatus.stopped
        : SingboxProxyRuntimeStatus.running,
    endpoints: endpoints,
  );
}

SingboxProxyRuntimeEndpoint _endpoint(String profileId, {required int port}) {
  return SingboxProxyRuntimeEndpoint(
    profileId: profileId,
    host: '127.0.0.1',
    port: port,
    username: 'user-$port',
    password: 'pass-$port',
  );
}

class _FakeSingboxProxyClient implements SingboxProxyClient {
  final _stateController =
      StreamController<SingboxProxyRuntimeState>.broadcast();
  final startCalls = <List<SingboxProxyProfile>>[];
  final startOptions = <SingboxProxyRuntimeOptions?>[];
  final stopCalls = <String>[];
  int stopAllCalls = 0;
  SingboxProxyRuntimeState _currentState;
  SingboxProxyRuntimeState? stateAfterStop;

  /// A start whose profile list includes any of these fails, the way a whole
  /// sing-box start does when one of its profiles cannot come up.
  Set<String> failStartsContaining = const {};

  /// Whether a failed start keeps the endpoints it had in its ERROR state, as
  /// the native runtime does for reporting. Their instance is closed either
  /// way.
  bool retainEndpointsOnFailure = false;

  /// Runs inside [start], so a test can observe what is published mid-reload.
  void Function()? onStart;

  /// Profiles sing-box refuses when asked to check them.
  Set<String> rejectedProfiles = const {};

  _FakeSingboxProxyClient(this._currentState);

  @override
  Stream<SingboxProxyRuntimeState> get stateStream => _stateController.stream;

  @override
  Stream<SingboxProxyLogMessage> get logStream => const Stream.empty();

  void emit(SingboxProxyRuntimeState state) {
    _currentState = state;
    _stateController.add(state);
  }

  @override
  Future<SingboxProxyRuntimeState> getState() async => _currentState;

  @override
  Future<SingboxProxyRuntimeState> start(
    List<SingboxProxyProfile> profiles, {
    SingboxProxyRuntimeOptions? options,
  }) async {
    startCalls.add(profiles);
    startOptions.add(options);
    onStart?.call();
    final failing = profiles.where(
      (profile) => failStartsContaining.contains(profile.id),
    );
    if (failing.isNotEmpty) {
      // The previous instance is already closed by the time a start fails.
      _currentState = SingboxProxyRuntimeState(
        status: SingboxProxyRuntimeStatus.error,
        endpoints: retainEndpointsOnFailure
            ? _currentState.endpoints
            : const [],
        message: 'start failed',
      );
      throw StateError('start failed for ${failing.first.id}');
    }
    return _currentState = _state(
      profiles.indexed
          .map((item) => _endpoint(item.$2.id, port: 12080 + item.$1))
          .toList(),
    );
  }

  @override
  Future<void> stop(List<String> profileIds) async {
    stopCalls.addAll(profileIds);
    _currentState = stateAfterStop ?? _currentState;
  }

  @override
  Future<void> stopAll() async {
    stopAllCalls += 1;
    _currentState = _state(const []);
  }

  /// Every profile [validateProfile] was asked about, by id.
  final validateCalls = <String>[];

  /// What [probeProfile] answers, by runtime profile id; null when absent.
  Map<String, String> probeFailures = const {};
  final probeCalls = <String>[];

  @override
  Future<String?> probeProfile(SingboxProxyProfile profile) async {
    probeCalls.add(profile.id);
    return probeFailures[profile.id];
  }

  @override
  Future<String?> validateProfile(SingboxProxyProfile profile) async {
    validateCalls.add(profile.id);
    return rejectedProfiles.contains(profile.id) ? 'invalid key' : null;
  }

  @override
  Future<SingboxProxyConfigResult> buildConfig(
    List<SingboxProxyProfile> profiles, {
    SingboxProxyRuntimeOptions? options,
  }) async {
    return SingboxProxyConfigResult(configJson: '{}', endpoints: const []);
  }
}

class _FakeProfilesRepository extends SingboxProxyProfilesRepository {
  final List<ProxyProfile> profiles;
  final deletedProfileIds = <String>[];

  _FakeProfilesRepository(this.profiles);

  @override
  Future<List<ProxyProfile>> fetchProfiles() async => profiles;

  @override
  Future<void> deleteProfile(String profileId) async {
    deletedProfileIds.add(profileId);
  }

  @override
  Stream<List<ProxyProfile>> build() => Stream.value(profiles);
}

class _FakeCredentialsRepository extends SingboxProxyCredentialsRepository {
  @override
  Future<String?> readSecretJson(String profileId) async => null;

  @override
  void build() {}
}

class _FakeEngineSettingsRepository extends EngineSettingsRepository {
  final EngineSettings settings;

  _FakeEngineSettingsRepository([EngineSettings? settings])
    : settings = settings ?? EngineSettings.withDefaults();

  @override
  Future<EngineSettings> fetchSettings() async => settings;

  @override
  Stream<EngineSettings> build() => Stream.value(settings);
}

class _FakeProxyDiagnosticsSettingsRepository
    extends ProxyDiagnosticsSettingsRepository {
  final ProxyDiagnosticsSettings settings;

  _FakeProxyDiagnosticsSettingsRepository([ProxyLogLevel? logLevel])
    : settings = ProxyDiagnosticsSettings.withDefaults(logLevel: logLevel);

  @override
  Future<ProxyDiagnosticsSettings> fetchSettings() async => settings;

  @override
  Stream<ProxyDiagnosticsSettings> build() => Stream.value(settings);
}

class _FakeContainerProxyRepository extends ContainerProxyRepository {
  @override
  void build() {}
}

class _FakeContainerRepository extends ContainerRepository {
  final clearedProxyConnectionIds = <ProxyConnectionId>[];

  @override
  Future<void> clearProxyConnectionAssignments(
    ProxyConnectionId proxyConnectionId,
  ) async {
    clearedProxyConnectionIds.add(proxyConnectionId);
  }

  @override
  void build() {}
}

class _FakeProxyRoutingSettingsRepository
    extends ProxyRoutingSettingsRepository {
  final ProxyRoutingSettings? _settings;

  _FakeProxyRoutingSettingsRepository([this._settings]);

  ProxyRoutingSettings? peekSettings() => _settings;

  @override
  Stream<ProxyRoutingSettings> build() {
    return Stream.value(_settings ?? ProxyRoutingSettings.withDefaults());
  }
}
