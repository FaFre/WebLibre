import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/data/models/bang_key.dart';

const webSearchBangTrigger = 'wl';

final webSearchBang = BangData(
  websiteName: 'WebLibre Search',
  domain: 'weblibre.eu',
  trigger: webSearchBangTrigger,
  // Placeholder template — selecting this bang routes the query through the
  // token-based search backend instead of opening this URL.
  urlTemplate: 'https://weblibre.eu/?q={{{s}}}',
  group: BangGroup.weblibre,
  searxngApi: false,
);

const webSearchBangKey = BangKey(
  group: BangGroup.weblibre,
  trigger: webSearchBangTrigger,
);

bool isWebSearchBang(BangData? bang) =>
    bang != null && bang.group == BangGroup.weblibre;
