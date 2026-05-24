import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';

void main() {
  group('ContainerMetadata proxy serialization', () {
    test('round-trips proxyConnectionId through JSON', () {
      final metadata = ContainerMetadata.withDefaults(
        proxyConnectionId: const SingboxProxyConnectionId('profile-1'),
        clearDataOnExit: true,
      );

      final json = metadata.toJson();
      final restored = ContainerMetadata.fromJson(json);

      expect(
        json['proxyConnectionId'],
        const SingboxProxyConnectionId('profile-1').encode(),
      );
      expect(json['clearDataOnExit'], isTrue);
      expect(restored.proxyConnectionId, metadata.proxyConnectionId);
      expect(restored.usesTorProxy, isFalse);
    });

    test('usesTorProxy is true only for the Tor connection id', () {
      final tor = ContainerMetadata.withDefaults(
        proxyConnectionId: const TorProxyConnectionId(),
      );

      expect(tor.usesTorProxy, isTrue);
    });
  });

  group('ContainerMetadata icon serialization', () {
    test('stores MDI icon names', () {
      final metadata = ContainerMetadata.withDefaults(
        iconData: MdiIcons.folderOutline,
      );

      final json = metadata.toJson();
      final restored = ContainerMetadata.fromJson(json);

      expect(json['iconData'], <String, dynamic>{'name': 'folder-outline'});
      expect(restored.iconData, MdiIcons.folderOutline);
    });

    test('restores legacy code point JSON as a const MDI icon', () {
      final restored = ContainerMetadata.fromJson({
        'iconData': <String, dynamic>{
          'codePoint': MdiIcons.folderOutline.codePoint,
          'fontFamily': MdiIcons.folderOutline.fontFamily,
          'fontPackage': MdiIcons.folderOutline.fontPackage,
        },
      });

      expect(identical(restored.iconData, MdiIcons.folderOutline), isTrue);
    });
  });
}
